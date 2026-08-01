//
//  EventRecord.swift
//  Kudao
//

import Foundation
import SwiftData

/// Frozen copy of a party plan, exactly as it stood when the date arrived.
///
/// The live `PartyPlan` is reset for every new cycle, so the archive keeps its
/// own value copy. It is stored as JSON inside `EventRecord.planJSON`: the
/// snapshot must survive future changes to the plan model without a migration.
nonisolated struct ArchivedPlan: Codable, Sendable, Equatable {
    var giftIdea: String = ""
    var giftCategory: String = ""
    var giftPriceRaw: String = PriceBand.medium.rawValue
    var giftReason: String = ""
    var cakeType: String = ""
    var cakeReason: String = ""
    var venueIdea: String = ""
    var venueReason: String = ""
    var guestCount: Int = 0
    var confidenceRaw: String = SuggestionConfidence.low.rawValue
    /// True when the user had signed the plan off before the event.
    var wasConfirmed: Bool = false
    var confirmedAt: Date?
    var generatedAt: Date?

    var giftPriceBand: PriceBand { PriceBand.parse(giftPriceRaw) }
    var confidence: SuggestionConfidence { SuggestionConfidence.parse(confidenceRaw) }

    /// True when at least one card of the plan carries something to show.
    var hasContent: Bool {
        ![giftIdea, cakeType, venueIdea]
            .allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    func headline(for section: PlanSection) -> String {
        switch section {
        case .gift: giftIdea
        case .cake: cakeType
        case .venue: venueIdea
        case .guests: guestCount > 0 ? String(guestCount) : ""
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

    // MARK: - JSON

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    /// Serialised form stored on the record; empty when encoding is impossible.
    var json: String {
        guard let data = try? Self.encoder.encode(self) else { return "" }
        return String(decoding: data, as: UTF8.self)
    }

    static func decode(_ json: String) -> ArchivedPlan? {
        guard !json.isEmpty, let data = json.data(using: .utf8) else { return nil }
        return try? decoder.decode(ArchivedPlan.self, from: data)
    }
}

/// One closed cycle of a profile: the year that just happened, kept forever.
///
/// Kudao never deletes a profile when its date goes by — it archives the cycle
/// and starts the next one. This is the "event_history" row: what was planned,
/// what was written, which memories were collected, and when it all happened.
@Model
final class EventRecord {
    var id: UUID = UUID()
    /// Owning profile id, denormalised so the library can group without loading relationships.
    var profileID: UUID = UUID()
    /// Calendar year of the event this record closes.
    var year: Int = 0
    /// The day the occasion fell on that year.
    var eventDate: Date = Date()
    var occasionRaw: String = OccasionKind.birthday.rawValue
    /// Name as it read that year, so an old cycle keeps its wording after a rename.
    var profileName: String = ""

    /// `ArchivedPlan` as JSON. Empty for a remembrance, which plans nothing.
    var planJSON: String = ""

    /// The greeting or thought that was prepared for this cycle.
    var messageText: String = ""
    var wasMessageSent: Bool = false

    /// Ids of the gallery items that belong to this cycle.
    var galleryItemIDs: [UUID] = []
    var photoCount: Int = 0
    var videoCount: Int = 0
    /// Thumbnail kept on the record itself, so the cover survives a gallery cleanup.
    @Attribute(.externalStorage) var coverData: Data?

    /// Diary summaries written during the cycle — the "Pensieri" of a remembrance.
    var memoryHighlights: [String] = []
    var noteCount: Int = 0
    /// Keywords the diary held when the cycle closed.
    var keywords: [String] = []

    var archivedAt: Date = Date()
    var updatedAt: Date = Date()

    var profile: BirthdayProfile?

    init(
        profileID: UUID,
        year: Int,
        eventDate: Date,
        occasion: OccasionKind,
        profileName: String,
        profile: BirthdayProfile? = nil
    ) {
        self.id = UUID()
        self.profileID = profileID
        self.year = year
        self.eventDate = eventDate
        self.occasionRaw = occasion.rawValue
        self.profileName = profileName
        self.profile = profile
        self.archivedAt = Date()
        self.updatedAt = Date()
    }

    var occasion: OccasionKind {
        get { OccasionKind.parse(occasionRaw) }
        set { occasionRaw = newValue.rawValue }
    }

    /// The plan that was on the table that year, decoded on demand.
    var plan: ArchivedPlan? {
        ArchivedPlan.decode(planJSON)
    }

    var hasPlan: Bool {
        plan?.hasContent ?? false
    }

    var hasMessage: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var mediaCount: Int { photoCount + videoCount }

    var hasMedia: Bool { mediaCount > 0 }

    /// True while photos of that party can still arrive and update the snapshot.
    func isMediaWindowOpen(reference: Date = Date()) -> Bool {
        let days = Calendar.current.dateComponents([.day], from: eventDate, to: reference).day ?? 0
        return days <= BirthdayProfile.galleryWindowDays
    }

    /// A cycle with nothing in it is not worth a row in the library.
    var isEmpty: Bool {
        !hasPlan && !hasMessage && !hasMedia && memoryHighlights.isEmpty
    }
}
