//
//  SuggestionEngine.swift
//  Kudao
//

import Foundation
import Observation
import OSLog
import SwiftData

/// Drives the party-plan generation for one profile screen.
/// Failures never destroy the current plan: they only surface a message.
@Observable
final class SuggestionEngine {
    private let logger = Logger(subsystem: "com.kudao.app", category: "suggestion-engine")

    private(set) var isGeneratingPlan: Bool = false
    private(set) var regeneratingSections: Set<PlanSection> = []
    private(set) var errorMessage: String?
    /// Guards the automatic first generation so it runs once per screen.
    private(set) var hasAttemptedAutoGeneration: Bool = false

    var isBusy: Bool { isGeneratingPlan || !regeneratingSections.isEmpty }

    func isRegenerating(_ section: PlanSection) -> Bool {
        regeneratingSections.contains(section)
    }

    func clearError() {
        errorMessage = nil
    }

    func markAutoGenerationAttempted() {
        hasAttemptedAutoGeneration = true
    }

    // MARK: - Generation

    /// Builds (or replaces) the whole plan for a profile.
    func generatePlan(for profile: BirthdayProfile, language: AppLanguage, context: ModelContext) {
        guard !isGeneratingPlan else { return }
        let input = Self.makeInput(for: profile)
        guard input.keywordCount > 0 else { return }

        isGeneratingPlan = true
        errorMessage = nil
        hasAttemptedAutoGeneration = true

        Task { [weak self] in
            defer { self?.isGeneratingPlan = false }
            do {
                let suggestion = try await SuggestionService.generatePlan(input, language: language)
                guard let self, !profile.isDeleted else { return }
                self.store(suggestion, keywordCount: input.keywordCount, on: profile, context: context)
            } catch {
                self?.handle(error)
            }
        }
    }

    /// Refreshes a single card, keeping the rest of the plan untouched.
    func regenerate(
        section: PlanSection,
        for profile: BirthdayProfile,
        language: AppLanguage,
        context: ModelContext
    ) {
        guard let plan = profile.partyPlan, !regeneratingSections.contains(section) else { return }
        let input = Self.makeInput(for: profile)
        let current = plan.suggestion

        regeneratingSections.insert(section)
        errorMessage = nil

        Task { [weak self] in
            defer { self?.regeneratingSections.remove(section) }
            do {
                let updated = try await SuggestionService.regenerate(
                    section: section,
                    current: current,
                    input: input,
                    language: language
                )
                guard let self, !profile.isDeleted, let plan = profile.partyPlan, !plan.isDeleted else { return }
                plan.apply(updated)
                plan.sourceKeywordCount = input.keywordCount
                self.save(context)
            } catch {
                self?.handle(error)
            }
        }
    }

    // MARK: - Persistence

    /// Applies a manual edit made by the user; the plan needs confirming again.
    func applyManualEdit(
        _ suggestion: PartySuggestion,
        to profile: BirthdayProfile,
        context: ModelContext
    ) {
        guard let plan = profile.partyPlan else { return }
        plan.apply(suggestion)
        plan.isManuallyEdited = true
        save(context)
    }

    /// Freezes the current plan as the definitive one.
    func confirmPlan(for profile: BirthdayProfile, context: ModelContext) {
        guard let plan = profile.partyPlan else { return }
        plan.confirmedAt = Date()
        save(context)
    }

    private func store(
        _ suggestion: PartySuggestion,
        keywordCount: Int,
        on profile: BirthdayProfile,
        context: ModelContext
    ) {
        if let existing = profile.partyPlan {
            existing.apply(suggestion)
            existing.sourceKeywordCount = keywordCount
            existing.isManuallyEdited = false
            existing.generatedAt = Date()
        } else {
            let plan = PartyPlan(suggestion: suggestion, keywordCount: keywordCount, profile: profile)
            context.insert(plan)
            profile.partyPlan = plan
        }
        save(context)
    }

    private func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            logger.error("Saving the party plan failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func handle(_ error: Error) {
        logger.error("Suggestion request failed: \(error.localizedDescription, privacy: .public)")
        if let proxyError = error as? ProxyError {
            errorMessage = proxyError.errorDescription
        } else {
            errorMessage = ProxyError.serverError(0).errorDescription
        }
    }

    // MARK: - Input building

    /// Collapses the diary tags into the compact context the model receives.
    static func makeInput(for profile: BirthdayProfile) -> SuggestionInput {
        let tags = profile.diaryTags.sorted { $0.createdAt > $1.createdAt }
        var buckets: [DiaryCategory: [String]] = [:]

        for tag in tags {
            for keyword in tag.keywords {
                let cleaned = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !cleaned.isEmpty else { continue }
                var existing = buckets[tag.category] ?? []
                if !existing.contains(where: { $0.localizedCaseInsensitiveCompare(cleaned) == .orderedSame }) {
                    existing.append(cleaned)
                    buckets[tag.category] = existing
                }
            }
        }

        let tagLines = DiaryCategory.allCases.compactMap { category -> String? in
            guard let keywords = buckets[category], !keywords.isEmpty else { return nil }
            return "\(category.rawValue): \(keywords.joined(separator: ", "))"
        }

        let giftLeads = tags
            .filter { $0.isGiftRelevant && !$0.summary.isEmpty }
            .prefix(8)
            .map(\.summary)

        return SuggestionInput(
            name: profile.name,
            relationship: profile.relationship.rawValue,
            age: profile.countdown.turningAge,
            tagLines: tagLines,
            giftLeads: Array(giftLeads),
            keywordCount: buckets.values.reduce(0) { $0 + $1.count }
        )
    }

    /// Distinct keyword count used for the confidence badge and the low-data banner.
    static func keywordCount(for profile: BirthdayProfile) -> Int {
        makeInput(for: profile).keywordCount
    }
}
