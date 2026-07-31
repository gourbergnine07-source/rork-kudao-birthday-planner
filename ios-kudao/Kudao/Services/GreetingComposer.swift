//
//  GreetingComposer.swift
//  Kudao
//

import Foundation
import Observation
import OSLog

/// Holds the birthday message for one profile screen, per tone.
@Observable
final class GreetingComposer {
    private let logger = Logger(subsystem: "com.kudao.app", category: "greeting-composer")

    private(set) var isGenerating: Bool = false
    private(set) var errorMessage: String?
    /// Cached message per tone, so switching tones back and forth costs nothing.
    private var messages: [GreetingTone: String] = [:]

    var tone: GreetingTone = .warm

    var message: String? { messages[tone] }

    func clearError() {
        errorMessage = nil
    }

    /// Generates the message for the current tone unless one is already cached.
    func generateIfNeeded(for profile: BirthdayProfile, language: AppLanguage) {
        guard messages[tone] == nil else { return }
        generate(for: profile, language: language)
    }

    /// Always asks for a fresh message, replacing the cached one.
    func generate(for profile: BirthdayProfile, language: AppLanguage) {
        guard !isGenerating else { return }

        let input = GreetingInput(
            name: profile.name,
            relationship: profile.relationship.rawValue,
            turningAge: profile.countdown.turningAge,
            tagLines: Self.tagLines(for: profile),
            tone: tone
        )
        let requestedTone = tone

        isGenerating = true
        errorMessage = nil

        Task { [weak self] in
            defer { self?.isGenerating = false }
            do {
                let text = try await GreetingService.generate(input, language: language)
                self?.messages[requestedTone] = text
            } catch {
                self?.handle(error)
            }
        }
    }

    private func handle(_ error: Error) {
        logger.error("Greeting request failed: \(error.localizedDescription, privacy: .public)")
        if let proxyError = error as? ProxyError {
            errorMessage = proxyError.errorDescription
        } else {
            errorMessage = ProxyError.serverError(0).errorDescription
        }
    }

    /// Same keyword grouping the party plan uses, so both features share one source of truth.
    private static func tagLines(for profile: BirthdayProfile) -> [String] {
        SuggestionEngine.makeInput(for: profile).tagLines
    }
}
