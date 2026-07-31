//
//  KudaoSharedStore.swift
//  Kudao
//

import Foundation

/// The App Group shared between the app and the home-screen widget.
nonisolated enum KudaoSharedStore {
    static let appGroupID = "group.app.rork.ek3qfxdplwz49ny1h3a7x.kudao"
    static let snapshotFileName = "widget-countdown.json"

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    /// App Group container URL of the widget snapshot file, when the group is available.
    static var snapshotURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(snapshotFileName)
    }

    static func set(_ value: Bool, forKey key: String) {
        defaults?.set(value, forKey: key)
    }
}
