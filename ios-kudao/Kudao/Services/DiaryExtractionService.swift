//
//  DiaryExtractionService.swift
//  Kudao
//

import Foundation
import OSLog

/// Structured result of the AI pass over a diary note.
nonisolated struct DiaryExtraction: Sendable {
    let category: DiaryCategory
    let keywords: [String]
    let isGiftRelevant: Bool
    let summary: String
}

/// Raw JSON contract returned by the model.
private nonisolated struct DiaryExtractionPayload: Decodable, Sendable {
    let categoria: String?
    let tag: [String]?
    let rilevanza_regalo: Bool?
    let note_sintetiche: String?
}

private nonisolated struct ChatCompletionResponse: Decodable, Sendable {
    struct Choice: Decodable, Sendable {
        struct Message: Decodable, Sendable { let content: String? }
        let message: Message
    }
    let choices: [Choice]
}

/// Sends a diary note to Claude and turns the answer into tags the app can group.
nonisolated enum DiaryExtractionService {
    private static let logger = Logger(subsystem: "com.kudao.app", category: "diary-extraction")
    private static let model = "anthropic/claude-sonnet-4.6"
    private static let fallbackModels = ["anthropic/claude-haiku-4.5", "openai/gpt-5-mini"]

    private static func systemPrompt(language: AppLanguage, occasion: OccasionKind) -> String {
        if occasion == .remembrance {
            return remembrancePrompt(language: language)
        }

        let framing: String
        switch occasion {
        case .wedding:
            framing = "a couple whose wedding anniversary they are preparing"
        case .other:
            framing = "a person whose upcoming occasion they are preparing"
        case .birthday, .remembrance:
            framing = "a person whose birthday they are preparing"
        }

        return """
        You extract structured gift-planning data from short diary notes that a user writes \
        about \(framing).

        Answer with ONLY a raw JSON object, no prose, no markdown fences, using exactly this shape:
        {
          "categoria": "cibo" | "viaggi" | "shopping" | "hobby" | "luoghi" | "altro",
          "tag": ["keyword 1", "keyword 2"],
          "rilevanza_regalo": true or false,
          "note_sintetiche": "short summary of 5-10 words"
        }

        Rules:
        - "categoria" must be exactly one of the six allowed values, lowercase.
        - "tag": 1 to 4 short lowercase keywords (1-3 words each), concrete nouns or named \
        entities taken from the note. No sentences, no duplicates, no hashtags.
        - "rilevanza_regalo": true only when the note could realistically help choose a gift, \
        a cake, a venue or a party detail.
        - "note_sintetiche": 5 to 10 words maximum.
        - Write "tag" and "note_sintetiche" in \(language.promptName).
        - If the note is vague, still answer with the best guess and use "altro".
        """
    }

    /// A remembrance diary is not shopping research: it collects who somebody was.
    private static func remembrancePrompt(language: AppLanguage) -> String {
        """
        You help someone keep the memory of a person who has passed away. They write short \
        notes: anecdotes, habits, sayings, qualities, places and passions tied to that person. \
        You turn each note into structured keywords so the memories stay searchable.

        Answer with ONLY a raw JSON object, no prose, no markdown fences, using exactly this shape:
        {
          "categoria": "cibo" | "viaggi" | "shopping" | "hobby" | "luoghi" | "altro",
          "tag": ["keyword 1", "keyword 2"],
          "rilevanza_regalo": true or false,
          "note_sintetiche": "short summary of 5-10 words"
        }

        Meaning of the fields in this context:
        - "categoria": where the memory belongs. Use "hobby" for passions, crafts and talents, \
        "luoghi" for places bound to the person, "cibo" for dishes and rituals around the table, \
        "viaggi" for journeys and holidays, "shopping" for cherished objects, and "altro" for \
        character traits, sayings, anecdotes and family stories.
        - "tag": 1 to 4 short lowercase keywords (1-3 words each) taken from the note — a trait, \
        a habit, a place, a person, an object. No sentences, no duplicates, no hashtags.
        - "rilevanza_regalo": true when the note captures something that really defines the \
        person — a quality, a recurring habit, a story worth retelling. False for passing details.
        - "note_sintetiche": 5 to 10 words maximum, in the tone of a memory.

        Rules:
        - Never suggest gifts, parties, cakes or purchases. This is remembrance, not planning.
        - Stay respectful and matter-of-fact. Never add sentiment the note does not contain.
        - Write "tag" and "note_sintetiche" in \(language.promptName).
        - If the note is vague, still answer with the best guess and use "altro".
        """
    }

    /// Throws `ProxyError` on transport failures and `ProxyError.badResponse` on unparseable output.
    static func extract(
        note: String,
        personName: String,
        language: AppLanguage,
        occasion: OccasionKind = .birthday
    ) async throws -> DiaryExtraction {
        guard let url = ProxyClient.vercelChatCompletionsURL else {
            throw ProxyError.badResponse
        }

        let userPrompt = """
        Person: \(personName)
        Diary note: \(note)
        """

        let body: [String: Any] = [
            "model": model,
            "temperature": 0,
            "max_tokens": 300,
            "messages": [
                ["role": "system", "content": systemPrompt(language: language, occasion: occasion)],
                ["role": "user", "content": userPrompt]
            ],
            "providerOptions": ["gateway": ["models": fallbackModels]]
        ]

        let request = try ProxyClient.jsonRequest(url: url, body: body)
        let (data, _) = try await ProxyClient.sendWithRetry(request)

        guard !data.isEmpty else { throw ProxyError.noData }

        let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = completion.choices.first?.message.content,
              let payload = decodePayload(from: content) else {
            logger.error("Diary extraction returned an unreadable payload")
            throw ProxyError.badResponse
        }

        let keywords = (payload.tag ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty && $0.count <= 40 }
            .reduce(into: [String]()) { result, keyword in
                if !result.contains(keyword) { result.append(keyword) }
            }
            .prefix(4)

        let summary = (payload.note_sintetiche ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        return DiaryExtraction(
            category: DiaryCategory.parse(payload.categoria ?? ""),
            keywords: Array(keywords),
            isGiftRelevant: payload.rilevanza_regalo ?? false,
            summary: summary
        )
    }

    /// Models sometimes wrap JSON in prose or fences — grab the outermost object.
    private static func decodePayload(from content: String) -> DiaryExtractionPayload? {
        guard let start = content.firstIndex(of: "{"),
              let end = content.lastIndex(of: "}"),
              start < end else { return nil }
        let json = String(content[start...end])
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(DiaryExtractionPayload.self, from: data)
    }
}
