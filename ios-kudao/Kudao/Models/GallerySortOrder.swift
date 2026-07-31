//
//  GallerySortOrder.swift
//  Kudao
//

import Foundation

/// Chronological order of the memories in a party gallery.
nonisolated enum GallerySortOrder: String, CaseIterable, Identifiable, Sendable {
    /// Most recent memory first, the way a camera roll opens.
    case newestFirst
    /// Oldest first, so the evening replays in the order it happened.
    case oldestFirst

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .newestFirst: "arrow.down.to.line"
        case .oldestFirst: "arrow.up.to.line"
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .newestFirst: strings.gallerySortNewest
        case .oldestFirst: strings.gallerySortOldest
        }
    }

    /// Applies the order, keeping the item id as a tiebreaker for stability.
    func sorted(_ items: [GalleryItem]) -> [GalleryItem] {
        items.sorted { lhs, rhs in
            if lhs.createdAt == rhs.createdAt {
                return lhs.remoteID < rhs.remoteID
            }
            return self == .newestFirst
                ? lhs.createdAt > rhs.createdAt
                : lhs.createdAt < rhs.createdAt
        }
    }

    static func parse(_ raw: String?) -> GallerySortOrder {
        GallerySortOrder(rawValue: raw ?? "") ?? .newestFirst
    }
}
