//
//  ReminderSchedule.swift
//  Kudao
//

import Foundation

/// Where the user's default reminder preferences live.
///
/// The schedule math and the profile form both read these, so changing the
/// defaults in "My profile" moves every future reminder at once.
nonisolated enum ReminderDefaults {
    static let hourKey = "kudao.defaults.reminderHour"
    static let minuteKey = "kudao.defaults.reminderMinute"
    static let daysBeforeKey = "kudao.defaults.reminderDays"
    static let giftDaysBeforeKey = "kudao.defaults.giftReminderDays"

    static let hour: Int = 9
    static let minute: Int = 0
    static let daysBefore: Int = 7
    static let giftDaysBefore: Int = 10

    /// Reads a stored default, falling back to the shipped value.
    static func stored(_ key: String, fallback: Int, range: ClosedRange<Int>) -> Int {
        guard let value = UserDefaults.standard.object(forKey: key) as? Int else { return fallback }
        return min(max(value, range.lowerBound), range.upperBound)
    }
}

/// Calendar math for the local reminder fire dates of a profile.
extension BirthdayProfile {
    /// Hour of the day every reminder fires at, local time.
    static var reminderHour: Int {
        ReminderDefaults.stored(ReminderDefaults.hourKey, fallback: ReminderDefaults.hour, range: 0...23)
    }

    /// Minute of the hour every reminder fires at, local time.
    static var reminderMinute: Int {
        ReminderDefaults.stored(ReminderDefaults.minuteKey, fallback: ReminderDefaults.minute, range: 0...59)
    }

    /// The next fire date for a reminder placed `daysBefore` the birthday.
    ///
    /// If this year's window has already passed, the next year's birthday is used,
    /// so a reminder is always scheduled for a future date.
    func reminderFireDate(
        daysBefore: Int,
        reference: Date = Date(),
        calendar: Calendar = .current
    ) -> Date? {
        let components = calendar.dateComponents([.month, .day], from: birthDate)
        let currentYear = calendar.component(.year, from: reference)

        for offset in 0...2 {
            var target = DateComponents()
            target.year = currentYear + offset
            target.month = components.month
            target.day = components.day

            guard let occurrence = calendar.date(from: target),
                  let shifted = calendar.date(byAdding: .day, value: -max(0, daysBefore), to: occurrence),
                  let fire = calendar.date(
                      bySettingHour: Self.reminderHour,
                      minute: Self.reminderMinute,
                      second: 0,
                      of: shifted
                  ),
                  fire > reference
            else { continue }

            return fire
        }
        return nil
    }

    /// Fire date of the main birthday reminder, when enabled.
    var birthdayReminderDate: Date? {
        guard isReminderEnabled else { return nil }
        return reminderFireDate(daysBefore: reminderDaysBefore)
    }

    /// Fire date of the separate gift reminder, when enabled.
    var giftReminderDate: Date? {
        guard isReminderEnabled, isGiftReminderEnabled else { return nil }
        return reminderFireDate(daysBefore: giftReminderDaysBefore)
    }

    /// "Upload your memories" nudge, the morning after the party.
    ///
    /// It is scheduled on every device that can see the profile, so each
    /// participant gets the reminder without Kudao needing a push server.
    func galleryReminderDate(reference: Date = Date(), calendar: Calendar = .current) -> Date? {
        let components = calendar.dateComponents([.month, .day], from: birthDate)
        let currentYear = calendar.component(.year, from: reference)

        for offset in 0...2 {
            var target = DateComponents()
            target.year = currentYear + offset
            target.month = components.month
            target.day = components.day

            guard let occurrence = calendar.date(from: target),
                  let dayAfter = calendar.date(byAdding: .day, value: 1, to: occurrence),
                  let fire = calendar.date(
                      bySettingHour: Self.reminderHour,
                      minute: Self.reminderMinute,
                      second: 0,
                      of: dayAfter
                  ),
                  fire > reference
            else { continue }

            return fire
        }
        return nil
    }
}
