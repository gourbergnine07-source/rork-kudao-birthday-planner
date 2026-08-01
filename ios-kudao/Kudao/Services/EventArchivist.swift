//
//  EventArchivist.swift
//  Kudao
//

import Foundation
import OSLog
import SwiftData

/// Closes a cycle once its date has gone by, and opens the next one.
///
/// Kudao is built around a date that comes back every year. When it passes, the
/// profile must not disappear and must not stay frozen on last year's plan:
/// the cycle is snapshotted into an `EventRecord`, the countdown rolls over on
/// its own (it is derived from the date), and the plan is handed back unconfirmed
/// so the next round can be prepared from scratch — with the whole diary history
/// behind it, not just the last twelve months.
@MainActor
enum EventArchivist {
    private static let logger = Logger(subsystem: "com.kudao.app", category: "archive")

    /// Photos of a party keep arriving for days, so a fresh record stays open to updates.
    private static let mediaWindowDays = BirthdayProfile.galleryWindowDays

    /// Archives every cycle that has ended and refreshes the ones still collecting media.
    ///
    /// Safe to call as often as the app likes: a cycle is archived once, keyed on
    /// the profile and the year of the event.
    @discardableResult
    static func sync(
        profiles: [BirthdayProfile],
        records: [EventRecord],
        context: ModelContext,
        reference: Date = Date()
    ) -> Int {
        let calendar = Calendar.current
        var archived = 0

        for profile in profiles where !profile.isDeleted {
            guard let cycle = closedCycle(for: profile, reference: reference, calendar: calendar) else {
                continue
            }

            // The owner deleted this year from the library on purpose; rebuilding
            // it would quietly undo that.
            guard !profile.removedArchiveYears.contains(cycle.year) else { continue }

            if let existing = records.first(where: { $0.profileID == profile.id && $0.year == cycle.year }) {
                // The party is over but the memories are not in yet: keep the media fresh.
                guard existing.isMediaWindowOpen(reference: reference) else { continue }
                captureMedia(into: existing, from: profile, cycle: cycle, calendar: calendar)
                continue
            }

            let record = makeRecord(for: profile, cycle: cycle, calendar: calendar)
            context.insert(record)
            startNextCycle(for: profile, context: context)
            archived += 1
        }

        guard archived > 0 else { return 0 }

        do {
            try context.save()
        } catch {
            logger.error("Archiving a cycle failed: \(error.localizedDescription, privacy: .public)")
        }
        return archived
    }

    // MARK: - Cycle boundaries

    /// The window one archived cycle covers: from the previous occurrence to this one.
    private struct Cycle {
        let year: Int
        let eventDate: Date
        let start: Date
    }

    /// The most recent occurrence, when it is genuinely over and the profile lived through it.
    private static func closedCycle(
        for profile: BirthdayProfile,
        reference: Date,
        calendar: Calendar
    ) -> Cycle? {
        let countdown = BirthdayCountdown(birthDate: profile.referenceDate, reference: reference, calendar: calendar)
        // The day itself still belongs to the current cycle.
        guard countdown.daysSinceLast >= 1 else { return nil }

        let eventDate = countdown.lastDate
        let created = calendar.startOfDay(for: profile.createdAt)
        // Nothing to archive for a date that went by before the profile existed.
        guard eventDate >= created else { return nil }

        let previous = calendar.date(byAdding: .year, value: -1, to: eventDate) ?? eventDate
        return Cycle(
            year: calendar.component(.year, from: eventDate),
            eventDate: eventDate,
            start: max(previous, created)
        )
    }

    // MARK: - Snapshot

    private static func makeRecord(
        for profile: BirthdayProfile,
        cycle: Cycle,
        calendar: Calendar
    ) -> EventRecord {
        let record = EventRecord(
            profileID: profile.id,
            year: cycle.year,
            eventDate: cycle.eventDate,
            occasion: profile.occasion,
            profileName: profile.fullName,
            profile: profile
        )

        if let plan = profile.partyPlan {
            record.planJSON = ArchivedPlan(plan: plan).json
        }

        if let message = profile.birthdayMessage {
            record.messageText = message.trimmedText
            record.wasMessageSent = message.isSent
        }

        captureDiary(into: record, from: profile, cycle: cycle)
        captureMedia(into: record, from: profile, cycle: cycle, calendar: calendar)
        return record
    }

    /// Notes and thoughts written during the cycle, newest first.
    ///
    /// For a remembrance this is the heart of the record: the memories shared
    /// that year are the only thing the library has to show.
    private static func captureDiary(into record: EventRecord, from profile: BirthdayProfile, cycle: Cycle) {
        let entries = profile.diaryEntries
            .filter { $0.createdAt >= cycle.start && $0.createdAt <= endOfDay(cycle.eventDate) }
            .sorted { $0.createdAt > $1.createdAt }

        record.noteCount = entries.count
        record.memoryHighlights = entries.prefix(12).map { entry in
            let summary = entry.extraction?.summary.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard summary.isEmpty else { return summary }
            return shortened(entry.textContent)
        }

        let tags = profile.diaryTags.filter { $0.createdAt <= endOfDay(cycle.eventDate) }
        var seen: Set<String> = []
        var keywords: [String] = []
        for keyword in tags.flatMap(\.keywords) {
            let cleaned = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleaned.isEmpty, seen.insert(cleaned.lowercased()).inserted else { continue }
            keywords.append(cleaned)
        }
        record.keywords = Array(keywords.prefix(24))
    }

    /// Photos and videos taken around the event, plus the cover of the record.
    private static func captureMedia(
        into record: EventRecord,
        from profile: BirthdayProfile,
        cycle: Cycle,
        calendar: Calendar
    ) {
        let opens = calendar.date(byAdding: .day, value: -3, to: cycle.eventDate) ?? cycle.eventDate
        let closes = calendar.date(byAdding: .day, value: mediaWindowDays, to: cycle.eventDate) ?? cycle.eventDate
        let items = profile.galleryItems
            .filter { $0.createdAt >= opens && $0.createdAt <= endOfDay(closes) }
            .sorted { $0.createdAt < $1.createdAt }

        record.galleryItemIDs = items.map(\.id)
        record.photoCount = items.filter { !$0.isVideo }.count
        record.videoCount = items.filter(\.isVideo).count
        record.coverData = items.first(where: { !$0.isVideo && $0.thumbnailData != nil })?.thumbnailData
            ?? items.first(where: { $0.thumbnailData != nil })?.thumbnailData
            ?? profile.photoData
        record.updatedAt = Date()
    }

    // MARK: - Deletion

    /// Removes an archived cycle for good, leaving the live profile untouched.
    ///
    /// Only the snapshot goes: the diary notes it summarised, the gallery items it
    /// pointed at and the profile itself all stay. A tombstone is recorded so the
    /// next `sync` does not archive that year all over again.
    static func delete(_ record: EventRecord, context: ModelContext) {
        if let profile = record.profile, !profile.removedArchiveYears.contains(record.year) {
            profile.removedArchiveYears.append(record.year)
        }
        context.delete(record)

        do {
            try context.save()
        } catch {
            logger.error("Deleting an archived cycle failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Drops a single memory from an archived cycle.
    ///
    /// `noteCount` is decremented alongside so the "12 notes written that year"
    /// line cannot end up claiming more than the record can show.
    static func removeMemory(at index: Int, from record: EventRecord, context: ModelContext) {
        guard record.memoryHighlights.indices.contains(index) else { return }
        record.memoryHighlights.remove(at: index)
        record.noteCount = max(0, record.noteCount - 1)
        record.updatedAt = Date()

        do {
            try context.save()
        } catch {
            logger.error("Deleting an archived memory failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Restart

    /// Hands the profile to its next cycle without touching a single memory.
    ///
    /// The diary, the tags and the gallery all stay: they are what makes next
    /// year's suggestions better. Only the things that were about *this* event
    /// are released — the confirmed plan and the greeting that was already sent.
    private static func startNextCycle(for profile: BirthdayProfile, context: ModelContext) {
        if let plan = profile.partyPlan {
            // The plan is preserved in the record; the new cycle starts unconfirmed
            // so the engine can rebuild it from the full history.
            profile.partyPlan = nil
            context.delete(plan)
        }

        if let message = profile.birthdayMessage {
            message.markSent(false)
            message.isUserEdited = false
            message.isAutoRefreshEnabled = true
            // Forget the fingerprint so the diary rewrites the draft for the new year.
            message.sourceSignature = ""
            message.autoRefreshedAt = nil
            message.scheduledAt = BirthdayMessage.defaultSendDate(for: profile)
            message.updatedAt = Date()
        }
    }

    // MARK: - Helpers

    private static func endOfDay(_ date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date)) ?? date
    }

    /// First line of a note, trimmed to a length the library can show.
    private static func shortened(_ text: String) -> String {
        let flattened = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard flattened.count > 90 else { return flattened }
        return String(flattened.prefix(90)) + "\u{2026}"
    }
}

extension ArchivedPlan {
    /// Value copy of a live plan, taken the moment its cycle closes.
    @MainActor
    init(plan: PartyPlan) {
        self.init(
            giftIdea: plan.giftIdea,
            giftCategory: plan.giftCategory,
            giftPriceRaw: plan.giftPriceRaw,
            giftReason: plan.giftReason,
            cakeType: plan.cakeType,
            cakeReason: plan.cakeReason,
            venueIdea: plan.venueIdea,
            venueReason: plan.venueReason,
            guestCount: plan.guestCount,
            confidenceRaw: plan.confidenceRaw,
            wasConfirmed: plan.isConfirmed,
            confirmedAt: plan.confirmedAt,
            generatedAt: plan.generatedAt
        )
    }
}
