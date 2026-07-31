//
//  CloudBackupService.swift
//  Kudao
//

import Foundation
import Observation
import SwiftData
import UIKit
import Supabase

/// Keeps a copy of the user's own birthday profiles in the managed Postgres
/// database, so a lost or replaced phone does not mean a lost year of notes.
///
/// The device stays the source of truth: a sync pushes everything local, then
/// pulls back only what is missing here (a restore, or a profile created on
/// another device). Profiles shared by somebody else are never uploaded — they
/// already live in their own share room.
@Observable
final class CloudBackupService {
    private static let lastSyncKey = "kudao.cloud.lastSyncedAt"

    /// The recovery code, present exactly when this device holds one.
    private(set) var code: String?
    /// True when the signed-in email account owns a vault on the server.
    ///
    /// This is the second door into the backup: no code needed, just the account.
    private(set) var isLinkedToAccount: Bool = false
    private(set) var isWorking: Bool = false
    private(set) var lastSyncedAt: Date?
    /// How many profiles and notes the last sync brought back down.
    private(set) var lastRestoredCount: Int = 0
    var errorMessage: String?

    init() {
        code = CloudVaultCode.load()
        let stored = UserDefaults.standard.double(forKey: Self.lastSyncKey)
        lastSyncedAt = stored > 0 ? Date(timeIntervalSince1970: stored) : nil
    }

    /// The backup is live when either door is open.
    var isEnabled: Bool { code != nil || isLinkedToAccount }

    /// True when the vault is only reachable through the signed-in account.
    var isAccountOnly: Bool { code == nil && isLinkedToAccount }

    /// Code sent to the database: nil lets the account resolve the vault instead.
    private var activeCode: String? { code }

    /// False when the build has no database keys (previews, local runs).
    var isAvailable: Bool { SupabaseBackend.isConfigured }

    /// `K7QD-2M4X-9BTR` for display.
    var formattedCode: String { CloudVaultCode.format(code ?? "") }

    // MARK: - Turning it on and off

    /// Creates a brand new vault, stores its code in the Keychain and uploads everything.
    func enable(strings: Strings, context: ModelContext) async {
        guard !isWorking else { return }
        guard let client = SupabaseBackend.client else {
            errorMessage = strings.cloudUnavailableMessage
            return
        }

        isWorking = true
        errorMessage = nil
        let fresh = CloudVaultCode.generate()

        do {
            let created: CloudVaultCreated = try await client
                .rpc("kudao_create_vault", params: CloudCreateVaultParams(code: fresh, label: UIDevice.current.model))
                .execute()
                .value
            _ = created.accountId

            CloudVaultCode.save(fresh)
            code = fresh
            // Creating a vault while signed in binds it to the account server-side.
            isLinkedToAccount = created.linked ?? false
            let response = try await push(code: fresh, client: client, context: context)
            finish(response, context: context)
        } catch {
            code = nil
            CloudVaultCode.clear()
            errorMessage = Self.message(for: error, strings: strings)
        }

        isWorking = false
    }

    /// Connects this device to an existing vault and pulls its content down.
    @discardableResult
    func restore(rawCode: String, strings: Strings, context: ModelContext) async -> Bool {
        guard !isWorking else { return false }
        guard let client = SupabaseBackend.client else {
            errorMessage = strings.cloudUnavailableMessage
            return false
        }

        let candidate = CloudVaultCode.normalize(rawCode)
        guard CloudVaultCode.isValid(candidate) else {
            errorMessage = strings.cloudInvalidCodeMessage
            return false
        }

        isWorking = true
        errorMessage = nil
        var succeeded = false

        do {
            let response = try await push(code: candidate, client: client, context: context)
            CloudVaultCode.save(candidate)
            code = candidate
            finish(response, context: context)
            succeeded = true
        } catch {
            errorMessage = Self.message(for: error, strings: strings)
        }

        isWorking = false
        return succeeded
    }

    /// Uploads the current state and downloads anything missing.
    func sync(strings: Strings, context: ModelContext) async {
        guard !isWorking, isEnabled else { return }
        guard let client = SupabaseBackend.client else { return }

        isWorking = true
        errorMessage = nil

        do {
            let response = try await push(code: activeCode, client: client, context: context)
            finish(response, context: context)
        } catch {
            errorMessage = Self.message(for: error, strings: strings)
        }

        isWorking = false
    }

    // MARK: - Email account

    /// Ties the vault this device already holds to the account that just signed in.
    ///
    /// From then on the same data can be recovered by signing in anywhere, even
    /// if the recovery code is lost.
    func linkToAccount(strings: Strings) async {
        guard let client = SupabaseBackend.client, let code else { return }

        do {
            _ = try await client
                .rpc("kudao_link_vault", params: CloudCodeParams(code: code))
                .execute()
            isLinkedToAccount = true
        } catch {
            errorMessage = Self.message(for: error, strings: strings)
        }
    }

    /// Looks for a vault already owned by the signed-in account and adopts it.
    ///
    /// This is the "new phone, no code" path: sign in, and the notes come back.
    /// Returns true when a vault was found.
    @discardableResult
    func adoptAccountVault(strings: Strings, context: ModelContext) async -> Bool {
        guard !isWorking, let client = SupabaseBackend.client else { return false }

        if code != nil {
            await linkToAccount(strings: strings)
            return isLinkedToAccount
        }

        isWorking = true
        errorMessage = nil
        defer { isWorking = false }

        do {
            let vault: CloudAccountVault = try await client
                .rpc("kudao_account_vault")
                .execute()
                .value
            guard vault.linked else { return false }

            isLinkedToAccount = true
            let response = try await push(code: nil, client: client, context: context)
            finish(response, context: context)
            return true
        } catch {
            errorMessage = Self.message(for: error, strings: strings)
            return false
        }
    }

    /// Called on sign-out: the account door closes, the code door stays open.
    func forgetAccountLink() {
        isLinkedToAccount = false
        if code == nil {
            lastSyncedAt = nil
            lastRestoredCount = 0
            UserDefaults.standard.removeObject(forKey: Self.lastSyncKey)
        }
    }

    /// Stops backing up. `deleteRemoteCopy` also wipes the rows from the database.
    func disable(deleteRemoteCopy: Bool, strings: Strings) async {
        guard isEnabled else { return }

        isWorking = true
        errorMessage = nil

        if deleteRemoteCopy, let client = SupabaseBackend.client {
            do {
                _ = try await client
                    .rpc("kudao_forget_vault", params: CloudCodeParams(code: activeCode))
                    .execute()
            } catch {
                errorMessage = Self.message(for: error, strings: strings)
                isWorking = false
                return
            }
        }

        CloudVaultCode.clear()
        CloudTombstones.clear()
        UserDefaults.standard.removeObject(forKey: Self.lastSyncKey)
        self.code = nil
        isLinkedToAccount = false
        lastSyncedAt = nil
        lastRestoredCount = 0
        isWorking = false
    }

    // MARK: - Sync internals

    private func push(
        code: String?,
        client: SupabaseClient,
        context: ModelContext
    ) async throws -> CloudSyncResponse {
        let now = CloudDateFormat.millis(Date())
        let profiles = (try? context.fetch(FetchDescriptor<BirthdayProfile>())) ?? []
        let mine = profiles.filter(\.isOwnedByMe)

        var profilePayloads = mine.map { Self.payload(for: $0, at: now) }
        var entryPayloads = mine.flatMap { profile in
            profile.diaryEntries.map { Self.payload(for: $0, profileID: profile.id, at: now) }
        }

        profilePayloads.append(contentsOf: CloudTombstones.profiles.map {
            CloudProfilePayload.tombstone(id: $0, at: now)
        })
        entryPayloads.append(contentsOf: CloudTombstones.entries.map {
            CloudEntryPayload.tombstone(id: $0.id, profileId: $0.profileID, at: now)
        })

        return try await client
            .rpc(
                "kudao_sync_vault",
                params: CloudSyncParams(code: code, profiles: profilePayloads, entries: entryPayloads)
            )
            .execute()
            .value
    }

    /// Writes the pulled rows into SwiftData and records the sync stamp.
    private func finish(_ response: CloudSyncResponse, context: ModelContext) {
        lastRestoredCount = adopt(response, context: context)
        CloudTombstones.clear()

        let stamp = CloudDateFormat.date(fromMillis: response.syncedAt) ?? Date()
        lastSyncedAt = stamp
        UserDefaults.standard.set(stamp.timeIntervalSince1970, forKey: Self.lastSyncKey)
    }

    /// Inserts every remote row that is not on this device yet. Local rows win.
    private func adopt(_ response: CloudSyncResponse, context: ModelContext) -> Int {
        let existing = (try? context.fetch(FetchDescriptor<BirthdayProfile>())) ?? []
        var byID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        var restored = 0

        for payload in response.profiles {
            guard let id = UUID(uuidString: payload.id), byID[id] == nil else { continue }
            let profile = Self.makeProfile(from: payload, id: id)
            context.insert(profile)
            byID[id] = profile
            restored += 1
        }

        let knownNotes = Set(
            byID.values.flatMap { $0.diaryEntries.map(\.id) }
        )

        for payload in response.entries {
            guard
                let id = UUID(uuidString: payload.id),
                !knownNotes.contains(id),
                let profileID = UUID(uuidString: payload.profileId),
                let profile = byID[profileID]
            else { continue }

            let note = DiaryEntry(
                textContent: payload.textContent,
                profile: profile,
                id: id,
                createdAt: CloudDateFormat.date(fromMillis: payload.createdAt) ?? Date(),
                authorUserID: payload.authorUserId,
                authorName: payload.authorName,
                isRemote: payload.isRemote
            )
            context.insert(note)
            restored += 1
        }

        if restored > 0 {
            try? context.save()
        }

        return restored
    }

    // MARK: - Mapping

    private static func payload(for profile: BirthdayProfile, at moment: Double) -> CloudProfilePayload {
        let photo = profile.photoData?.base64EncodedString()

        return CloudProfilePayload(
            id: profile.id.uuidString,
            name: profile.name,
            lastName: profile.lastName,
            birthDate: CloudDateFormat.day.string(from: profile.birthDate),
            relationship: profile.relationshipRaw,
            occasion: profile.occasionRaw,
            isSelfProfile: profile.isSelfProfile,
            bond: profile.bondRaw,
            favoriteCharacter: profile.favoriteCharacter,
            address: profile.address,
            contactPhone: profile.contactPhone,
            contactEmail: profile.contactEmail,
            isSurpriseMode: profile.isSurpriseMode,
            photoBase64: (photo?.count ?? 0) <= 1_500_000 ? photo : nil,
            reminderEnabled: profile.isReminderEnabled,
            reminderDaysBefore: profile.reminderDaysBefore,
            giftReminderEnabled: profile.isGiftReminderEnabled,
            giftReminderDaysBefore: profile.giftReminderDaysBefore,
            plan: profile.partyPlan.map(planPayload),
            message: profile.birthdayMessage.map(messagePayload),
            createdAt: CloudDateFormat.millis(profile.createdAt),
            updatedAt: moment,
            deletedAt: nil
        )
    }

    private static func planPayload(_ plan: PartyPlan) -> CloudPlanPayload {
        CloudPlanPayload(
            giftIdea: plan.giftIdea,
            giftCategory: plan.giftCategory,
            giftPriceBand: plan.giftPriceRaw,
            giftReason: plan.giftReason,
            cakeType: plan.cakeType,
            cakeReason: plan.cakeReason,
            venueIdea: plan.venueIdea,
            venueReason: plan.venueReason,
            guestCount: plan.guestCount,
            confidence: plan.confidenceRaw,
            sourceKeywordCount: plan.sourceKeywordCount,
            isManuallyEdited: plan.isManuallyEdited,
            generatedAt: CloudDateFormat.millis(plan.generatedAt),
            confirmedAt: plan.confirmedAt.map(CloudDateFormat.millis)
        )
    }

    private static func messagePayload(_ message: BirthdayMessage) -> CloudMessagePayload {
        CloudMessagePayload(
            text: message.text,
            scheduledAt: CloudDateFormat.millis(message.scheduledAt),
            isScheduleEnabled: message.isScheduleEnabled,
            isSent: message.isSent,
            sentAt: message.sentAt.map(CloudDateFormat.millis),
            tone: message.toneRaw,
            isAutoRefreshEnabled: message.isAutoRefreshEnabled,
            isUserEdited: message.isUserEdited,
            sourceSignature: message.sourceSignature,
            createdAt: CloudDateFormat.millis(message.createdAt),
            updatedAt: CloudDateFormat.millis(message.updatedAt)
        )
    }

    private static func payload(
        for entry: DiaryEntry,
        profileID: UUID,
        at moment: Double
    ) -> CloudEntryPayload {
        CloudEntryPayload(
            id: entry.id.uuidString,
            profileId: profileID.uuidString,
            textContent: entry.textContent,
            authorUserId: entry.authorUserID,
            authorName: entry.authorName,
            isRemote: entry.isRemote,
            createdAt: CloudDateFormat.millis(entry.createdAt),
            updatedAt: moment,
            deletedAt: nil
        )
    }

    private static func makeProfile(from payload: CloudProfilePayload, id: UUID) -> BirthdayProfile {
        let profile = BirthdayProfile(
            name: payload.name,
            birthDate: CloudDateFormat.date(fromDay: payload.birthDate) ?? Date(),
            relationship: RelationshipKind(rawValue: payload.relationship) ?? .friend,
            lastName: payload.lastName,
            address: payload.address,
            contactPhone: payload.contactPhone,
            contactEmail: payload.contactEmail,
            favoriteCharacter: payload.favoriteCharacter,
            photoData: payload.photoBase64.flatMap { Data(base64Encoded: $0) },
            isSurpriseMode: payload.isSurpriseMode,
            occasion: OccasionKind.parse(payload.occasion),
            isSelfProfile: payload.isSelfProfile,
            bond: BondKind.parse(payload.bond)
        )

        profile.id = id
        profile.createdAt = CloudDateFormat.date(fromMillis: payload.createdAt) ?? Date()
        profile.isReminderEnabled = payload.reminderEnabled
        profile.reminderDaysBefore = payload.reminderDaysBefore
        profile.isGiftReminderEnabled = payload.giftReminderEnabled
        profile.giftReminderDaysBefore = payload.giftReminderDaysBefore

        if let plan = payload.plan {
            let restored = PartyPlan(
                suggestion: PartySuggestion(
                    giftIdea: plan.giftIdea,
                    giftCategory: plan.giftCategory,
                    giftPriceBand: PriceBand.parse(plan.giftPriceBand),
                    giftReason: plan.giftReason,
                    cakeType: plan.cakeType,
                    cakeReason: plan.cakeReason,
                    venueIdea: plan.venueIdea,
                    venueReason: plan.venueReason,
                    guestCount: plan.guestCount,
                    confidence: SuggestionConfidence.parse(plan.confidence)
                ),
                keywordCount: plan.sourceKeywordCount,
                profile: profile
            )
            restored.isManuallyEdited = plan.isManuallyEdited
            restored.generatedAt = CloudDateFormat.date(fromMillis: plan.generatedAt) ?? Date()
            restored.confirmedAt = CloudDateFormat.date(fromMillis: plan.confirmedAt)
            profile.partyPlan = restored
        }

        if let message = payload.message {
            let restored = BirthdayMessage(
                text: message.text,
                scheduledAt: CloudDateFormat.date(fromMillis: message.scheduledAt) ?? Date(),
                tone: GreetingTone(rawValue: message.tone) ?? .warm,
                profile: profile
            )
            restored.isScheduleEnabled = message.isScheduleEnabled
            restored.isSent = message.isSent
            restored.sentAt = CloudDateFormat.date(fromMillis: message.sentAt)
            restored.isAutoRefreshEnabled = message.isAutoRefreshEnabled
            restored.isUserEdited = message.isUserEdited
            restored.sourceSignature = message.sourceSignature
            restored.createdAt = CloudDateFormat.date(fromMillis: message.createdAt) ?? Date()
            restored.updatedAt = CloudDateFormat.date(fromMillis: message.updatedAt) ?? Date()
            profile.birthdayMessage = restored
        }

        return profile
    }

    // MARK: - Errors

    private static func message(for error: Error, strings: Strings) -> String {
        let text = String(describing: error).lowercased()

        if text.contains("unknown_code") {
            return strings.cloudUnknownCodeMessage
        }
        if text.contains("invalid_code") {
            return strings.cloudInvalidCodeMessage
        }

        // Keep the console useful without leaking the recovery code.
        print("Cloud backup failed: \(error)")
        return strings.cloudGenericErrorMessage
    }
}
