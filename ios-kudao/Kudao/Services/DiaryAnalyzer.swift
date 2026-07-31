//
//  DiaryAnalyzer.swift
//  Kudao
//

import Foundation
import Observation
import OSLog
import SwiftData

/// Runs the AI extraction for diary notes in the background.
/// A failure never blocks the user: the note stays saved, only the tags are missing.
@Observable
final class DiaryAnalyzer {
    private let logger = Logger(subsystem: "com.kudao.app", category: "diary-analyzer")

    /// Entry ids with an extraction currently in flight.
    private(set) var runningEntryIDs: Set<UUID> = []

    func isRunning(_ entry: DiaryEntry) -> Bool {
        runningEntryIDs.contains(entry.id)
    }

    /// Fire-and-forget extraction. Safe to call again to retry a failed note.
    func analyze(
        entry: DiaryEntry,
        profile: BirthdayProfile,
        language: AppLanguage,
        context: ModelContext
    ) {
        let entryID = entry.id
        guard !runningEntryIDs.contains(entryID) else { return }

        let note = entry.textContent
        let personName = profile.name
        let occasion = profile.occasion
        guard !note.isEmpty else { return }

        runningEntryIDs.insert(entryID)
        entry.extractionStatus = .pending

        Task { [weak self] in
            defer { self?.runningEntryIDs.remove(entryID) }
            do {
                let extraction = try await DiaryExtractionService.extract(
                    note: note,
                    personName: personName,
                    language: language,
                    occasion: occasion
                )
                self?.apply(extraction, to: entry, profile: profile, context: context)
            } catch {
                self?.logger.error("Diary extraction failed: \(error.localizedDescription, privacy: .public)")
                guard !entry.isDeleted else { return }
                entry.extractionStatus = .failed
                try? context.save()
            }
        }
    }

    private func apply(
        _ extraction: DiaryExtraction,
        to entry: DiaryEntry,
        profile: BirthdayProfile,
        context: ModelContext
    ) {
        guard !entry.isDeleted, !profile.isDeleted else { return }

        if let existing = entry.extraction {
            context.delete(existing)
        }

        let tag = DiaryTag(
            category: extraction.category,
            keywords: extraction.keywords,
            isGiftRelevant: extraction.isGiftRelevant,
            summary: extraction.summary,
            entry: entry,
            profile: profile
        )
        context.insert(tag)
        entry.extraction = tag
        entry.extractionStatus = .ready
        try? context.save()
    }
}
