//
//  ProfileSearch.swift
//  Kudao
//

import Foundation

/// Matches profiles against whatever somebody types in the home search field.
///
/// People look for a person in two ways: by name, or by *when*. "marco",
/// "giugno", "12/06" and "1990" all have to lead somewhere. Every profile is
/// therefore flattened into a small haystack holding its names and every
/// sensible spelling of its date, and each word of the query has to appear in
/// it — so "marco giugno" narrows instead of widening.
@MainActor
struct ProfileSearch {
    let settings: AppSettings

    private let calendar: Calendar = .current

    /// Splits a raw query into normalised words. Empty when nothing was typed.
    static func tokens(_ query: String, locale: Locale = .current) -> [String] {
        normalise(query, locale: locale)
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
    }

    /// True when every word of the query appears in the profile's haystack.
    func matches(_ profile: BirthdayProfile, tokens: [String]) -> Bool {
        guard !tokens.isEmpty else { return true }
        let haystack = haystack(for: profile)
        return tokens.allSatisfy { haystack.contains($0) }
    }

    /// Names and dates of one profile, lowercased and stripped of accents.
    private func haystack(for profile: BirthdayProfile) -> String {
        var parts: [String] = [profile.name, profile.lastName]

        // Both the original date and the next occurrence: somebody searching
        // "giugno" means the celebration, not the year it was first recorded.
        let next = profile.countdown.nextDate
        for date in [profile.birthDate, next] {
            parts.append(settings.dayMonth(date))
            let components = calendar.dateComponents([.day, .month], from: date)
            guard let day = components.day, let month = components.month else { continue }
            parts.append("\(day)/\(month)")
            parts.append(String(format: "%02d/%02d", day, month))
            parts.append(String(format: "%02d.%02d", day, month))
            parts.append("\(day)-\(month)")
        }

        parts.append(String(calendar.component(.year, from: next)))

        // A placeholder year is never searchable: it was invented by the app.
        if !profile.hasUnknownBirthYear {
            parts.append(String(calendar.component(.year, from: profile.birthDate)))
            parts.append(settings.dayMonthYear(profile.birthDate))
        }

        return Self.normalise(parts.joined(separator: " "), locale: settings.locale)
    }

    private static func normalise(_ text: String, locale: Locale) -> String {
        text.folding(
            options: [.diacriticInsensitive, .caseInsensitive, .widthInsensitive],
            locale: locale
        )
    }
}
