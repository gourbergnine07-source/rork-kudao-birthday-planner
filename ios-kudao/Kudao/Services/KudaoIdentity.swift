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

    /// Stable, anonymous id for this device.
    let userID: String

    var displayName: String {
        didSet {
            let cleaned = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard cleaned != oldValue.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            UserDefaults.standard.set(cleaned, forKey: Self.displayNameKey)
        }
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
