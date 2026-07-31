//
//  ProfileShare.swift
//  Kudao
//

import Foundation
import SwiftData

/// One row of the `profile_shares` table: who has access to a profile and how.
///
/// Both sides of a collaboration keep the same list locally, refreshed from the
/// share room on every sync. Pending rows (`isPending`) are invite codes that
/// have been generated but not claimed yet.
@Model
final class ProfileShare {
    var id: UUID = UUID()
    /// Local profile this access refers to.
    var profileID: UUID = UUID()
    /// Kudao user id of the participant; empty while the invite is unclaimed.
    var sharedWithUserID: String = ""
    var sharedWithName: String = ""
    var permissionRaw: String = SharePermission.view.rawValue
    var invitedAt: Date = Date()
    var acceptedAt: Date?
    /// True for the original owner of the profile, who can never be removed.
    var isOwner: Bool = false
    /// Invite code, kept so the owner can re-share a pending invitation.
    var inviteCode: String = ""

    init(
        profileID: UUID,
        sharedWithUserID: String,
        sharedWithName: String,
        permission: SharePermission,
        invitedAt: Date = Date(),
        acceptedAt: Date? = nil,
        isOwner: Bool = false,
        inviteCode: String = ""
    ) {
        self.id = UUID()
        self.profileID = profileID
        self.sharedWithUserID = sharedWithUserID
        self.sharedWithName = sharedWithName
        self.permissionRaw = permission.rawValue
        self.invitedAt = invitedAt
        self.acceptedAt = acceptedAt
        self.isOwner = isOwner
        self.inviteCode = inviteCode
    }

    var permission: SharePermission {
        get { SharePermission.parse(permissionRaw) }
        set { permissionRaw = newValue.rawValue }
    }

    /// An invite that nobody has opened yet.
    var isPending: Bool { acceptedAt == nil }

    var displayName: String {
        sharedWithName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
