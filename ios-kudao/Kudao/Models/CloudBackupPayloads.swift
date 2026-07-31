//
//  CloudBackupPayloads.swift
//  Kudao
//

import Foundation

/// Party plan carried inside the profile's `plan` JSONB column.
nonisolated struct CloudPlanPayload: Codable, Sendable {
    let giftIdea: String
    let giftCategory: String
    let giftPriceBand: String
    let giftReason: String
    let cakeType: String
    let cakeReason: String
    let venueIdea: String
    let venueReason: String
    let guestCount: Int
    let confidence: String
    let sourceKeywordCount: Int
    let isManuallyEdited: Bool
    let generatedAt: Double
    let confirmedAt: Double?
}

/// Prepared greeting carried inside the profile's `message` JSONB column.
nonisolated struct CloudMessagePayload: Codable, Sendable {
    let text: String
    let scheduledAt: Double
    let isScheduleEnabled: Bool
    let isSent: Bool
    let sentAt: Double?
    let tone: String
    let isAutoRefreshEnabled: Bool
    let isUserEdited: Bool
    let sourceSignature: String
    let createdAt: Double
    let updatedAt: Double
}

/// One row of `cloud_profiles`, in both directions.
///
/// Timestamps travel as milliseconds since 1970 and the birth date as a plain
/// `yyyy-MM-dd` string, so no time zone can ever shift somebody's birthday.
nonisolated struct CloudProfilePayload: Codable, Sendable {
    let id: String
    let name: String
    let lastName: String
    let birthDate: String
    let relationship: String
    /// `OccasionKind` raw value: what the profile actually celebrates.
    let occasion: String
    /// True when the occasion belongs to the app user themselves.
    let isSelfProfile: Bool
    /// `BondKind` raw value, only meaningful on a remembrance.
    let bond: String
    let favoriteCharacter: String
    let address: String
    let contactPhone: String
    let contactEmail: String
    let isSurpriseMode: Bool
    let photoBase64: String?
    let reminderEnabled: Bool
    let reminderDaysBefore: Int
    let giftReminderEnabled: Bool
    let giftReminderDaysBefore: Int
    let plan: CloudPlanPayload?
    let message: CloudMessagePayload?
    let createdAt: Double
    let updatedAt: Double
    let deletedAt: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case lastName = "last_name"
        case birthDate = "birth_date"
        case relationship
        case occasion
        case isSelfProfile = "is_self_profile"
        case bond
        case favoriteCharacter = "favorite_character"
        case address
        case contactPhone = "contact_phone"
        case contactEmail = "contact_email"
        case isSurpriseMode = "is_surprise_mode"
        case photoBase64 = "photo_base64"
        case reminderEnabled = "reminder_enabled"
        case reminderDaysBefore = "reminder_days_before"
        case giftReminderEnabled = "gift_reminder_enabled"
        case giftReminderDaysBefore = "gift_reminder_days_before"
        case plan
        case message
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }

    /// Minimal row used to tell the server a profile was deleted on this device.
    static func tombstone(id: String, at moment: Double) -> CloudProfilePayload {
        CloudProfilePayload(
            id: id,
            name: "",
            lastName: "",
            birthDate: CloudDateFormat.day.string(from: Date()),
            relationship: RelationshipKind.friend.rawValue,
            occasion: OccasionKind.birthday.rawValue,
            isSelfProfile: false,
            bond: BondKind.other.rawValue,
            favoriteCharacter: "",
            address: "",
            contactPhone: "",
            contactEmail: "",
            isSurpriseMode: false,
            photoBase64: nil,
            reminderEnabled: false,
            reminderDaysBefore: 7,
            giftReminderEnabled: false,
            giftReminderDaysBefore: 10,
            plan: nil,
            message: nil,
            createdAt: moment,
            updatedAt: moment,
            deletedAt: moment
        )
    }
}

/// One row of `cloud_diary_entries`, in both directions.
nonisolated struct CloudEntryPayload: Codable, Sendable {
    let id: String
    let profileId: String
    let textContent: String
    let authorUserId: String
    let authorName: String
    let isRemote: Bool
    let createdAt: Double
    let updatedAt: Double
    let deletedAt: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case profileId = "profile_id"
        case textContent = "text_content"
        case authorUserId = "author_user_id"
        case authorName = "author_name"
        case isRemote = "is_remote"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }

    static func tombstone(id: String, profileId: String, at moment: Double) -> CloudEntryPayload {
        CloudEntryPayload(
            id: id,
            profileId: profileId,
            textContent: "",
            authorUserId: "",
            authorName: "",
            isRemote: false,
            createdAt: moment,
            updatedAt: moment,
            deletedAt: moment
        )
    }
}

// MARK: - Function parameters and answers

nonisolated struct CloudCreateVaultParams: Encodable, Sendable {
    let code: String
    let label: String

    enum CodingKeys: String, CodingKey {
        case code = "p_code"
        case label = "p_label"
    }
}

/// Sync parameters.
///
/// `code` is optional on purpose: a signed-in device can leave it out and the
/// database resolves the vault from the account instead.
nonisolated struct CloudSyncParams: Encodable, Sendable {
    let code: String?
    let profiles: [CloudProfilePayload]
    let entries: [CloudEntryPayload]

    enum CodingKeys: String, CodingKey {
        case code = "p_code"
        case profiles = "p_profiles"
        case entries = "p_entries"
    }
}

nonisolated struct CloudCodeParams: Encodable, Sendable {
    let code: String?

    enum CodingKeys: String, CodingKey {
        case code = "p_code"
    }
}

/// What `kudao_account_vault` reports about the signed-in account.
nonisolated struct CloudAccountVault: Decodable, Sendable {
    let linked: Bool
    let profileCount: Int?

    enum CodingKeys: String, CodingKey {
        case linked
        case profileCount = "profile_count"
    }
}

nonisolated struct CloudVaultCreated: Decodable, Sendable {
    let accountId: String
    /// True when the vault was bound to the signed-in account on creation.
    let linked: Bool?

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case linked
    }
}

nonisolated struct CloudSyncResponse: Decodable, Sendable {
    let accountId: String
    let profiles: [CloudProfilePayload]
    let entries: [CloudEntryPayload]
    let syncedAt: Double

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case profiles
        case entries
        case syncedAt = "synced_at"
    }
}

/// Fixed formatters used on the wire: never locale dependent.
nonisolated enum CloudDateFormat {
    static let day: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// Rebuilds a local date at midday, so daylight saving can never move it a day.
    static func date(fromDay text: String) -> Date? {
        guard let parsed = day.date(from: text) else { return nil }
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: parsed) ?? parsed
    }

    static func millis(_ date: Date) -> Double {
        date.timeIntervalSince1970 * 1000
    }

    static func date(fromMillis value: Double?) -> Date? {
        guard let value, value > 0 else { return nil }
        return Date(timeIntervalSince1970: value / 1000)
    }
}
