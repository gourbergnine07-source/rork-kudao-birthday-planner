//
//  GalleryTimeline.swift
//  Kudao
//

import Foundation

/// One day of memories in the gallery timeline.
struct GalleryDaySection: Identifiable {
    /// Start of the day, which is also a stable identity for the section.
    let id: Date
    /// Memories of that day, newest first.
    let items: [GalleryItem]

    var count: Int { items.count }
}

/// Organises a gallery as a reverse-chronological timeline.
///
/// The gallery never asks the user to sort anything: the newest memory is
/// always on top and everything is grouped by the day it was taken, the way a
/// camera roll reads.
enum GalleryTimeline {
    /// Every memory, newest first, with the remote id as a stable tiebreaker.
    static func ordered(_ items: [GalleryItem]) -> [GalleryItem] {
        items.sorted { lhs, rhs in
            if lhs.createdAt == rhs.createdAt {
                return lhs.remoteID > rhs.remoteID
            }
            return lhs.createdAt > rhs.createdAt
        }
    }

    /// The same memories grouped by day, most recent day first.
    static func sections(_ items: [GalleryItem], calendar: Calendar = .current) -> [GalleryDaySection] {
        let grouped = Dictionary(grouping: ordered(items)) {
            calendar.startOfDay(for: $0.createdAt)
        }

        return grouped
            .map { GalleryDaySection(id: $0.key, items: $0.value) }
            .sorted { $0.id > $1.id }
    }
}
