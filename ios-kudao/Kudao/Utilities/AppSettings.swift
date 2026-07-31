//
//  AppSettings.swift
//  Kudao
//

import Foundation
import Observation

/// Holds the active language, the app-wide privacy switches and the matching string table.
@Observable
final class AppSettings {
    private static let languageKey = "kudao.language"
    private static let biometricLockKey = "kudao.surprise.biometricLock"
    private static let hidePreviewsKey = "kudao.surprise.hideNotificationPreviews"
    private static let gallerySortKey = "kudao.gallery.sortOrder"

    var language: AppLanguage {
        didSet {
            guard language != oldValue else { return }
            UserDefaults.standard.set(language.rawValue, forKey: Self.languageKey)
        }
    }

    /// Requires biometrics (or the device passcode) before any surprise profile opens.
    var protectsSurpriseProfiles: Bool {
        didSet {
            guard protectsSurpriseProfiles != oldValue else { return }
            UserDefaults.standard.set(protectsSurpriseProfiles, forKey: Self.biometricLockKey)
            KudaoSharedStore.set(protectsSurpriseProfiles, forKey: Self.biometricLockKey)
        }
    }

    /// Replaces the reminder name with a neutral "Kudao reminder" wording for surprise profiles.
    var hidesSurpriseNotificationPreviews: Bool {
        didSet {
            guard hidesSurpriseNotificationPreviews != oldValue else { return }
            UserDefaults.standard.set(hidesSurpriseNotificationPreviews, forKey: Self.hidePreviewsKey)
            KudaoSharedStore.set(hidesSurpriseNotificationPreviews, forKey: Self.hidePreviewsKey)
        }
    }

    /// Chronological order of every party gallery, remembered between launches.
    var gallerySortOrder: GallerySortOrder {
        didSet {
            guard gallerySortOrder != oldValue else { return }
            UserDefaults.standard.set(gallerySortOrder.rawValue, forKey: Self.gallerySortKey)
        }
    }

    /// Lead time of the main reminder, one value per category of occasion.
    ///
    /// Kept as a dictionary keyed by the occasion raw value so the whole set is a
    /// single observable property: a stepper in the notification settings redraws
    /// every dependent label at once.
    private var reminderDaysByOccasion: [String: Int]

    /// Lead time of the separate gift nudge, one value per category of occasion.
    private var giftDaysByOccasion: [String: Int]

    /// Time of day every reminder fires at, local time.
    var reminderTime: Date {
        didSet {
            let parts = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            let hour = parts.hour ?? ReminderDefaults.hour
            let minute = parts.minute ?? ReminderDefaults.minute
            guard hour != Calendar.current.component(.hour, from: oldValue)
                || minute != Calendar.current.component(.minute, from: oldValue) else { return }
            UserDefaults.standard.set(hour, forKey: ReminderDefaults.hourKey)
            UserDefaults.standard.set(minute, forKey: ReminderDefaults.minuteKey)
        }
    }

    init() {
        let defaults = UserDefaults.standard
        if let stored = defaults.string(forKey: Self.languageKey),
           let saved = AppLanguage(rawValue: stored) {
            language = saved
        } else {
            language = AppLanguage.detectedFromDevice()
        }

        gallerySortOrder = GallerySortOrder.parse(defaults.string(forKey: Self.gallerySortKey))
        reminderDaysByOccasion = Dictionary(
            uniqueKeysWithValues: OccasionKind.allCases.map {
                ($0.rawValue, ReminderDefaults.daysBefore(for: $0))
            }
        )
        giftDaysByOccasion = Dictionary(
            uniqueKeysWithValues: OccasionKind.allCases.map {
                ($0.rawValue, ReminderDefaults.giftDaysBefore(for: $0))
            }
        )
        reminderTime = Calendar.current.date(
            bySettingHour: BirthdayProfile.reminderHour,
            minute: BirthdayProfile.reminderMinute,
            second: 0,
            of: Date()
        ) ?? Date()

        protectsSurpriseProfiles = defaults.bool(forKey: Self.biometricLockKey)
        // Surprises stay private by default.
        hidesSurpriseNotificationPreviews = defaults.object(forKey: Self.hidePreviewsKey) as? Bool ?? true
    }

    // MARK: - Reminder defaults

    /// How many days before the date a new profile of this occasion is announced.
    func reminderDays(for occasion: OccasionKind) -> Int {
        reminderDaysByOccasion[occasion.rawValue] ?? ReminderDefaults.shippedDaysBefore(occasion)
    }

    func setReminderDays(_ value: Int, for occasion: OccasionKind) {
        let clamped = min(max(value, ReminderDefaults.daysRange.lowerBound), ReminderDefaults.daysRange.upperBound)
        guard reminderDaysByOccasion[occasion.rawValue] != clamped else { return }
        reminderDaysByOccasion[occasion.rawValue] = clamped
        UserDefaults.standard.set(clamped, forKey: ReminderDefaults.daysBeforeKey(occasion))
    }

    /// How many days before the date the gift nudge fires for this occasion.
    func giftReminderDays(for occasion: OccasionKind) -> Int {
        giftDaysByOccasion[occasion.rawValue] ?? ReminderDefaults.shippedGiftDaysBefore(occasion)
    }

    func setGiftReminderDays(_ value: Int, for occasion: OccasionKind) {
        let clamped = min(
            max(value, ReminderDefaults.giftDaysRange.lowerBound),
            ReminderDefaults.giftDaysRange.upperBound
        )
        guard giftDaysByOccasion[occasion.rawValue] != clamped else { return }
        giftDaysByOccasion[occasion.rawValue] = clamped
        UserDefaults.standard.set(clamped, forKey: ReminderDefaults.giftDaysBeforeKey(occasion))
    }

    /// Puts a category back to the value Kudao ships with.
    func resetReminderDefaults(for occasion: OccasionKind) {
        setReminderDays(ReminderDefaults.shippedDaysBefore(occasion), for: occasion)
        setGiftReminderDays(ReminderDefaults.shippedGiftDaysBefore(occasion), for: occasion)
    }

    /// True when a category no longer matches the shipped lead times.
    func hasCustomReminderDefaults(for occasion: OccasionKind) -> Bool {
        reminderDays(for: occasion) != ReminderDefaults.shippedDaysBefore(occasion)
            || (occasion.wantsSuggestions
                && giftReminderDays(for: occasion) != ReminderDefaults.shippedGiftDaysBefore(occasion))
    }

    /// True when a profile's details must be unlocked before being shown.
    func requiresUnlock(_ profile: BirthdayProfile) -> Bool {
        protectsSurpriseProfiles && profile.isSurpriseMode
    }

    /// True when the person's name must never leave the app unmasked.
    func masksIdentity(of profile: BirthdayProfile) -> Bool {
        profile.isSurpriseMode && (protectsSurpriseProfiles || hidesSurpriseNotificationPreviews)
    }

    var strings: Strings { language.strings }
    var locale: Locale { language.locale }

    /// "09:00" style label of the reminder time, in the selected language.
    var reminderTimeLabel: String {
        reminderTime.formatted(
            Date.FormatStyle(locale: locale)
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.twoDigits)
        )
    }

    /// Localized "3 giugno" style date, following the selected language.
    func dayMonth(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(locale: locale)
                .day(.defaultDigits)
                .month(.wide)
        )
    }

    func dayMonthYear(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(locale: locale)
                .day(.defaultDigits)
                .month(.wide)
                .year()
        )
    }

    /// "Oggi, 14:32" / "Ieri, 09:05" / "3 giugno, 18:20" depending on how recent the date is.
    func noteTimestamp(_ date: Date) -> String {
        let time = date.formatted(
            Date.FormatStyle(locale: locale)
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.twoDigits)
        )
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "\(strings.todayLabel), \(time)" }
        if calendar.isDateInYesterday(date) { return "\(strings.yesterdayLabel), \(time)" }
        return "\(dayMonth(date)), \(time)"
    }

    func weekdayDayMonth(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(locale: locale)
                .weekday(.wide)
                .day(.defaultDigits)
                .month(.wide)
        )
    }
}
