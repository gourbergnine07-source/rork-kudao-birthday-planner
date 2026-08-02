//
//  ContactCandidate.swift
//  Kudao
//

import Foundation

/// One address-book entry that carries a birthday, ready to become a profile.
///
/// Deliberately free of any Contacts framework type: the import sheet, the
/// previews and the tests all work on plain values.
nonisolated struct ContactCandidate: Identifiable, Sendable, Hashable {
    /// Stable identifier of the underlying system contact.
    let id: String
    let givenName: String
    let familyName: String
    /// Day and month of the birthday, plus the year when the contact has one.
    let birthday: DateComponents
    /// Thumbnail from the address book, already small enough to store as-is.
    let photoData: Data?
    let phone: String
    let email: String

    /// Many address books only hold a day and a month.
    var hasYear: Bool { birthday.year != nil }

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
        var components = DateComponents()
        components.month = birthday.month
        components.day = birthday.day
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
        let name = fullName
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(name)|\(birthday.month ?? 0)|\(birthday.day ?? 0)"
    }
}

extension ContactCandidate {
    /// Match key for a profile already stored in the app.
    static func matchKey(name: String, lastName: String, date: Date, calendar: Calendar = .current) -> String {
        let full = [name, lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let components = calendar.dateComponents([.month, .day], from: date)
        return "\(full)|\(components.month ?? 0)|\(components.day ?? 0)"
    }
}
