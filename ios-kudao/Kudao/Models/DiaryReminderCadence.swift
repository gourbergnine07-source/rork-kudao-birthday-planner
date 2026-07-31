//
//  DiaryReminderCadence.swift
//  Kudao
//

import Foundation

/// How often Kudao invites the user to write something in a diary.
///
/// A profile is only as good as what has been noted in it, and most details
/// surface far from the date itself — so Kudao asks on a rhythm the user picks,
/// never more than once a day.
nonisolated enum DiaryReminderCadence: String, CaseIterable, Identifiable, Sendable {
    case daily
    case everyThreeDays
    case weekly
    case never

    var id: String { rawValue }

    /// Hour the invitation arrives at unless the user moves it.
    static let defaultHour: Int = 20

    /// Days between two invitations; nil when the user chose to be left alone.
    var intervalDays: Int? {
        switch self {
        case .daily: 1
        case .everyThreeDays: 3
        case .weekly: 7
        case .never: nil
        }
    }

    var isActive: Bool { self != .never }

    var symbolName: String {
        switch self {
        case .daily: "sun.max.fill"
        case .everyThreeDays: "calendar.badge.clock"
        case .weekly: "calendar"
        case .never: "bell.slash.fill"
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .daily: strings.diaryCadenceDaily
        case .everyThreeDays: strings.diaryCadenceEveryThreeDays
        case .weekly: strings.diaryCadenceWeekly
        case .never: strings.diaryCadenceNever
        }
    }

    /// Every-three-days is the middle ground Kudao ships with.
    static func parse(_ raw: String?) -> DiaryReminderCadence {
        DiaryReminderCadence(rawValue: raw ?? "") ?? .everyThreeDays
    }
}
