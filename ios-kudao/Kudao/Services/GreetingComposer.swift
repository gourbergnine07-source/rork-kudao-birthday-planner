//
//  GreetingComposer.swift
//  Kudao
//

import Foundation
import Observation
import OSLog
import SwiftData

/// Generates the birthday greeting and stores it on the profile's `BirthdayMessage`.
///
/// The stored record is the single source of truth: the AI only fills it in, the user
/// stays free to edit the text afterwards without it being overwritten.
@Observable
final class GreetingComposer {
    private let logger = Logger(subsystem: "com.kudao.app", category: "greeting-composer")

    private(set) var isGenerating: Bool = false
    private(set) var errorMessage: String?

    /// Voice used for the next generation.
    var tone: GreetingTone = .warm

    func clearError() {
        errorMessage = nil
    }

    /// Loads the tone the profile was last generated with, so the picker reopens where it was.
    func adoptTone(from profile: BirthdayProfile) {
        guard let message = profile.birthdayMessage, message.hasText else { return }
        tone = message.tone
    }

    /// Returns the stored message, creating an empty one on first use.
    @discardableResult
    func record(for profile: BirthdayProfile, context: ModelContext) -> BirthdayMessage {
        if let existing = profile.birthdayMessage, !existing.isDeleted {
            return existing
        }
        let created = BirthdayMessage(
            scheduledAt: BirthdayMessage.defaultSendDate(for: profile),
            tone: tone,
            profile: profile
        )
        context.insert(created)
        profile.birthdayMessage = created
        save(context)
        return created
    }

    /// Generates only when nothing has been written yet, so edits are never lost.
    func generateIfNeeded(for profile: BirthdayProfile, language: AppLanguage, context: ModelContext) {
        guard !(profile.birthdayMessage?.hasText ?? false) else { return }
        generate(for: profile, language: language, context: context)
    }

    /// Always asks for a fresh message, replacing whatever the record holds.
    func generate(for profile: BirthdayProfile, language: AppLanguage, context: ModelContext) {
        guard !isGenerating else { return }

        let input = GreetingInput(
            name: profile.name,
            relationship: profile.relationship.rawValue,
            turningAge: profile.countdown.turningAge,
            ageBracket: profile.ageBracket,
            favoriteCharacter: profile.trimmedFavoriteCharacter,
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
                guard let self, !profile.isDeleted else { return }
                let record = self.record(for: profile, context: context)
                record.text = text
                record.tone = requestedTone
                record.updatedAt = Date()
                self.save(context)
            } catch {
                self?.handle(error)
            }
        }
    }

    func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            logger.error("Saving the birthday message failed: \(error.localizedDescription, privacy: .public)")
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
