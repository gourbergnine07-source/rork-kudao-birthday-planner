//
//  PartyPlan.swift
//  Kudao
//

import Foundation
import SwiftData

/// Persisted party plan for a profile: the current draft plus the confirmation stamp.
@Model
final class PartyPlan {
    var id: UUID = UUID()
    var profile: BirthdayProfile?

    var giftIdea: String = ""
    var giftPriceRaw: String = PriceBand.medium.rawValue
    var giftReason: String = ""

    var cakeType: String = ""
    var cakeReason: String = ""

    var venueIdea: String = ""
    var venueReason: String = ""

    var guestCount: Int = 8

    var confidenceRaw: String = SuggestionConfidence.low.rawValue
    /// Number of keywords the plan was generated from.
    var sourceKeywordCount: Int = 0
    /// True as soon as the user edits any card by hand.
    var isManuallyEdited: Bool = false
    var generatedAt: Date = Date()
    /// Set by "Confirm all"; cleared whenever the plan changes again.
    var confirmedAt: Date?

    init(suggestion: PartySuggestion, keywordCount: Int, profile: BirthdayProfile? = nil) {
        self.id = UUID()
        self.profile = profile
        self.sourceKeywordCount = keywordCount
        self.generatedAt = Date()
        apply(suggestion)
    }

    var suggestion: PartySuggestion {
        PartySuggestion(
            giftIdea: giftIdea,
            giftPriceBand: PriceBand(rawValue: giftPriceRaw) ?? .medium,
            giftReason: giftReason,
            cakeType: cakeType,
            cakeReason: cakeReason,
            venueIdea: venueIdea,
            venueReason: venueReason,
            guestCount: guestCount,
            confidence: SuggestionConfidence(rawValue: confidenceRaw) ?? .low
        )
    }

    /// Writes a suggestion into the plan. Any change invalidates a previous confirmation.
    func apply(_ suggestion: PartySuggestion) {
        giftIdea = suggestion.giftIdea
        giftPriceRaw = suggestion.giftPriceBand.rawValue
        giftReason = suggestion.giftReason
        cakeType = suggestion.cakeType
        cakeReason = suggestion.cakeReason
        venueIdea = suggestion.venueIdea
        venueReason = suggestion.venueReason
        guestCount = suggestion.guestCount
        confidenceRaw = suggestion.confidence.rawValue
        confirmedAt = nil
    }

    var isConfirmed: Bool { confirmedAt != nil }
}
