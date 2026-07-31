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

    /// How early each kind of occasion is announced out of the box.
    ///
    /// A remembrance lands on the morning of the day itself, which is how Kudao
    /// has always behaved; the others get a week (a birthday, an anniversary) or
    /// three days (a generic event) of warning.
    static func shippedDaysBefore(_ occasion: OccasionKind) -> Int {
        switch occasion {
        case .birthday: 7
        case .wedding: 7
        case .remembrance: 0
        case .other: 3
        }
    }

    /// How early the separate "buy the present" nudge fires, per occasion.
    static func shippedGiftDaysBefore(_ occasion: OccasionKind) -> Int {
        switch occasion {
        case .birthday: 10
        case .wedding: 14
        case .remembrance: 0
        case .other: 7
        }
    }

    /// Range the main lead time can be dragged through. Zero means "on the day".
    static let daysRange: ClosedRange<Int> = 0...60
    static let giftDaysRange: ClosedRange<Int> = 1...120

    static func daysBeforeKey(_ occasion: OccasionKind) -> String {
        "\(daysBeforeKey).\(occasion.rawValue)"
    }

    static func giftDaysBeforeKey(_ occasion: OccasionKind) -> String {
        "\(giftDaysBeforeKey).\(occasion.rawValue)"
    }

    /// Lead time chosen for an occasion, falling back to the legacy global value.
    ///
    /// The pre-occasion builds stored a single number; reading it as the birthday
    /// fallback means an upgrade keeps the user's own choice instead of resetting it.
    static func daysBefore(for occasion: OccasionKind) -> Int {
        let legacy = occasion == .birthday
            ? stored(daysBeforeKey, fallback: shippedDaysBefore(occasion), range: daysRange)
            : shippedDaysBefore(occasion)
        return stored(daysBeforeKey(occasion), fallback: legacy, range: daysRange)
    }

    static func giftDaysBefore(for occasion: OccasionKind) -> Int {
        let legacy = occasion == .birthday
            ? stored(giftDaysBeforeKey, fallback: shippedGiftDaysBefore(occasion), range: giftDaysRange)
            : shippedGiftDaysBefore(occasion)
        return stored(giftDaysBeforeKey(occasion), fallback: legacy, range: giftDaysRange)
    }

    private static let leadTimeMigrationKey = "kudao.migration.occasionLeadTimes"

    /// Keeps remembrance profiles firing on the day, as they did before lead
    /// times became per-occasion.
    ///
    /// Until now the schedule ignored the stored number for a remembrance and
    /// always used zero; writing that zero into the profiles preserves exactly
    /// what those users were already getting. Runs once.
    @MainActor
    static func migrateLeadTimes(_ profiles: [BirthdayProfile]) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: leadTimeMigrationKey) else { return }
        defaults.set(true, forKey: leadTimeMigrationKey)

        for profile in profiles where profile.occasion == .remembrance {
            profile.reminderDaysBefore = 0
        }
    }

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

    /// Fire date of the main reminder, when enabled.
    ///
    /// The lead time is the profile's own, which starts life as the default the
    /// user picked for that category of occasion in the notification settings.
    var birthdayReminderDate: Date? {
        guard isReminderEnabled else { return nil }
        return reminderFireDate(daysBefore: max(0, reminderDaysBefore))
    }

    /// Fire date of the separate gift reminder, when enabled.
    ///
    /// Only occasions that actually involve a present get one.
    var giftReminderDate: Date? {
        guard isReminderEnabled, isGiftReminderEnabled, occasion.wantsSuggestions else { return nil }
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
