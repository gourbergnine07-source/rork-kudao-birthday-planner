//
//  KudaoIdentity.swift
//  Kudao
//

import Foundation
import Observation

/// The device's lightweight Kudao identity used by collaborative profiles.
///
/// Sharing needs a stable id per person plus a name their friends recognise.
/// Nothing else is collected, and the id never leaves the share rooms the user
/// explicitly joins.
@Observable
final class KudaoIdentity {
    static let shared = KudaoIdentity()

    private static let userIDKey = "kudao.identity.userID"
    private static let displayNameKey = "kudao.identity.displayName"
    private static let photoFileName = "kudao-me.jpg"

    /// Stable, anonymous id for this device.
    let userID: String

    var displayName: String {
        didSet {
            let cleaned = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard cleaned != oldValue.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            UserDefaults.standard.set(cleaned, forKey: Self.displayNameKey)
        }
    }

    /// The user's own avatar, kept as a compressed JPEG next to the app data.
    var photoData: Data? {
        didSet { Self.persist(photoData) }
    }

    init() {
        let defaults = UserDefaults.standard

        if let stored = defaults.string(forKey: Self.userIDKey), !stored.isEmpty {
            userID = stored
        } else {
            let fresh = UUID().uuidString
            defaults.set(fresh, forKey: Self.userIDKey)
            userID = fresh
        }

        displayName = defaults.string(forKey: Self.displayNameKey) ?? ""
        photoData = Self.photoURL.flatMap { try? Data(contentsOf: $0) }
    }

    // MARK: - Avatar storage

    private static var photoURL: URL? {
        let directory = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return directory?.appendingPathComponent(photoFileName)
    }

    private static func persist(_ data: Data?) {
        guard let url = photoURL else { return }
        if let data {
            try? data.write(to: url, options: .atomic)
        } else {
            try? FileManager.default.removeItem(at: url)
        }
    }

    var trimmedName: String {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasName: Bool { !trimmedName.isEmpty }

    /// Name sent to the share room; never empty so participant lists stay readable.
    func outgoingName(_ strings: Strings) -> String {
        hasName ? trimmedName : strings.participantYou
    }
}
