//
//  BirthdayProfile.swift
//  Kudao
//

import Foundation
import SwiftData

/// A person whose birthday the owner wants to plan for.
@Model
final class BirthdayProfile {
    var id: UUID = UUID()
    /// Reserved for future multi-user sync; nil while the app is local-only.
    var ownerUserID: String?
    var name: String = ""
    @Attribute(.externalStorage) var photoData: Data?
    var birthDate: Date = Date()
    var relationshipRaw: String = RelationshipKind.friend.rawValue
    var isSurpriseMode: Bool = false
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \DiaryEntry.profile)
    var diaryEntries: [DiaryEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \DiaryTag.profile)
    var diaryTags: [DiaryTag] = []

    @Relationship(deleteRule: .cascade, inverse: \PartyPlan.profile)
    var partyPlan: PartyPlan?

    init(
        name: String,
        birthDate: Date,
        relationship: RelationshipKind,
        photoData: Data? = nil,
        isSurpriseMode: Bool = false,
        ownerUserID: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.relationshipRaw = relationship.rawValue
        self.photoData = photoData
        self.isSurpriseMode = isSurpriseMode
        self.ownerUserID = ownerUserID
        self.createdAt = Date()
    }

    var relationship: RelationshipKind {
        get { RelationshipKind(rawValue: relationshipRaw) ?? .friend }
        set { relationshipRaw = newValue.rawValue }
    }

    var countdown: BirthdayCountdown {
        BirthdayCountdown(birthDate: birthDate)
    }

    /// First grapheme of every word, max two characters, used for the avatar fallback.
    var initials: String {
        let parts = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
        return parts.isEmpty ? "?" : parts.joined().uppercased()
    }
}
