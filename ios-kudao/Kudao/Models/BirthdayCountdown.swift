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
    /// Most recent occurrence of the birthday: today when it is the birthday itself.
    let lastDate: Date
    /// Days elapsed since that occurrence, so features can react to a party that just happened.
    let daysSinceLast: Int

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

        let previous: Date = {
            if let thisYear, thisYear <= today { return thisYear }
            return occurrence(inYear: currentYear - 1) ?? today
        }()
        lastDate = previous
        daysSinceLast = max(0, calendar.dateComponents([.day], from: previous, to: today).day ?? 0)

        let birthYear = birthComponents.year ?? currentYear
        let occurrenceYear = calendar.component(.year, from: resolved)
        turningAge = max(0, occurrenceYear - birthYear)
    }

    var isToday: Bool { daysRemaining == 0 }
    var isTomorrow: Bool { daysRemaining == 1 }

    /// True when the birthday happens today or within the next seven days.
    var isThisWeek: Bool { daysRemaining <= 7 }

    /// Short human label for the imminent badge: "Today", "Tomorrow" or "In N days".
    func imminentLabel(_ strings: Strings) -> String {
        if isToday { return strings.todayLabel }
        if isTomorrow { return strings.tomorrowLabel }
        return String(format: strings.imminentDaysFormat, daysRemaining)
    }

    /// 0 right after the birthday, approaching 1 as the next one gets closer.
    var yearProgress: Double {
        let clamped = min(Double(daysRemaining), 365)
        return 1 - (clamped / 365)
    }
}
