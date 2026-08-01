//
//  DiaryNudgePlan.swift
//  Kudao
//

import Foundation

/// A person the diary invitation may talk about.
///
/// The three signals below are what the rotation ranks on: they are snapshotted
/// here so the picking logic stays free of SwiftData and can be reasoned about
/// (and tested) on its own.
nonisolated struct DiaryNudgePerson: Sendable, Equatable, Identifiable {
    let id: UUID
    let name: String
    /// Surprise profiles whose name must never appear on the lock screen.
    let isDiscreet: Bool
    /// Keywords already extracted from this diary: the less there is, the more a note is worth.
    let tagCount: Int
    /// Days until the occasion, straight from the countdown.
    let daysUntilEvent: Int
    /// Days since the last note was written here; `neverWritten` when there is none.
    let daysSinceLastNote: Int

    /// Stand-in age for a diary that has never been written in.
    static let neverWritten: Int = 400

    /// How much Kudao has to gain from a note about this person right now.
    ///
    /// The three criteria are weighted rather than applied in strict order: a
    /// pure lexicographic sort would let a profile with 3 keywords outrank one
    /// with 4 even if the second person's birthday is tomorrow. The weights keep
    /// scarcity dominant while still letting urgency decide between profiles
    /// Kudao knows about equally well.
    var priorityScore: Double {
        // Criterion 1 - how little is known. The gap between 0 and 1 keywords is
        // huge and narrows as the diary fills, so an empty profile always wins.
        let scarcity = 100.0 / Double(1 + max(0, tagCount))
        // Criterion 2 - how close the date is, over a one-year horizon.
        let urgency = 10.0 * max(0, 1 - Double(max(0, daysUntilEvent)) / 365.0)
        // Criterion 3 - how long this diary has been silent, capped at three
        // months so neglect alone can never outrank an imminent date.
        let staleness = min(Double(max(0, daysSinceLastNote)), 90.0) / 90.0
        return scarcity + urgency + staleness
    }
}

/// Everything needed to schedule the diary invitations, snapshotted off the models.
///
/// Remembrances are deliberately absent: nudging somebody every three days to
/// write about a person they lost is not a tone Kudao wants to take.
nonisolated struct DiaryNudgePlan: Sendable, Equatable {
    let isEnabled: Bool
    let cadence: DiaryReminderCadence
    let hour: Int
    let minute: Int
    let people: [DiaryNudgePerson]

    static let off = DiaryNudgePlan(
        isEnabled: false,
        cadence: .never,
        hour: DiaryReminderCadence.defaultHour,
        minute: 0,
        people: []
    )

    /// True when invitations should actually be put on the calendar.
    var isActive: Bool {
        isEnabled && cadence.isActive && !people.isEmpty
    }

    /// People whose name can be printed in a notification.
    var namablePeople: [DiaryNudgePerson] {
        people.filter { !$0.isDiscreet }
    }

    /// Age of the most recent note, used to surface diaries that went quiet.
    @MainActor
    private static func daysSinceLastNote(
        in profile: BirthdayProfile,
        reference: Date,
        calendar: Calendar
    ) -> Int {
        guard let latest = profile.diaryEntries.map(\.createdAt).max() else {
            return DiaryNudgePerson.neverWritten
        }
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: latest),
            to: calendar.startOfDay(for: reference)
        ).day ?? 0
        return max(0, days)
    }

    /// Builds the plan from the live settings and profiles.
    @MainActor
    static func make(
        settings: AppSettings,
        profiles: [BirthdayProfile],
        reference: Date = Date()
    ) -> DiaryNudgePlan {
        let calendar = Calendar.current
        let people = profiles
            .filter(\.wantsDiaryNudges)
            .map { profile in
                DiaryNudgePerson(
                    id: profile.id,
                    name: profile.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    isDiscreet: settings.masksIdentity(of: profile),
                    tagCount: profile.diaryTags.count,
                    daysUntilEvent: profile.countdown.daysRemaining,
                    daysSinceLastNote: Self.daysSinceLastNote(
                        in: profile,
                        reference: reference,
                        calendar: calendar
                    )
                )
            }
            .filter { !$0.name.isEmpty }

        return DiaryNudgePlan(
            isEnabled: settings.wantsDiaryReminders,
            cadence: settings.diaryReminderCadence,
            hour: settings.diaryReminderHour,
            minute: settings.diaryReminderMinute,
            people: people
        )
    }

    /// The next moments an invitation would arrive, starting from `reference`.
    func upcomingDates(from reference: Date = Date(), limit: Int = 6) -> [Date] {
        guard isActive, let interval = cadence.intervalDays else { return [] }

        let calendar = Calendar.current
        guard let todaySlot = calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: reference
        ) else { return [] }

        // Today still counts when the hour has not passed yet.
        var next = todaySlot > reference.addingTimeInterval(60)
            ? todaySlot
            : calendar.date(byAdding: .day, value: interval, to: todaySlot) ?? todaySlot

        var dates: [Date] = []
        for _ in 0..<limit {
            dates.append(next)
            guard let following = calendar.date(byAdding: .day, value: interval, to: next) else { break }
            next = following
        }
        return dates
    }
}
