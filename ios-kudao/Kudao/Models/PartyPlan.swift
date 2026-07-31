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
    /// Shop category suggested for the gift, used by the nearby-store search.
    var giftCategory: String = ""
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
            giftCategory: giftCategory,
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
        giftCategory = suggestion.giftCategory
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

    /// True once the AI produced an actual gift idea to shop for.
    var hasGiftIdea: Bool {
        !giftIdea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Search term for shops: the suggested category, falling back to the idea itself.
    var shopSearchTerm: String {
        let category = giftCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        return category.isEmpty ? giftIdea.trimmingCharacters(in: .whitespacesAndNewlines) : category
    }
}
