//
//  AppSettings.swift
//  Kudao
//

import Foundation
import Observation

/// Holds the active language and exposes the matching string table.
@Observable
final class AppSettings {
    private static let languageKey = "kudao.language"

    var language: AppLanguage {
        didSet {
            guard language != oldValue else { return }
            UserDefaults.standard.set(language.rawValue, forKey: Self.languageKey)
        }
    }

    init() {
        if let stored = UserDefaults.standard.string(forKey: Self.languageKey),
           let saved = AppLanguage(rawValue: stored) {
            language = saved
        } else {
            language = AppLanguage.detectedFromDevice()
        }
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

    func weekdayDayMonth(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(locale: locale)
                .weekday(.wide)
                .day(.defaultDigits)
                .month(.wide)
        )
    }
}
