//
//  OccasionKind.swift
//  Kudao
//

import SwiftUI

/// What a Kudao profile is actually about.
///
/// Kudao started as a birthday planner, and the birthday case is still the
/// default. The other three reuse the same machinery — one reference date, a
/// diary, a prepared text, a shared gallery — but change the vocabulary, the
/// colours and, for a remembrance, drop the gift engine entirely.
///
/// Raw values stay Italian: they travel inside the AI prompts and the cloud
/// payload, exactly like `AgeBracket` and the plan JSON keys already do.
nonisolated enum OccasionKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case birthday = "compleanno"
    case wedding = "matrimonio"
    case remembrance = "commemorazione"
    case other = "altro"

    var id: String { rawValue }

    static func parse(_ raw: String?) -> OccasionKind {
        let normalized = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return OccasionKind(rawValue: normalized) ?? .birthday
    }

    var symbolName: String {
        switch self {
        case .birthday: "birthday.cake.fill"
        case .wedding: "infinity"
        case .remembrance: "leaf.fill"
        case .other: "star.fill"
        }
    }

    // MARK: - Behaviour

    /// Remembrances have no gift, cake or guest list to plan.
    var wantsSuggestions: Bool { self != .remembrance }

    /// A surprise only makes sense when somebody can still be surprised.
    var wantsSurpriseMode: Bool { self != .remembrance }

    /// Only birthdays derive a life stage from the reference date.
    var wantsAgeBracket: Bool { self == .birthday }

    /// The "relazione" picker is replaced by a soberer "legame" one.
    var usesBond: Bool { self == .remembrance }

    /// Addresses and phone numbers would be out of place on a remembrance.
    var wantsContactDetails: Bool { self != .remembrance }

    /// Only a remembrance can never be about the person holding the phone.
    var allowsSelfProfile: Bool { self != .remembrance }

    /// Confetti, party poppers and the warm gradient stay away from a remembrance.
    var isFestive: Bool { self != .remembrance }

    /// The main notification fires on the day itself instead of days before.
    var remindsOnTheDay: Bool { self == .remembrance }

    // MARK: - Colours

    @MainActor
    var accent: Color {
        switch self {
        case .birthday: Palette.coral
        case .wedding: Palette.berry
        case .remembrance: Palette.sage
        case .other: Palette.dusk
        }
    }

    /// Header and hero-card fill.
    @MainActor
    var gradient: LinearGradient {
        switch self {
        case .birthday: Palette.warmGradient
        case .wedding: Palette.vowGradient
        case .remembrance: Palette.stillGradient
        case .other: Palette.eventGradient
        }
    }

    // MARK: - Wording

    func title(_ strings: Strings) -> String {
        switch self {
        case .birthday: strings.occasionBirthday
        case .wedding: strings.occasionWedding
        case .remembrance: strings.occasionRemembrance
        case .other: strings.occasionOther
        }
    }

    /// One line under the big card in the picker.
    func caption(_ strings: Strings) -> String {
        switch self {
        case .birthday: strings.occasionBirthdayCaption
        case .wedding: strings.occasionWeddingCaption
        case .remembrance: strings.occasionRemembranceCaption
        case .other: strings.occasionOtherCaption
        }
    }

    /// Plural label used by the home filter.
    func pluralTitle(_ strings: Strings) -> String {
        switch self {
        case .birthday: strings.occasionBirthdayPlural
        case .wedding: strings.occasionWeddingPlural
        case .remembrance: strings.occasionRemembrancePlural
        case .other: strings.occasionOtherPlural
        }
    }

    /// What the single date on the profile means.
    func dateLabel(_ strings: Strings) -> String {
        switch self {
        case .birthday: strings.birthDateLabel
        case .wedding: strings.weddingDateLabel
        case .remembrance: strings.passingDateLabel
        case .other: strings.eventDateLabel
        }
    }

    /// Caption of the first stat tile.
    func dateStatLabel(_ strings: Strings) -> String {
        switch self {
        case .birthday: strings.birthLabel
        case .wedding: strings.weddingStatLabel
        case .remembrance: strings.passingStatLabel
        case .other: strings.eventStatLabel
        }
    }

    /// Caption of the second stat tile: age, years together, years since.
    func elapsedStatLabel(_ strings: Strings) -> String {
        switch self {
        case .birthday: strings.ageLabel
        case .wedding: strings.yearsTogetherLabel
        case .remembrance: strings.yearsSinceLabel
        case .other: strings.yearsElapsedLabel
        }
    }

    /// "al compleanno" / "all'anniversario" / "alla ricorrenza" / "all'evento".
    func countdownSuffix(_ strings: Strings) -> String {
        switch self {
        case .birthday: strings.daysToGo
        case .wedding: strings.daysToAnniversary
        case .remembrance: strings.daysToRemembrance
        case .other: strings.daysToEvent
        }
    }

    /// Headline of the banner on the day itself.
    func todayTitle(_ strings: Strings) -> String {
        switch self {
        case .birthday: strings.todayTitle
        case .wedding: strings.todayAnniversaryTitle
        case .remembrance: strings.todayRemembranceTitle
        case .other: strings.todayEventTitle
        }
    }

    /// Label of the button that jumps to the prepared text.
    func composeAction(_ strings: Strings) -> String {
        switch self {
        case .birthday: strings.sendWishesAction
        case .wedding: strings.sendAnniversaryWishesAction
        case .remembrance: strings.writeThoughtAction
        case .other: strings.sendEventWishesAction
        }
    }

    /// Title of the diary tab: notes about tastes, or memories of a person.
    func diaryTabTitle(_ strings: Strings) -> String {
        self == .remembrance ? strings.memoriesTab : strings.diaryTab
    }

    /// Title of the message tab: a greeting, or a thought.
    func messageTabTitle(_ strings: Strings) -> String {
        self == .remembrance ? strings.thoughtTab : strings.messageTab
    }

    /// Symbol of the diary tab, softer for a remembrance.
    var diarySymbolName: String {
        self == .remembrance ? "heart.text.square.fill" : "book.closed.fill"
    }

    var messageSymbolName: String {
        self == .remembrance ? "quote.bubble.fill" : "paperplane.fill"
    }
}
