//
//  WidgetCountdownSnapshot.swift
//  KudaoWidget
//
//  Mirror of the payload the app writes into the App Group container.
//  Kept self-contained: extensions are separate binaries and share no memory
//  with the host app.
//

import Foundation

nonisolated struct WidgetCountdownEntry: Codable, Sendable, Equatable {
    let id: String
    let name: String
    let initials: String
    let birthDate: Date
    let isMasked: Bool
    let relationshipRaw: String
    /// Optional so a snapshot written by an older build still decodes.
    let hidesAge: Bool?

    /// True when the app knows the birth year and an age can be shown.
    var showsAge: Bool { hidesAge != true }
}

nonisolated struct WidgetCountdownSnapshot: Codable, Sendable, Equatable {
    let languageCode: String
    let generatedAt: Date
    let entries: [WidgetCountdownEntry]

    static let empty = WidgetCountdownSnapshot(languageCode: "it", generatedAt: .distantPast, entries: [])
}

/// Reads the snapshot the app publishes. Never throws: an empty snapshot renders
/// the widget's onboarding state.
nonisolated enum WidgetSnapshotReader {
    static let appGroupID = "group.app.rork.ek3qfxdplwz49ny1h3a7x.kudao"
    static let fileName = "widget-countdown.json"

    static func load() -> WidgetCountdownSnapshot {
        guard
            let url = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
                .appendingPathComponent(fileName),
            let data = try? Data(contentsOf: url)
        else { return .empty }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(WidgetCountdownSnapshot.self, from: data)) ?? .empty
    }
}

/// Countdown math recomputed inside the widget, so a stale snapshot still shows
/// the right number of days.
nonisolated struct WidgetCountdown: Sendable, Equatable {
    let nextDate: Date
    let daysRemaining: Int
    let turningAge: Int

    init(birthDate: Date, reference: Date = Date(), calendar: Calendar = .current) {
        let today = calendar.startOfDay(for: reference)
        let birth = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let currentYear = calendar.component(.year, from: today)

        func occurrence(inYear year: Int) -> Date? {
            var components = DateComponents()
            components.year = year
            components.month = birth.month
            components.day = birth.day
            return calendar.date(from: components).map { calendar.startOfDay(for: $0) }
        }

        let thisYear = occurrence(inYear: currentYear)
        let resolved: Date
        if let thisYear, thisYear >= today {
            resolved = thisYear
        } else {
            resolved = occurrence(inYear: currentYear + 1) ?? today
        }

        nextDate = resolved
        daysRemaining = max(0, calendar.dateComponents([.day], from: today, to: resolved).day ?? 0)
        turningAge = max(0, calendar.component(.year, from: resolved) - (birth.year ?? currentYear))
    }

    var isToday: Bool { daysRemaining == 0 }
}
