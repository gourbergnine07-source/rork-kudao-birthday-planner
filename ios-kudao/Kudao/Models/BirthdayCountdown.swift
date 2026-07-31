//
//  BirthdayCountdown.swift
//  Kudao
//

import Foundation

/// Calendar math for the next occurrence of a birthday.
nonisolated struct BirthdayCountdown: Sendable, Equatable {
    let nextDate: Date
    let daysRemaining: Int
    let turningAge: Int

    init(birthDate: Date, reference: Date = Date(), calendar: Calendar = .current) {
        let today = calendar.startOfDay(for: reference)
        let birthComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let currentYear = calendar.component(.year, from: today)

        func occurrence(inYear year: Int) -> Date? {
            var components = DateComponents()
            components.year = year
            components.month = birthComponents.month
            components.day = birthComponents.day
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

        let birthYear = birthComponents.year ?? currentYear
        let occurrenceYear = calendar.component(.year, from: resolved)
        turningAge = max(0, occurrenceYear - birthYear)
    }

    var isToday: Bool { daysRemaining == 0 }
    var isTomorrow: Bool { daysRemaining == 1 }

    /// 0 right after the birthday, approaching 1 as the next one gets closer.
    var yearProgress: Double {
        let clamped = min(Double(daysRemaining), 365)
        return 1 - (clamped / 365)
    }
}
