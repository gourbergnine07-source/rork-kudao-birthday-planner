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

    // MARK: Reminders

    /// Master switch for the birthday reminder notification.
    var isReminderEnabled: Bool = true
    /// How many days before the birthday the main reminder fires.
    var reminderDaysBefore: Int = 7
    /// Optional earlier notification dedicated to buying the gift.
    var isGiftReminderEnabled: Bool = true
    var giftReminderDaysBefore: Int = 10

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

    /// True while the birthday sits inside the reminder window and the plan is still unconfirmed.
    var needsPlanConfirmation: Bool {
        guard isReminderEnabled else { return false }
        return countdown.daysRemaining <= max(1, reminderDaysBefore) && !(partyPlan?.isConfirmed ?? false)
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
