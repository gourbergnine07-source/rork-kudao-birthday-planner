//
//  SharingPolicy.swift
//  Kudao
//

import Foundation
import SwiftData

/// Single place deciding what may leave the device.
///
/// Sharing with the birthday person is not built yet, but every future entry
/// point must ask here first so surprise profiles can never leak.
nonisolated enum SharingPolicy {
    /// A surprise profile is never shareable with the person it celebrates.
    static func canShareWithCelebrant(_ profile: BirthdayProfile) -> Bool {
        !profile.isSurpriseMode
    }

    /// Filters a list before it is offered to any celebrant-facing feature.
    static func shareableWithCelebrant(_ profiles: [BirthdayProfile]) -> [BirthdayProfile] {
        profiles.filter(canShareWithCelebrant)
    }

    /// Collaborative sharing sends the profile to another Kudao user, so a
    /// protected surprise profile must stay on this device only.
    static func canShareWithCollaborators(isSurprise: Bool, protectsSurprises: Bool) -> Bool {
        !(isSurprise && protectsSurprises)
    }

    /// Owner-facing exports (PDF/JSON, share sheet) stay allowed: the data never
    /// reaches the celebrant, it goes to the person planning the party.
    static func canExportForOwner(_ profile: BirthdayProfile) -> Bool {
        !profile.isDeleted
    }
}
