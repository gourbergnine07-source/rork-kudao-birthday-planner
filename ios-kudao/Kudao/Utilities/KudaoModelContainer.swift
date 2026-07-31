//
//  KudaoModelContainer.swift
//  Kudao
//

import Foundation
import SwiftData

/// Builds the app's SwiftData container.
///
/// The schema grows as features ship (diary tags, party plans, ...). If an older
/// on-device store cannot be migrated automatically, SwiftData throws and the app
/// would crash on launch. Instead of crashing we rebuild the store from scratch,
/// and as a last resort fall back to an in-memory container so the UI still works.
enum KudaoModelContainer {
    static let schema = Schema([
        BirthdayProfile.self,
        DiaryEntry.self,
        DiaryTag.self,
        PartyPlan.self,
    ])

    static func make() -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        if let container = try? ModelContainer(for: schema, configurations: configuration) {
            return container
        }

        resetStoreFiles(at: configuration.url)

        if let container = try? ModelContainer(for: schema, configurations: configuration) {
            return container
        }

        // Never crash: an ephemeral store is better than a dead launch.
        // swiftlint:disable:next force_try
        return try! ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        )
    }

    /// Removes the SQLite store together with its write-ahead log and shared memory files.
    private static func resetStoreFiles(at url: URL) {
        let manager = FileManager.default
        let companions = ["", "-wal", "-shm"].map { suffix in
            url.deletingLastPathComponent()
                .appendingPathComponent(url.lastPathComponent + suffix)
        }

        for file in companions where manager.fileExists(atPath: file.path) {
            try? manager.removeItem(at: file)
        }
    }

    /// Fresh in-memory container used by SwiftUI previews.
    static func preview() -> ModelContainer {
        // swiftlint:disable:next force_try
        try! ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        )
    }
}
