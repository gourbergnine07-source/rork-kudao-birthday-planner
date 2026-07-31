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

    init() {
        let defaults = UserDefaults.standard
        if let stored = defaults.string(forKey: Self.languageKey),
           let saved = AppLanguage(rawValue: stored) {
            language = saved
        } else {
            language = AppLanguage.detectedFromDevice()
        }

        protectsSurpriseProfiles = defaults.bool(forKey: Self.biometricLockKey)
        // Surprises stay private by default.
        hidesSurpriseNotificationPreviews = defaults.object(forKey: Self.hidePreviewsKey) as? Bool ?? true
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
