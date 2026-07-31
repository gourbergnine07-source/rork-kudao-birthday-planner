//
//  SuggestionVote.swift
//  Kudao
//

import Foundation
import SwiftData

/// A thumbs up / thumbs down cast by one participant on one plan card.
@Model
final class SuggestionVote {
    var id: UUID = UUID()
    var profileID: UUID = UUID()
    /// `PlanSection` raw value: gift, cake, venue, guests.
    var cardRaw: String = PlanSection.gift.rawValue
    var userID: String = ""
    var userName: String = ""
    /// 1 for thumbs up, -1 for thumbs down.
    var value: Int = 0
    var updatedAt: Date = Date()

    init(
        profileID: UUID,
        card: PlanSection,
        userID: String,
        userName: String,
        value: Int,
        updatedAt: Date = Date()
    ) {
        self.id = UUID()
        self.profileID = profileID
        self.cardRaw = card.rawValue
        self.userID = userID
        self.userName = userName
        self.value = value
        self.updatedAt = updatedAt
    }

    var card: PlanSection {
        PlanSection(rawValue: cardRaw) ?? .gift
    }

    var isUp: Bool { value > 0 }
}

/// Aggregated tally shown under a suggestion card.
nonisolated struct VoteTally: Sendable, Equatable {
    var up: Int = 0
    var down: Int = 0
    /// The signed value cast by the current user, 0 when they have not voted.
    var mine: Int = 0

    var total: Int { up + down }
    var score: Int { up - down }
    var hasVotes: Bool { total > 0 }
}
