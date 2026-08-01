//
//  BirthdayProfile.swift
//  Kudao
//

import Foundation
import SwiftData

/// An occasion the owner wants to prepare for, and the person behind it.
///
/// The type is still called `BirthdayProfile` because that is what SwiftData
/// persists, but a profile can now be a birthday, a wedding anniversary, a
/// remembrance or a free-form event — see `occasion`.
@Model
final class BirthdayProfile {
    var id: UUID = UUID()
    /// Reserved for future multi-user sync; nil while the app is local-only.
    var ownerUserID: String?
    var name: String = ""
    /// Optional family name, shown next to the first name in the header.
    var lastName: String = ""
    @Attribute(.externalStorage) var photoData: Data?
    /// The one date the whole profile revolves around.
    ///
    /// Its meaning follows `occasion`: date of birth for a birthday, the wedding
    /// day for an anniversary, the day somebody passed for a remembrance, or a
    /// free date for anything else. The stored name is kept for compatibility.
    var birthDate: Date = Date()

    // MARK: Occasion

    /// Which kind of occasion this profile is, as an `OccasionKind` raw value.
    var occasionRaw: String = OccasionKind.birthday.rawValue
    /// True when the occasion belongs to the app user themselves.
    var isSelfProfile: Bool = false
    /// Tie to the remembered person, as a `BondKind` raw value. Remembrances only.
    var bondRaw: String = BondKind.other.rawValue

    // MARK: Contact details (all optional)

    var address: String = ""
    var contactPhone: String = ""
    var contactEmail: String = ""
    var relationshipRaw: String = RelationshipKind.friend.rawValue
    /// Only asked for children: cartoon or character they love, used for themed ideas.
    var favoriteCharacter: String = ""
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
    /// Keeps this profile out of the recurring "write something down" invitations.
    var isDiaryNudgeExcluded: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \DiaryEntry.profile)
    var diaryEntries: [DiaryEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \DiaryTag.profile)
    var diaryTags: [DiaryTag] = []

    @Relationship(deleteRule: .cascade, inverse: \PartyPlan.profile)
    var partyPlan: PartyPlan?

    @Relationship(deleteRule: .cascade, inverse: \BirthdayMessage.profile)
    var birthdayMessage: BirthdayMessage?

    @Relationship(deleteRule: .cascade, inverse: \GalleryItem.profile)
    var galleryItems: [GalleryItem] = []

    /// Every cycle of this profile that has already happened, oldest to newest.
    @Relationship(deleteRule: .cascade, inverse: \EventRecord.profile)
    var eventHistory: [EventRecord] = []

    // MARK: Collaboration

    /// Kudao id of the person who owns the profile; empty until it is shared.
    var shareOwnerUserID: String = ""
    /// Display name of that owner, shown to invited collaborators.
    var shareOwnerName: String = ""
    /// Share-room id: this profile's own uuid for owners, the original id for mirrors.
    var remoteProfileID: String = ""
    /// Permission granted to me; empty when I am the owner of the profile.
    var sharedPermissionRaw: String = ""
    /// Set once the profile belongs to a collaborative room.
    var sharedAt: Date?
    /// Last successful sync with the share room.
    var lastSyncedAt: Date?

    init(
        name: String,
        birthDate: Date,
        relationship: RelationshipKind,
        lastName: String = "",
        address: String = "",
        contactPhone: String = "",
        contactEmail: String = "",
        favoriteCharacter: String = "",
        photoData: Data? = nil,
        isSurpriseMode: Bool = false,
        ownerUserID: String? = nil,
        occasion: OccasionKind = .birthday,
        isSelfProfile: Bool = false,
        bond: BondKind = .other
    ) {
        self.id = UUID()
        self.name = name
        self.lastName = lastName
        self.address = address
        self.contactPhone = contactPhone
        self.contactEmail = contactEmail
        self.birthDate = birthDate
        self.relationshipRaw = relationship.rawValue
        self.favoriteCharacter = favoriteCharacter
        self.photoData = photoData
        self.isSurpriseMode = isSurpriseMode
        self.ownerUserID = ownerUserID
        self.occasionRaw = occasion.rawValue
        self.isSelfProfile = isSelfProfile
        self.bondRaw = bond.rawValue
        self.createdAt = Date()
    }

    var relationship: RelationshipKind {
        get { RelationshipKind(rawValue: relationshipRaw) ?? .friend }
        set { relationshipRaw = newValue.rawValue }
    }

    /// What this profile celebrates or commemorates.
    var occasion: OccasionKind {
        get { OccasionKind.parse(occasionRaw) }
        set { occasionRaw = newValue.rawValue }
    }

    /// Tie to the remembered person; only meaningful on a remembrance.
    var bond: BondKind {
        get { BondKind.parse(bondRaw) }
        set { bondRaw = newValue.rawValue }
    }

    /// The reference date, under the name the rest of the app should use.
    var referenceDate: Date {
        get { birthDate }
        set { birthDate = newValue }
    }

    /// Short label describing the tie, whichever picker the occasion uses.
    func bondOrRelationshipTitle(_ strings: Strings) -> String {
        occasion.usesBond ? bond.title(strings) : relationship.title(strings)
    }

    /// Matching symbol for that label.
    var bondOrRelationshipSymbol: String {
        occasion.usesBond ? bond.symbolName : relationship.symbolName
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

    /// Full years elapsed since the reference date.
    ///
    /// Age for a birthday, years married for an anniversary, years since the
    /// loss for a remembrance.
    var currentAge: Int {
        let years = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        return max(0, years)
    }

    /// Life stage derived from the birth date; never edited by hand.
    ///
    /// Only a birthday profile has a meaningful one — everything else reads as
    /// an adult so the AI guidance stays neutral.
    var ageBracket: AgeBracket {
        occasion.wantsAgeBracket ? AgeBracket.forAge(currentAge) : .adult
    }

    /// Trimmed favourite character, only meaningful for children.
    var trimmedFavoriteCharacter: String {
        favoriteCharacter.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: Party gallery

    /// How long the shared gallery stays open after the party.
    static let galleryWindowDays: Int = 60

    /// The gallery opens on the day of the party and closes again once the memories are old.
    var isGalleryUnlocked: Bool {
        countdown.isToday || countdown.daysSinceLast <= Self.galleryWindowDays
    }

    /// Date the gallery becomes available: this year's birthday, or the next one.
    var galleryUnlockDate: Date {
        isGalleryUnlocked ? countdown.lastDate : countdown.nextDate
    }

    // MARK: Collaboration helpers

    /// A profile I joined through an invite code, owned by somebody else.
    var isSharedMirror: Bool { !sharedPermissionRaw.isEmpty }

    /// Permission I hold on this profile: owners always have full access.
    var myPermission: SharePermission {
        isSharedMirror ? SharePermission.parse(sharedPermissionRaw) : .edit
    }

    /// True once the profile lives in a share room (either side of it).
    var isCollaborative: Bool { sharedAt != nil }

    /// Id used to address the share room on the backend.
    var roomID: String {
        remoteProfileID.isEmpty ? id.uuidString : remoteProfileID
    }

    /// Guests with "view" access can read everything but change nothing.
    var canContribute: Bool { myPermission == .edit }

    /// Only the original owner edits the profile data, the plan and the reminders.
    var isOwnedByMe: Bool { !isSharedMirror }

    /// True when this profile may appear in the recurring diary invitations.
    ///
    /// Remembrances never do: a periodic prompt to write about somebody who is
    /// gone would be the wrong tone. Read-only guests are left out too, since
    /// they cannot add a note anyway.
    var wantsDiaryNudges: Bool {
        guard !isDiaryNudgeExcluded, occasion != .remembrance else { return false }
        return canContribute
    }

    /// True when at least one contact field is filled in.
    var hasContactDetails: Bool {
        [address, contactPhone, contactEmail].contains {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    /// True while the date sits inside the reminder window and the plan is still unconfirmed.
    ///
    /// Remembrances have nothing to plan, so they never ask for a confirmation.
    var needsPlanConfirmation: Bool {
        guard isReminderEnabled, occasion.wantsSuggestions else { return false }
        return countdown.daysRemaining <= max(1, reminderDaysBefore) && !(partyPlan?.isConfirmed ?? false)
    }

    // MARK: Archive

    /// Past cycles, most recent year first.
    var archivedCycles: [EventRecord] {
        eventHistory.sorted { $0.eventDate > $1.eventDate }
    }

    /// True once at least one cycle of this profile has been archived.
    var hasHistory: Bool { !eventHistory.isEmpty }

    /// Gift ideas already used in past years, newest first.
    ///
    /// Feeding these back into the engine is what stops the same present from
    /// being suggested twice.
    var pastGiftIdeas: [String] {
        archivedCycles.compactMap { record in
            let idea = record.plan?.giftIdea.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return idea.isEmpty ? nil : idea
        }
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
