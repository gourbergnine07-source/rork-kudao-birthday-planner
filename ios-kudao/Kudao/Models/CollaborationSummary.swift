//
//  CollaborationSummary.swift
//  Kudao
//

import Foundation

/// Who is around a profile, flattened for the list cards.
///
/// The home screen reads every `ProfileShare` once and hands each card its own
/// summary, so the cards stay free of SwiftData queries and of the service.
struct CollaborationSummary: Equatable {
    /// True once the profile lives in a share room, on either side of it.
    let isCollaborative: Bool
    /// True when somebody else owns the profile and I joined with a code.
    let isMirror: Bool
    /// Display name of the owner, only meaningful for a mirror.
    let ownerName: String
    /// What I am allowed to do here.
    let permission: SharePermission
    /// Everyone who accepted, owner first.
    let participantNames: [String]
    /// Invite codes generated but not claimed yet.
    let pendingInvites: Int

    static let none = CollaborationSummary(
        isCollaborative: false,
        isMirror: false,
        ownerName: "",
        permission: .edit,
        participantNames: [],
        pendingInvites: 0
    )

    var participantCount: Int { participantNames.count }

    /// A shared profile nobody has joined yet still counts as collaborative.
    var hasCompany: Bool { participantCount > 1 }

    /// Short line describing the collaboration: "Shared by Marco" or "4 participants".
    func caption(_ strings: Strings) -> String {
        if isMirror {
            let owner = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
            return owner.isEmpty
                ? strings.sharedBadge
                : String(format: strings.sharedByFormat, owner)
        }
        if hasCompany {
            return String(format: strings.participantsCountFormat, participantCount)
        }
        if pendingInvites > 0 {
            return String(format: strings.pendingInvitesCountFormat, pendingInvites)
        }
        return strings.collaborationOnlyYou
    }

    /// Builds one summary per profile from the flat list of share rows.
    static func map(
        profiles: [BirthdayProfile],
        shares: [ProfileShare]
    ) -> [UUID: CollaborationSummary] {
        guard !profiles.isEmpty else { return [:] }

        var grouped: [UUID: [ProfileShare]] = [:]
        for share in shares {
            grouped[share.profileID, default: []].append(share)
        }

        var result: [UUID: CollaborationSummary] = [:]
        for profile in profiles where profile.isCollaborative {
            let rows = grouped[profile.id] ?? []

            let accepted = rows
                .filter { !$0.sharedWithUserID.isEmpty }
                .sorted { lhs, rhs in
                    if lhs.isOwner != rhs.isOwner { return lhs.isOwner }
                    return lhs.invitedAt < rhs.invitedAt
                }
                .map(\.displayName)

            let pending = rows.filter { $0.sharedWithUserID.isEmpty && !$0.inviteCode.isEmpty }.count

            result[profile.id] = CollaborationSummary(
                isCollaborative: true,
                isMirror: profile.isSharedMirror,
                ownerName: profile.shareOwnerName,
                permission: profile.myPermission,
                participantNames: accepted,
                pendingInvites: pending
            )
        }
        return result
    }
}
