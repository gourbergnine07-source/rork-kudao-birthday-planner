//
//  SuggestionService.swift
//  Kudao
//

import Foundation
import OSLog

/// Everything the engine knows about a person when asking for a plan.
nonisolated struct SuggestionInput: Sendable {
    let name: String
    /// English relationship label, used inside the prompt.
    let relationship: String
    let age: Int
    /// One line per category, e.g. "cibo: sushi, ramen".
    let tagLines: [String]
    /// Short summaries of notes flagged as gift-relevant.
    let giftLeads: [String]
    let keywordCount: Int
}

private nonisolated struct GiftPayload: Decodable, Sendable {
    let idea: String?
    let fascia_prezzo: String?
    let motivazione: String?
}

private nonisolated struct CakePayload: Decodable, Sendable {
    let tipo: String?
    let motivazione: String?
}

private nonisolated struct VenuePayload: Decodable, Sendable {
    let suggerimento: String?
    let motivazione: String?
}

private nonisolated struct PlanPayload: Decodable, Sendable {
    let regalo: GiftPayload?
    let torta: CakePayload?
    let locale_tipo: VenuePayload?
    let numero_invitati_stimato: Int?
    let confidenza: String?
}

private nonisolated struct ChatResponse: Decodable, Sendable {
    struct Choice: Decodable, Sendable {
        struct Message: Decodable, Sendable { let content: String? }
        let message: Message
    }
    let choices: [Choice]
}

/// Asks Claude for a full party plan, or for a single refreshed card.
nonisolated enum SuggestionService {
    private static let logger = Logger(subsystem: "com.kudao.app", category: "suggestions")
    private static let model = "anthropic/claude-sonnet-4.6"
    private static let fallbackModels = ["anthropic/claude-haiku-4.5", "openai/gpt-5-mini"]

    // MARK: - Prompts

    private static func systemPrompt(language: AppLanguage) -> String {
        """
        You are a birthday party planner. From the preferences a user collected about a person \
        you propose a gift, a cake, a venue type and an estimated guest count.

        Answer with ONLY a raw JSON object, no prose, no markdown fences, using exactly this shape:
        {
          "regalo": {"idea": "...", "fascia_prezzo": "basso" | "medio" | "alto", "motivazione": "..."},
          "torta": {"tipo": "...", "motivazione": "..."},
          "locale_tipo": {"suggerimento": "...", "motivazione": "..."},
          "numero_invitati_stimato": 12,
          "confidenza": "bassa" | "media" | "alta"
        }

        Rules:
        - Every "idea", "tipo" and "suggerimento" is one concrete proposal, 3 to 10 words. \
        Never a list, never several options separated by "or".
        - Every "motivazione" is 1 short sentence (max 18 words) and must reference the collected \
        keywords explicitly. Never invent preferences that are not in the input.
        - "numero_invitati_stimato" is a realistic integer between 2 and 60 for this relationship and age.
        - "confidenza" reflects how much evidence the keywords give you: few or vague keywords \
        means "bassa", a rich and coherent list means "alta".
        - Write every text value in \(language.promptName). Keep the JSON keys exactly as above, in Italian.
        """
    }

    private static func userPrompt(_ input: SuggestionInput) -> String {
        var lines: [String] = [
            "Person: \(input.name)",
            "Relationship to the user: \(input.relationship)",
            "Turning age: \(input.age)"
        ]
        if input.tagLines.isEmpty {
            lines.append("Collected keywords: none")
        } else {
            lines.append("Collected keywords by category:")
            lines.append(contentsOf: input.tagLines.map { "- \($0)" })
        }
        if !input.giftLeads.isEmpty {
            lines.append("Notes flagged as gift-relevant:")
            lines.append(contentsOf: input.giftLeads.map { "- \($0)" })
        }
        lines.append("Total distinct keywords: \(input.keywordCount)")
        return lines.joined(separator: "\n")
    }

    // MARK: - Requests

    /// Generates the whole plan. Throws `ProxyError` on transport or parsing failures.
    static func generatePlan(_ input: SuggestionInput, language: AppLanguage) async throws -> PartySuggestion {
        let content = try await complete(
            system: systemPrompt(language: language),
            user: userPrompt(input),
            maxTokens: 700
        )

        guard let payload = decode(PlanPayload.self, from: content) else {
            logger.error("Plan generation returned an unreadable payload")
            throw ProxyError.badResponse
        }

        let suggestion = PartySuggestion(
            giftIdea: clean(payload.regalo?.idea),
            giftPriceBand: PriceBand.parse(payload.regalo?.fascia_prezzo ?? ""),
            giftReason: clean(payload.regalo?.motivazione),
            cakeType: clean(payload.torta?.tipo),
            cakeReason: clean(payload.torta?.motivazione),
            venueIdea: clean(payload.locale_tipo?.suggerimento),
            venueReason: clean(payload.locale_tipo?.motivazione),
            guestCount: clampGuests(payload.numero_invitati_stimato),
            confidence: SuggestionConfidence.parse(payload.confidenza ?? "")
        )

        guard !suggestion.giftIdea.isEmpty || !suggestion.cakeType.isEmpty else {
            throw ProxyError.badResponse
        }
        return capped(suggestion, keywordCount: input.keywordCount)
    }

    /// Regenerates a single card, asking for an alternative to what is on screen.
    static func regenerate(
        section: PlanSection,
        current: PartySuggestion,
        input: SuggestionInput,
        language: AppLanguage
    ) async throws -> PartySuggestion {
        let shape: String
        switch section {
        case .gift:
            shape = #"{"regalo": {"idea": "...", "fascia_prezzo": "basso" | "medio" | "alto", "motivazione": "..."}}"#
        case .cake:
            shape = #"{"torta": {"tipo": "...", "motivazione": "..."}}"#
        case .venue:
            shape = #"{"locale_tipo": {"suggerimento": "...", "motivazione": "..."}}"#
        case .guests:
            shape = #"{"numero_invitati_stimato": 12}"#
        }

        let system = """
        \(systemPrompt(language: language))

        For this request answer with ONLY this reduced JSON object and nothing else:
        \(shape)
        """

        let currentValue: String
        switch section {
        case .gift: currentValue = current.giftIdea
        case .cake: currentValue = current.cakeType
        case .venue: currentValue = current.venueIdea
        case .guests: currentValue = String(current.guestCount)
        }

        let user = """
        \(userPrompt(input))

        Current proposal for "\(section.jsonKey)": \(currentValue)
        Propose a clearly different alternative that still fits the collected keywords.
        """

        let content = try await complete(system: system, user: user, maxTokens: 300, temperature: 0.7)

        guard let payload = decode(PlanPayload.self, from: content) else {
            logger.error("Section regeneration returned an unreadable payload")
            throw ProxyError.badResponse
        }

        var updated = current
        switch section {
        case .gift:
            let idea = clean(payload.regalo?.idea)
            guard !idea.isEmpty else { throw ProxyError.badResponse }
            updated.giftIdea = idea
            updated.giftPriceBand = PriceBand.parse(payload.regalo?.fascia_prezzo ?? current.giftPriceBand.rawValue)
            updated.giftReason = clean(payload.regalo?.motivazione)
        case .cake:
            let type = clean(payload.torta?.tipo)
            guard !type.isEmpty else { throw ProxyError.badResponse }
            updated.cakeType = type
            updated.cakeReason = clean(payload.torta?.motivazione)
        case .venue:
            let venue = clean(payload.locale_tipo?.suggerimento)
            guard !venue.isEmpty else { throw ProxyError.badResponse }
            updated.venueIdea = venue
            updated.venueReason = clean(payload.locale_tipo?.motivazione)
        case .guests:
            guard let count = payload.numero_invitati_stimato else { throw ProxyError.badResponse }
            updated.guestCount = clampGuests(count)
        }
        return updated
    }

    // MARK: - Transport

    private static func complete(
        system: String,
        user: String,
        maxTokens: Int,
        temperature: Double = 0.3
    ) async throws -> String {
        guard let url = ProxyClient.vercelChatCompletionsURL else { throw ProxyError.badResponse }

        let body: [String: Any] = [
            "model": model,
            "temperature": temperature,
            "max_tokens": maxTokens,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user]
            ],
            "providerOptions": ["gateway": ["models": fallbackModels]]
        ]

        let request = try ProxyClient.jsonRequest(url: url, body: body)
        let (data, _) = try await ProxyClient.sendWithRetry(request)
        guard !data.isEmpty else { throw ProxyError.noData }

        let completion = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = completion.choices.first?.message.content, !content.isEmpty else {
            throw ProxyError.noData
        }
        return content
    }

    // MARK: - Helpers

    /// Models sometimes wrap JSON in prose or fences — grab the outermost object.
    private static func decode<T: Decodable>(_ type: T.Type, from content: String) -> T? {
        guard let start = content.firstIndex(of: "{"),
              let end = content.lastIndex(of: "}"),
              start < end else { return nil }
        guard let data = String(content[start...end]).data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func clean(_ value: String?) -> String {
        (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func clampGuests(_ value: Int?) -> Int {
        min(max(value ?? 8, 2), 60)
    }

    /// The diary volume caps how confident the plan is allowed to look.
    private static func capped(_ suggestion: PartySuggestion, keywordCount: Int) -> PartySuggestion {
        var result = suggestion
        let ceiling = SuggestionConfidence.ceiling(forKeywordCount: keywordCount)
        if result.confidence.rank > ceiling.rank {
            result.confidence = ceiling
        }
        return result
    }
}
