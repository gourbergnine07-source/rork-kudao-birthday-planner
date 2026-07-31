//
//  SharePermission.swift
//  Kudao
//

import SwiftUI

/// What an invited collaborator may do inside a shared profile.
nonisolated enum SharePermission: String, Codable, CaseIterable, Identifiable, Sendable {
    /// Read-only: sees the profile, the diary and the plan, cannot change anything.
    case view
    /// Can add diary notes and vote on the suggestion cards.
    case edit

    var id: String { rawValue }

    static func parse(_ raw: String) -> SharePermission {
        SharePermission(rawValue: raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) ?? .view
    }

    var symbolName: String {
        switch self {
        case .view: "eye.fill"
        case .edit: "square.and.pencil"
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .view: strings.permissionViewTitle
        case .edit: strings.permissionEditTitle
        }
    }

    func caption(_ strings: Strings) -> String {
        switch self {
        case .view: strings.permissionViewCaption
        case .edit: strings.permissionEditCaption
        }
    }

    @MainActor
    var accent: Color {
        switch self {
        case .view: Palette.teal
        case .edit: Palette.violet
        }
    }
}
