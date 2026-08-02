//
//  ContactCandidate.swift
//  Kudao
//

import Foundation

/// One address-book entry ready to become a profile.
///
/// Deliberately free of any Contacts framework type: the import sheet, the
/// previews and the tests all work on plain values.
nonisolated struct ContactCandidate: Identifiable, Sendable, Hashable {
    /// Stable identifier of the underlying system contact.
    let id: String
    let givenName: String
    let familyName: String
    /// Day and month of the birthday, plus the year when the contact has one.
    ///
    /// Empty when the address book holds no date at all: those contacts can
    /// still be imported, the date is asked for in a following step.
    let birthday: DateComponents
    /// Picture from the address book, already downscaled to avatar size.
    let photoData: Data?
    let phone: String
    let email: String
    /// Home address on a single line, empty when the card carries none.
    let postalAddress: String

    /// Many address books only hold a day and a month.
    var hasYear: Bool { birthday.year != nil }

    /// False when the contact carries no birthday whatsoever.
    var hasDate: Bool { birthday.day != nil && birthday.month != nil }

    /// "Giulia Rossi", or just the part that exists.
    var fullName: String {
        [givenName, familyName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// The date to store on the profile.
    ///
    /// When the year is missing the day and month still have to land on a real
    /// date, so the most recent occurrence is used and the profile remembers
    /// that its year is a placeholder — nothing ever shows an invented age.
    func resolvedDate(reference: Date = Date(), calendar: Calendar = .current) -> Date {
        guard let month = birthday.month, let day = birthday.day else { return reference }

        var components = DateComponents()
        components.month = month
        components.day = day
        components.hour = 12

        if let year = birthday.year {
            components.year = year
            return calendar.date(from: components) ?? reference
        }

        let currentYear = calendar.component(.year, from: reference)
        components.year = currentYear
        guard let thisYear = calendar.date(from: components) else { return reference }
        if thisYear <= reference { return thisYear }

        components.year = currentYear - 1
        return calendar.date(from: components) ?? thisYear
    }

    /// Key used to spot a contact that is already in Kudao: name plus day and month.
    ///
    /// The year is left out on purpose, so a profile created by hand with an
    /// approximate year is still recognised as the same person.
    var matchKey: String {
        "\(nameKey)|\(birthday.month ?? 0)|\(birthday.day ?? 0)"
    }

    /// Name-only key, used to recognise a dateless contact already in Kudao.
    ///
    /// Without a date there is nothing else to compare, so two people sharing a
    /// name are treated as one rather than offering an obvious duplicate.
    var nameKey: String {
        fullName
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension ContactCandidate {
    /// Match key for a profile already stored in the app.
    static func matchKey(name: String, lastName: String, date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.month, .day], from: date)
        return "\(nameKey(name: name, lastName: lastName))|\(components.month ?? 0)|\(components.day ?? 0)"
    }

    /// Name-only key for a profile already stored in the app.
    static func nameKey(name: String, lastName: String) -> String {
        [name, lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}
