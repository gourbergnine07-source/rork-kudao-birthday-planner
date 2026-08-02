//
//  WidgetBridge.swift
//  Kudao
//

import Foundation
import OSLog
import SwiftData
import WidgetKit

/// One upcoming birthday as the widget needs it: no SwiftData, no photos, no diary.
nonisolated struct WidgetCountdownEntry: Codable, Sendable, Equatable {
    let id: String
    /// Already masked when the profile is a protected surprise, so the widget never holds the real name.
    let name: String
    let initials: String
    let birthDate: Date
    let isMasked: Bool
    let relationshipRaw: String
    /// Optional so a snapshot written by an older build still decodes.
    let hidesAge: Bool?
}

/// Payload written into the App Group container and read back by the widget.
nonisolated struct WidgetCountdownSnapshot: Codable, Sendable, Equatable {
    let languageCode: String
    let generatedAt: Date
    let entries: [WidgetCountdownEntry]
}

/// Publishes the nearest birthdays into the App Group so the widget can render them.
///
/// The widget recomputes the remaining days itself from `birthDate`, so a stale
/// snapshot still shows a correct countdown.
nonisolated enum WidgetBridge {
    private static let logger = Logger(subsystem: "com.kudao.app", category: "widget")
    private static let maxEntries = 5

    /// Writes the snapshot and asks WidgetKit for a reload. Cheap enough to call on every change.
    static func publish(profiles: [BirthdayProfile], settings: AppSettings) {
        let masked = Set(
            profiles
                .filter { settings.masksIdentity(of: $0) }
                .map(\.id)
        )
        let placeholder = settings.strings.maskedProfileName

        let entries = profiles
            .filter { !$0.isDeleted && !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
            .sorted { lhs, rhs in
                let left = lhs.countdown.daysRemaining
                let right = rhs.countdown.daysRemaining
                return left == right ? lhs.name < rhs.name : left < right
            }
            .prefix(maxEntries)
            .map { profile -> WidgetCountdownEntry in
                let hidden = masked.contains(profile.id)
                return WidgetCountdownEntry(
                    id: profile.id.uuidString,
                    name: hidden ? placeholder : profile.name,
                    initials: hidden ? "?" : profile.initials,
                    birthDate: profile.birthDate,
                    isMasked: hidden,
                    relationshipRaw: profile.relationshipRaw,
                    hidesAge: profile.hasUnknownBirthYear
                )
            }

        let snapshot = WidgetCountdownSnapshot(
            languageCode: settings.language.rawValue,
            generatedAt: Date(),
            entries: Array(entries)
        )

        write(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private static func write(_ snapshot: WidgetCountdownSnapshot) {
        guard let url = KudaoSharedStore.snapshotURL else {
            logger.warning("App Group container unavailable, widget snapshot skipped")
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            try encoder.encode(snapshot).write(to: url, options: .atomic)
        } catch {
            logger.error("Writing the widget snapshot failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
