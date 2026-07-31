//
//  AppLanguage.swift
//  Kudao
//

import Foundation

/// Languages shipped with Kudao. Italian is the fallback.
nonisolated enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case italian = "it"
    case english = "en"
    case french = "fr"
    case spanish = "es"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .italian: "Italiano"
        case .english: "English"
        case .french: "Français"
        case .spanish: "Español"
        }
    }

    var flag: String {
        switch self {
        case .italian: "🇮🇹"
        case .english: "🇬🇧"
        case .french: "🇫🇷"
        case .spanish: "🇪🇸"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }

    var strings: Strings {
        switch self {
        case .italian: .italian
        case .english: .english
        case .french: .french
        case .spanish: .spanish
        }
    }

    /// Picks the first preferred device language supported by the app, defaulting to Italian.
    static func detectedFromDevice() -> AppLanguage {
        for identifier in Locale.preferredLanguages {
            let code = Locale(identifier: identifier).language.languageCode?.identifier ?? ""
            if let match = AppLanguage(rawValue: code) {
                return match
            }
        }
        return .italian
    }
}
