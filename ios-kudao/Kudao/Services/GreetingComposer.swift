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
        guard let message = profile.birthdayMessage, message.hasText else {
            tone = tone.resolved(for: profile.occasion)
            return
        }
        tone = message.tone.resolved(for: profile.occasion)
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
        Task { await run(for: profile, language: language, tone: tone, isAutomatic: false, context: context) }
    }

    /// Rewrites the draft when the diary gained new material since it was written.
    ///
    /// Automatic rewrites stop the moment the user touches the text, marks the
    /// greeting as sent, or switches the option off, so nothing handwritten is lost.
    /// Returns true when the text actually changed, so callers can refresh the reminder.
    @discardableResult
    func refreshFromDiary(
        for profile: BirthdayProfile,
        language: AppLanguage,
        context: ModelContext
    ) async -> Bool {
        guard let message = profile.birthdayMessage, !message.isDeleted, message.hasText else { return false }
        guard message.followsDiary else { return false }

        let signature = Self.diarySignature(for: profile)
        guard !signature.isEmpty, signature != message.sourceSignature else { return false }

        // Greetings written before this feature existed have no signature yet: adopt
        // the current one as their baseline instead of rewriting them behind the user.
        guard !message.sourceSignature.isEmpty else {
            message.sourceSignature = signature
            save(context)
            return false
        }

        return await run(
            for: profile,
            language: language,
            tone: message.tone,
            isAutomatic: true,
            context: context
        )
    }

    /// Rewrites the draft on explicit request, keeping the tone already chosen.
    @discardableResult
    func regenerate(
        for profile: BirthdayProfile,
        language: AppLanguage,
        context: ModelContext
    ) async -> Bool {
        await run(
            for: profile,
            language: language,
            tone: profile.birthdayMessage?.tone ?? tone,
            isAutomatic: false,
            context: context
        )
    }

    /// One generation pass: asks the model, then stores the result on the record.
    @discardableResult
    private func run(
        for profile: BirthdayProfile,
        language: AppLanguage,
        tone requestedTone: GreetingTone,
        isAutomatic: Bool,
        context: ModelContext
    ) async -> Bool {
        guard !isGenerating else { return false }

        let voice = requestedTone.resolved(for: profile.occasion)
        let input = GreetingInput(
            name: profile.name,
            occasion: profile.occasion,
            relationship: profile.relationship.rawValue,
            turningAge: profile.countdown.turningAge,
            ageBracket: profile.ageBracket,
            favoriteCharacter: profile.trimmedFavoriteCharacter,
            tagLines: Self.tagLines(for: profile),
            tone: voice,
            bond: profile.bond
        )
        let signature = Self.diarySignature(for: profile)

        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            let text = try await GreetingService.generate(input, language: language)
            guard !profile.isDeleted else { return false }

            let record = record(for: profile, context: context)
            record.text = text
            record.tone = voice
            record.sourceSignature = signature
            record.isUserEdited = false
            record.updatedAt = Date()
            if isAutomatic { record.autoRefreshedAt = Date() }
            save(context)
            return true
        } catch {
            handle(error)
            return false
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

    /// Fingerprint of the diary material a greeting was written from.
    ///
    /// Adding a note, extracting new keywords or deleting a wrong tag all change it,
    /// which is exactly when the draft deserves a rewrite.
    static func diarySignature(for profile: BirthdayProfile) -> String {
        let lines = tagLines(for: profile)
        guard !lines.isEmpty else { return "" }
        return stableDigest(of: lines.joined(separator: "|"))
    }

    /// FNV-1a digest: unlike `hashValue` it stays identical across app launches,
    /// which is what makes the stored signature comparable over time.
    private static func stableDigest(of value: String) -> String {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in Array(value.utf8) {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
        return String(hash, radix: 16)
    }
}
