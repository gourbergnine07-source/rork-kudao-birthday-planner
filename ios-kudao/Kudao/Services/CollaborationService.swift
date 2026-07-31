//
//  CollaborationService.swift
//  Kudao
//

import Foundation
import Observation
import SwiftData

/// Keeps a shared profile in step with its share room.
///
/// The owner publishes the profile snapshot plus their own diary notes; every
/// participant pulls the merged room state (participants, notes, votes). All
/// remote state is mirrored into SwiftData so the UI keeps working offline.
@Observable
final class CollaborationService {
    /// Room ids currently syncing, so several profiles can refresh independently.
    private(set) var syncingRooms: Set<String> = []
    private(set) var errorMessage: String?
    /// Bumped after every successful merge so views can refresh derived state.
    private(set) var revision: Int = 0

    func isSyncing(_ profile: BirthdayProfile) -> Bool {
        syncingRooms.contains(profile.roomID)
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Owner: create an invite

    /// Registers the share room (idempotent) and returns a fresh invite code.
    func createInvite(
        for profile: BirthdayProfile,
        permission: SharePermission,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async -> String? {
        let roomID = profile.roomID
        let ownerName = identity.outgoingName(strings)
        errorMessage = nil
        syncingRooms.insert(roomID)
        defer { syncingRooms.remove(roomID) }

        do {
            let invite = try await ShareClient.createInvite(
                profileID: roomID,
                ownerUserID: identity.userID,
                ownerName: ownerName,
                permission: permission,
                snapshot: Self.snapshot(of: profile)
            )

            profile.shareOwnerUserID = identity.userID
            profile.shareOwnerName = ownerName
            profile.remoteProfileID = roomID
            if profile.sharedAt == nil { profile.sharedAt = Date() }

            upsertShare(
                profileID: profile.id,
                userID: "",
                name: "",
                permission: SharePermission.parse(invite.permission),
                invitedAt: Self.date(invite.invitedAt),
                acceptedAt: nil,
                isOwner: false,
                code: invite.code,
                context: context
            )
            try? context.save()

            // Pull the merged state straight away so the participant list is live.
            await sync(profile: profile, identity: identity, strings: strings, context: context)
            return invite.code
        } catch {
            errorMessage = Self.message(error, strings)
            return nil
        }
    }

    // MARK: - Guest: join with a code

    /// Claims an invite code and creates the local mirror of the shared profile.
    func join(
        code: String,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async -> BirthdayProfile? {
        let cleaned = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleaned.isEmpty else { return nil }

        errorMessage = nil
        syncingRooms.insert(cleaned)
        defer { syncingRooms.remove(cleaned) }

        do {
            let state = try await ShareClient.join(
                code: cleaned,
                userID: identity.userID,
                userName: identity.outgoingName(strings)
            )

            let existing = (try? context.fetch(FetchDescriptor<BirthdayProfile>()))?
                .first { $0.remoteProfileID == state.profileId && $0.isSharedMirror }

            let mirror: BirthdayProfile
            if let existing {
                mirror = existing
            } else {
                let snapshot = state.snapshot
                mirror = BirthdayProfile(
                    name: snapshot?.name ?? strings.sharedProfileFallbackName,
                    birthDate: Self.date(snapshot?.birthDate ?? Date().timeIntervalSince1970 * 1000),
                    relationship: RelationshipKind(rawValue: snapshot?.relationship ?? "") ?? .friend
                )
                mirror.remoteProfileID = state.profileId
                context.insert(mirror)
            }

            mirror.sharedPermissionRaw = SharePermission.parse(state.permission).rawValue
            mirror.sharedAt = mirror.sharedAt ?? Date()
            apply(state: state, to: mirror, identity: identity, context: context)
            try? context.save()
            return mirror
        } catch {
            errorMessage = Self.message(error, strings)
            return nil
        }
    }

    // MARK: - Sync

    /// Owners publish then pull; guests only pull.
    func sync(
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async {
        guard profile.isCollaborative else { return }
        let roomID = profile.roomID
        guard !syncingRooms.contains(roomID) || profile.isOwnedByMe else { return }

        syncingRooms.insert(roomID)
        defer { syncingRooms.remove(roomID) }

        do {
            let state: RoomState
            if profile.isOwnedByMe {
                state = try await ShareClient.pushSnapshot(
                    roomID: roomID,
                    ownerUserID: identity.userID,
                    ownerName: identity.outgoingName(strings),
                    snapshot: Self.snapshot(of: profile),
                    notes: Self.outgoingNotes(of: profile, userID: identity.userID)
                )
            } else {
                state = try await ShareClient.state(roomID: roomID, userID: identity.userID)
            }

            apply(state: state, to: profile, identity: identity, context: context)
            try? context.save()
            errorMessage = nil
        } catch {
            errorMessage = Self.message(error, strings)
        }
    }

    // MARK: - Contributions

    /// Publishes a note the current user just wrote locally.
    func publish(
        note: DiaryEntry,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings
    ) async {
        guard profile.isCollaborative, profile.canContribute else { return }

        do {
            try await ShareClient.addNote(
                roomID: profile.roomID,
                userID: identity.userID,
                userName: identity.outgoingName(strings),
                note: OutgoingNote(
                    id: note.id.uuidString,
                    text: note.textContent,
                    createdAt: note.createdAt.timeIntervalSince1970 * 1000
                )
            )
        } catch {
            errorMessage = Self.message(error, strings)
        }
    }

    /// Removes a note from the room: guests may delete their own, owners any.
    func retract(
        noteID: UUID,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings
    ) async {
        guard profile.isCollaborative else { return }

        do {
            try await ShareClient.deleteNote(
                roomID: profile.roomID,
                userID: identity.userID,
                noteID: noteID.uuidString
            )
        } catch {
            errorMessage = Self.message(error, strings)
        }
    }

    /// Casts (or clears) the current user's vote on one plan card.
    func setVote(
        card: PlanSection,
        value: Int,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async {
        guard profile.isCollaborative, profile.canContribute else { return }

        // Optimistic local update so the tap feels instant.
        let existing = votes(for: profile, context: context).filter {
            $0.cardRaw == card.rawValue && $0.userID == identity.userID
        }
        for vote in existing { context.delete(vote) }

        if value != 0 {
            context.insert(
                SuggestionVote(
                    profileID: profile.id,
                    card: card,
                    userID: identity.userID,
                    userName: identity.outgoingName(strings),
                    value: value
                )
            )
        }
        try? context.save()
        revision += 1

        do {
            try await ShareClient.vote(
                roomID: profile.roomID,
                userID: identity.userID,
                userName: identity.outgoingName(strings),
                card: card,
                value: value
            )
            await sync(profile: profile, identity: identity, strings: strings, context: context)
        } catch {
            errorMessage = Self.message(error, strings)
        }
    }

    /// Owner-only: revokes one participant's access.
    func removeParticipant(
        userID: String,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async {
        guard profile.isOwnedByMe, userID != identity.userID else { return }

        do {
            let state = try await ShareClient.removeParticipant(
                roomID: profile.roomID,
                ownerUserID: identity.userID,
                targetUserID: userID
            )
            apply(state: state, to: profile, identity: identity, context: context)
            try? context.save()
        } catch {
            errorMessage = Self.message(error, strings)
        }
    }

    /// Drops a pending invite locally once the owner stops offering it.
    func discardPendingInvite(code: String, profile: BirthdayProfile, context: ModelContext) {
        for share in shares(for: profile, context: context) where share.inviteCode == code && share.isPending {
            context.delete(share)
        }
        try? context.save()
        revision += 1
    }

    // MARK: - Merge

    private func apply(
        state: RoomState,
        to profile: BirthdayProfile,
        identity: KudaoIdentity,
        context: ModelContext
    ) {
        profile.shareOwnerUserID = state.ownerUserId
        profile.shareOwnerName = state.ownerName
        profile.remoteProfileID = state.profileId
        profile.lastSyncedAt = Date()
        if profile.sharedAt == nil { profile.sharedAt = Date() }

        if !state.isOwner {
            profile.sharedPermissionRaw = SharePermission.parse(state.permission).rawValue
            if let snapshot = state.snapshot {
                applySnapshot(snapshot, to: profile, context: context)
            }
        }

        mergeParticipants(state, profile: profile, context: context)
        mergeNotes(state, profile: profile, identity: identity, context: context)
        mergeVotes(state, profile: profile, context: context)
        revision += 1
    }

    /// Guests keep a read-only copy of the profile data and of the party plan.
    private func applySnapshot(_ snapshot: ProfileSnapshot, to profile: BirthdayProfile, context: ModelContext) {
        profile.name = snapshot.name
        profile.lastName = snapshot.lastName
        profile.birthDate = Self.date(snapshot.birthDate)
        profile.relationshipRaw = RelationshipKind(rawValue: snapshot.relationship)?.rawValue
            ?? RelationshipKind.friend.rawValue
        profile.isSurpriseMode = snapshot.isSurpriseMode

        if let base64 = snapshot.photoBase64, let data = Data(base64Encoded: base64) {
            profile.photoData = data
        }

        guard let plan = snapshot.plan else { return }

        let suggestion = PartySuggestion(
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
        )

        if let existing = profile.partyPlan {
            existing.apply(suggestion)
            existing.sourceKeywordCount = plan.keywordCount
            existing.confirmedAt = plan.isConfirmed ? (existing.confirmedAt ?? Date()) : nil
        } else {
            let created = PartyPlan(suggestion: suggestion, keywordCount: plan.keywordCount, profile: profile)
            if plan.isConfirmed { created.confirmedAt = Date() }
            context.insert(created)
            profile.partyPlan = created
        }
    }

    private func mergeParticipants(_ state: RoomState, profile: BirthdayProfile, context: ModelContext) {
        let local = shares(for: profile, context: context)
        var remaining = local

        for participant in state.participants {
            let match = remaining.first { $0.sharedWithUserID == participant.userId }
            if let match {
                match.sharedWithName = participant.name
                match.permission = SharePermission.parse(participant.permission)
                match.invitedAt = Self.date(participant.invitedAt)
                match.acceptedAt = participant.acceptedAt.map(Self.date)
                match.isOwner = participant.isOwner
                remaining.removeAll { $0 === match }
            } else {
                context.insert(
                    ProfileShare(
                        profileID: profile.id,
                        sharedWithUserID: participant.userId,
                        sharedWithName: participant.name,
                        permission: SharePermission.parse(participant.permission),
                        invitedAt: Self.date(participant.invitedAt),
                        acceptedAt: participant.acceptedAt.map(Self.date),
                        isOwner: participant.isOwner
                    )
                )
            }
        }

        for invite in state.pendingInvites {
            let match = remaining.first { $0.inviteCode == invite.code && $0.sharedWithUserID.isEmpty }
            if let match {
                match.permission = SharePermission.parse(invite.permission)
                match.invitedAt = Self.date(invite.invitedAt)
                match.acceptedAt = nil
                remaining.removeAll { $0 === match }
            } else {
                context.insert(
                    ProfileShare(
                        profileID: profile.id,
                        sharedWithUserID: "",
                        sharedWithName: "",
                        permission: SharePermission.parse(invite.permission),
                        invitedAt: Self.date(invite.invitedAt),
                        acceptedAt: nil,
                        isOwner: false,
                        inviteCode: invite.code
                    )
                )
            }
        }

        // Anything the room no longer knows about has been revoked or claimed.
        for stale in remaining { context.delete(stale) }
    }

    private func mergeNotes(
        _ state: RoomState,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        context: ModelContext
    ) {
        let serverNotes = state.notes
        let serverIDs = Set(serverNotes.compactMap { UUID(uuidString: $0.id) })
        let localNotes = profile.diaryEntries

        for note in serverNotes {
            guard let uuid = UUID(uuidString: note.id) else { continue }
            let isMine = note.authorId == identity.userID

            if let existing = localNotes.first(where: { $0.id == uuid }) {
                existing.textContent = note.text
                existing.authorUserID = note.authorId
                existing.authorName = note.authorName
                existing.isRemote = !isMine
                continue
            }

            // Someone else's note (or my own note seen from a second device).
            let imported = DiaryEntry(
                textContent: note.text,
                profile: profile,
                id: uuid,
                createdAt: Self.date(note.createdAt),
                authorUserID: note.authorId,
                authorName: note.authorName,
                isRemote: !isMine
            )
            context.insert(imported)
        }

        // Remote-authored notes that disappeared upstream disappear here too.
        for note in localNotes where note.isRemote && !serverIDs.contains(note.id) {
            context.delete(note)
        }
    }

    private func mergeVotes(_ state: RoomState, profile: BirthdayProfile, context: ModelContext) {
        for vote in votes(for: profile, context: context) {
            context.delete(vote)
        }

        for vote in state.votes {
            guard let card = PlanSection(rawValue: vote.card), vote.value != 0 else { continue }
            context.insert(
                SuggestionVote(
                    profileID: profile.id,
                    card: card,
                    userID: vote.userId,
                    userName: vote.userName,
                    value: vote.value > 0 ? 1 : -1,
                    updatedAt: Self.date(vote.updatedAt)
                )
            )
        }
    }

    /// Inserts or refreshes one local share row, matching by user id or invite code.
    private func upsertShare(
        profileID: UUID,
        userID: String,
        name: String,
        permission: SharePermission,
        invitedAt: Date,
        acceptedAt: Date?,
        isOwner: Bool,
        code: String,
        context: ModelContext
    ) {
        let all = (try? context.fetch(FetchDescriptor<ProfileShare>())) ?? []
        let match = all.first { share in
            guard share.profileID == profileID else { return false }
            if !userID.isEmpty { return share.sharedWithUserID == userID }
            return share.sharedWithUserID.isEmpty && !code.isEmpty && share.inviteCode == code
        }

        if let match {
            match.sharedWithName = name
            match.permission = permission
            match.invitedAt = invitedAt
            match.acceptedAt = acceptedAt
            match.isOwner = isOwner
            if !code.isEmpty { match.inviteCode = code }
            return
        }

        context.insert(
            ProfileShare(
                profileID: profileID,
                sharedWithUserID: userID,
                sharedWithName: name,
                permission: permission,
                invitedAt: invitedAt,
                acceptedAt: acceptedAt,
                isOwner: isOwner,
                inviteCode: code
            )
        )
    }

    // MARK: - Local lookups

    func shares(for profile: BirthdayProfile, context: ModelContext) -> [ProfileShare] {
        let all = (try? context.fetch(FetchDescriptor<ProfileShare>())) ?? []
        return all.filter { $0.profileID == profile.id }
    }

    func votes(for profile: BirthdayProfile, context: ModelContext) -> [SuggestionVote] {
        let all = (try? context.fetch(FetchDescriptor<SuggestionVote>())) ?? []
        return all.filter { $0.profileID == profile.id }
    }

    /// Tally for one card, including what the current user voted.
    func tally(
        for card: PlanSection,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        context: ModelContext
    ) -> VoteTally {
        var tally = VoteTally()
        for vote in votes(for: profile, context: context) where vote.cardRaw == card.rawValue {
            if vote.isUp { tally.up += 1 } else { tally.down += 1 }
            if vote.userID == identity.userID { tally.mine = vote.value }
        }
        return tally
    }

    // MARK: - Snapshots

    /// Photos above this size are dropped: the room row limit is 2 MB.
    private static let maxPhotoBytes = 500_000

    static func snapshot(of profile: BirthdayProfile) -> ProfileSnapshot {
        let photo: String? = {
            guard let data = profile.photoData, data.count <= maxPhotoBytes else { return nil }
            return data.base64EncodedString()
        }()

        let plan: PlanSnapshot? = profile.partyPlan.map { plan in
            PlanSnapshot(
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
                isConfirmed: plan.isConfirmed,
                keywordCount: plan.sourceKeywordCount
            )
        }

        return ProfileSnapshot(
            name: profile.name,
            lastName: profile.lastName,
            birthDate: profile.birthDate.timeIntervalSince1970 * 1000,
            relationship: profile.relationshipRaw,
            isSurpriseMode: profile.isSurpriseMode,
            photoBase64: photo,
            plan: plan
        )
    }

    private static func outgoingNotes(of profile: BirthdayProfile, userID: String) -> [OutgoingNote] {
        profile.diaryEntries
            .filter { !$0.isRemote && $0.isMine(userID) }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(300)
            .map {
                OutgoingNote(
                    id: $0.id.uuidString,
                    text: $0.textContent,
                    createdAt: $0.createdAt.timeIntervalSince1970 * 1000
                )
            }
    }

    // MARK: - Helpers

    private static func date(_ milliseconds: Double) -> Date {
        Date(timeIntervalSince1970: milliseconds / 1000)
    }

    private static func message(_ error: Error, _ strings: Strings) -> String {
        (error as? ShareError ?? .server).message(strings)
    }
}
