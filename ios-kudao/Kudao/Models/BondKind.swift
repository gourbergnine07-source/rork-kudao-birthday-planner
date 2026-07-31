//
//  BondKind.swift
//  Kudao
//

import SwiftUI

/// The tie between the user and a person they are remembering.
///
/// A remembrance profile replaces the festive "relazione" picker with this one:
/// same idea, sober vocabulary, no party framing.
nonisolated enum BondKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case parent
    case grandparent
    case sibling
    case spouse
    case child
    case friend
    case other

    var id: String { rawValue }

    static func parse(_ raw: String?) -> BondKind {
        BondKind(rawValue: (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) ?? .other
    }

    var symbolName: String {
        switch self {
        case .parent: "figure.and.child.holdinghands"
        case .grandparent: "figure.walk.motion"
        case .sibling: "figure.2"
        case .spouse: "heart.fill"
        case .child: "figure.child"
        case .friend: "hands.clap.fill"
        case .other: "person.fill"
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .parent: strings.bondParent
        case .grandparent: strings.bondGrandparent
        case .sibling: strings.bondSibling
        case .spouse: strings.bondSpouse
        case .child: strings.bondChild
        case .friend: strings.bondFriend
        case .other: strings.bondOther
        }
    }

    /// English wording handed to the model inside a prompt.
    var promptLabel: String {
        switch self {
        case .parent: "parent"
        case .grandparent: "grandparent"
        case .sibling: "sibling"
        case .spouse: "spouse or life partner"
        case .child: "child"
        case .friend: "close friend"
        case .other: "loved one"
        }
    }
}
