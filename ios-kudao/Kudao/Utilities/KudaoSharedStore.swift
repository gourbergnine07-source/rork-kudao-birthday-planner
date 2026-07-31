//
//  KudaoSharedStore.swift
//  Kudao
//

import Foundation

/// Storage shared with the home-screen widget.
///
/// Reading data from a widget extension requires an App Group entitlement, and a
/// build signed with an App Group its provisioning profile does not declare is
/// refused by iOS at install time. While the group is not provisioned we keep the
/// same plumbing but fall back to the app's own container, so the countdown
/// snapshot is still written and nothing else in the app breaks.
nonisolated enum KudaoSharedStore {
    static let appGroupID = "group.app.rork.ek3qfxdplwz49ny1h3a7x.kudao"
    static let snapshotFileName = "widget-countdown.json"

    /// True when the App Group container is actually available to this build.
    static var isAppGroupAvailable: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil
    }

    /// App Group defaults when the group exists, the app's own defaults otherwise.
    static var defaults: UserDefaults {
        guard isAppGroupAvailable, let shared = UserDefaults(suiteName: appGroupID) else {
            return .standard
        }
        return shared
    }

    /// Where the countdown snapshot lives: App Group container first, local support directory otherwise.
    static var snapshotURL: URL? {
        if let container = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            return container.appendingPathComponent(snapshotFileName)
        }
        return localSnapshotURL
    }

    private static var localSnapshotURL: URL? {
        try? FileManager.default
            .url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent(snapshotFileName)
    }

    static func set(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}
