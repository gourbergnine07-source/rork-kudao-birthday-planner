//
//  GreetingService.swift
//  Kudao
//

import Foundation
import OSLog

/// Everything the model needs to write a personal birthday message.
nonisolated struct GreetingInput: Sendable {
    let name: String
    let relationship: String
    let turningAge: Int
    /// Life stage computed from the birth date; drives how the message is worded.
    let ageBracket: AgeBracket
    /// Cartoon or character a child loves, empty for everybody else.
    let favoriteCharacter: String
    /// One line per diary category, e.g. "cibo: sushi, ramen".
    let tagLines: [String]
    let tone: GreetingTone
}

private nonisolated struct GreetingResponse: Decodable, Sendable {
    struct Choice: Decodable, Sendable {
        struct Message: Decodable, Sendable { let content: String? }
        let message: Message
    }
    let choices: [Choice]
}

/// Writes the ready-to-send birthday message from the diary keywords.
nonisolated enum GreetingService {
    private static let logger = Logger(subsystem: "com.kudao.app", category: "greeting")
    private static let model = "anthropic/claude-sonnet-4.6"
    private static let fallbackModels = ["anthropic/claude-haiku-4.5", "openai/gpt-5-mini"]

    static func generate(_ input: GreetingInput, language: AppLanguage) async throws -> String {
        guard let url = ProxyClient.vercelChatCompletionsURL else { throw ProxyError.badResponse }

        let system = """
        You write short birthday messages that a person can send as-is to someone they care about.

        Rules:
        - Answer with the message text only. No greeting label, no quotes, no markdown, no explanation.
        - 2 to 4 sentences, max 55 words. It must read like a real person wrote it.
        - Address the person directly by their first name at least once.
        - Weave in one or two of the collected keywords naturally. Never list them, never say \
        "according to my notes". If there are no keywords, stay warm and generic.
        - Never mention the gift, the party, the surprise or this app.
        - Tone: \(input.tone.promptInstruction).
        - Register for this age bracket (\(input.ageBracket.rawValue)): \(input.ageBracket.greetingGuidance).
        - Adapt to the relationship too: informal and direct with friends and peers, warmer and more \
        affectionate with family and partners, simple and playful with children.
        - Write in the first person, as if the sender were writing it themselves. Never sign it, \
        never add a placeholder name at the end.
        - Write in \(language.promptName).
        """

        var lines: [String] = [
            "Person: \(input.name)",
            "Relationship to the sender: \(input.relationship)",
            "Turning age: \(input.turningAge)",
            "fascia_eta: \(input.ageBracket.rawValue)"
        ]
        if !input.favoriteCharacter.isEmpty {
            lines.append("Favourite character or cartoon: \(input.favoriteCharacter)")
        }
        if input.tagLines.isEmpty {
            lines.append("Collected keywords: none")
        } else {
            lines.append("Collected keywords by category:")
            lines.append(contentsOf: input.tagLines.map { "- \($0)" })
        }

        let body: [String: Any] = [
            "model": model,
            "temperature": 0.8,
            "max_tokens": 300,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": lines.joined(separator: "\n")]
            ],
            "providerOptions": ["gateway": ["models": fallbackModels]]
        ]

        let request = try ProxyClient.jsonRequest(url: url, body: body)
        let (data, _) = try await ProxyClient.sendWithRetry(request)
        guard !data.isEmpty else { throw ProxyError.noData }

        let completion = try JSONDecoder().decode(GreetingResponse.self, from: data)
        let text = sanitized(completion.choices.first?.message.content ?? "")
        guard !text.isEmpty else {
            logger.error("Greeting generation returned an empty message")
            throw ProxyError.noData
        }
        return text
    }

    /// Strips wrapping quotes and stray fences some models still add.
    private static func sanitized(_ raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```") {
            text = text
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let quotes: Set<Character> = ["\"", "\u{201C}", "\u{201D}", "\u{00AB}", "\u{00BB}"]
        while let first = text.first, quotes.contains(first) {
            text.removeFirst()
        }
        while let last = text.last, quotes.contains(last) {
            text.removeLast()
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
