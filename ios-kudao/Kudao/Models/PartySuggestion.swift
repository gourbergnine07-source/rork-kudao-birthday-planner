//
//  PartySuggestion.swift
//  Kudao
//

import SwiftUI

/// Budget bracket suggested for the gift. Raw values match the JSON contract.
nonisolated enum PriceBand: String, Codable, CaseIterable, Identifiable, Sendable {
    case low = "basso"
    case medium = "medio"
    case high = "alto"

    var id: String { rawValue }

    /// How many filled pips the UI shows.
    var level: Int {
        switch self {
        case .low: 1
        case .medium: 2
        case .high: 3
        }
    }

    static func parse(_ raw: String) -> PriceBand {
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let exact = PriceBand(rawValue: normalized) { return exact }
        switch normalized {
        case "low", "bajo", "bas", "faible", "economico", "cheap": return .low
        case "high", "alta", "élevé", "eleve", "elevado", "expensive", "premium": return .high
        default: return .medium
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .low: strings.priceLow
        case .medium: strings.priceMedium
        case .high: strings.priceHigh
        }
    }
}

/// How much the engine trusts its own answer, driven by how many tags exist.
nonisolated enum SuggestionConfidence: String, Codable, CaseIterable, Identifiable, Sendable {
    case low = "bassa"
    case medium = "media"
    case high = "alta"

    var id: String { rawValue }

    var rank: Int {
        switch self {
        case .low: 0
        case .medium: 1
        case .high: 2
        }
    }

    var symbolName: String {
        switch self {
        case .low: "gauge.with.dots.needle.0percent"
        case .medium: "gauge.with.dots.needle.50percent"
        case .high: "gauge.with.dots.needle.100percent"
        }
    }

    static func parse(_ raw: String) -> SuggestionConfidence {
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let exact = SuggestionConfidence(rawValue: normalized) { return exact }
        switch normalized {
        case "low", "baja", "faible", "basso": return .low
        case "high", "alta", "élevée", "elevee", "elevada", "alto": return .high
        default: return .medium
        }
    }

    /// The engine can never claim more confidence than the diary actually supports.
    static func ceiling(forKeywordCount count: Int) -> SuggestionConfidence {
        switch count {
        case 0...3: .low
        case 4...8: .medium
        default: .high
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .low: strings.confidenceLow
        case .medium: strings.confidenceMedium
        case .high: strings.confidenceHigh
        }
    }

    @MainActor
    var accent: Color {
        switch self {
        case .low: Palette.amber
        case .medium: Palette.violet
        case .high: Palette.teal
        }
    }
}

/// The four cards of the party plan, used for regeneration and manual editing.
nonisolated enum PlanSection: String, CaseIterable, Identifiable, Sendable {
    case gift
    case cake
    case venue
    case guests

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .gift: "gift.fill"
        case .cake: "birthday.cake.fill"
        case .venue: "mappin.and.ellipse"
        case .guests: "person.2.fill"
        }
    }

    /// JSON key the model must answer with when only this card is regenerated.
    var jsonKey: String {
        switch self {
        case .gift: "regalo"
        case .cake: "torta"
        case .venue: "locale_tipo"
        case .guests: "numero_invitati_stimato"
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .gift: strings.giftCardTitle
        case .cake: strings.cakeCardTitle
        case .venue: strings.venueCardTitle
        case .guests: strings.guestsCardTitle
        }
    }

    /// An anniversary plans a present and an experience, not a cake and a guest list.
    func title(_ strings: Strings, occasion: OccasionKind) -> String {
        guard occasion == .wedding else { return title(strings) }
        switch self {
        case .gift: return strings.anniversaryGiftCardTitle
        case .cake: return strings.experienceCardTitle
        case .venue: return strings.anniversaryVenueCardTitle
        case .guests: return strings.guestsCardTitle
        }
    }

    func symbolName(for occasion: OccasionKind) -> String {
        guard occasion == .wedding else { return symbolName }
        switch self {
        case .gift: return "gift.fill"
        case .cake: return "sparkles"
        case .venue: return "fork.knife"
        case .guests: return "person.2.fill"
        }
    }

    /// Which cards the plan is made of, for a given occasion.
    ///
    /// A wedding drops the guest count: an anniversary is usually for two.
    static func sections(for occasion: OccasionKind) -> [PlanSection] {
        switch occasion {
        case .wedding: [.gift, .cake, .venue]
        case .birthday, .other: allCases
        case .remembrance: []
        }
    }

    @MainActor
    var accent: Color {
        switch self {
        case .gift: Palette.berry
        case .cake: Palette.coral
        case .venue: Palette.teal
        case .guests: Palette.amber
        }
    }
}

/// In-memory shape of one generated party plan.
nonisolated struct PartySuggestion: Sendable, Equatable {
    var giftIdea: String
    /// Kind of shop that sells the idea, e.g. "profumeria" — drives the nearby-store search.
    var giftCategory: String
    var giftPriceBand: PriceBand
    var giftReason: String
    var cakeType: String
    var cakeReason: String
    var venueIdea: String
    var venueReason: String
    var guestCount: Int
    var confidence: SuggestionConfidence

    /// Headline text shown on a card.
    func headline(for section: PlanSection, strings: Strings) -> String {
        switch section {
        case .gift: giftIdea
        case .cake: cakeType
        case .venue: venueIdea
        case .guests: String(format: strings.guestsUnitFormat, guestCount)
        }
    }

    func reason(for section: PlanSection) -> String {
        switch section {
        case .gift: giftReason
        case .cake: cakeReason
        case .venue: venueReason
        case .guests: ""
        }
    }
}
