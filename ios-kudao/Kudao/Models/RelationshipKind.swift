//
//  RelationshipKind.swift
//  Kudao
//

import SwiftUI

/// The kind of bond between the app owner and the celebrated person.
nonisolated enum RelationshipKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case friend
    case family
    case partner
    case colleague

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .friend: "figure.2"
        case .family: "house.fill"
        case .partner: "heart.fill"
        case .colleague: "briefcase.fill"
        }
    }
}

extension RelationshipKind {
    @MainActor
    var accent: Color {
        switch self {
        case .friend: Palette.amber
        case .family: Palette.berry
        case .partner: Palette.coral
        case .colleague: Palette.clay
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .friend: strings.relFriend
        case .family: strings.relFamily
        case .partner: strings.relPartner
        case .colleague: strings.relColleague
        }
    }
}
