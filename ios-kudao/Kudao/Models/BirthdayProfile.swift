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
    /// Optional family name, shown next to the first name in the header.
    var lastName: String = ""
    @Attribute(.externalStorage) var photoData: Data?
    var birthDate: Date = Date()

    // MARK: Contact details (all optional)

    var address: String = ""
    var contactPhone: String = ""
    var contactEmail: String = ""
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
        lastName: String = "",
        address: String = "",
        contactPhone: String = "",
        contactEmail: String = "",
        photoData: Data? = nil,
        isSurpriseMode: Bool = false,
        ownerUserID: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.lastName = lastName
        self.address = address
        self.contactPhone = contactPhone
        self.contactEmail = contactEmail
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

    /// "Mike Ross" when a family name exists, otherwise just the first name.
    var fullName: String {
        let trimmed = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? name : "\(name) \(trimmed)"
    }

    var hasLastName: Bool {
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Age reached at the last birthday, i.e. how old the person is right now.
    var currentAge: Int {
        let years = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        return max(0, years)
    }

    /// True when at least one contact field is filled in.
    var hasContactDetails: Bool {
        [address, contactPhone, contactEmail].contains {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
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
