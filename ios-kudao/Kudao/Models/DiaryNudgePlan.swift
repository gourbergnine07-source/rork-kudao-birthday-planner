//
//  DiaryNudgePlan.swift
//  Kudao
//

import Foundation

/// A person the diary invitation may talk about.
nonisolated struct DiaryNudgePerson: Sendable, Equatable, Identifiable {
    let id: UUID
    let name: String
    /// Surprise profiles whose name must never appear on the lock screen.
    let isDiscreet: Bool
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

    /// Builds the plan from the live settings and profiles.
    @MainActor
    static func make(settings: AppSettings, profiles: [BirthdayProfile]) -> DiaryNudgePlan {
        let people = profiles
            .filter(\.wantsDiaryNudges)
            .map {
                DiaryNudgePerson(
                    id: $0.id,
                    name: $0.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    isDiscreet: settings.masksIdentity(of: $0)
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
