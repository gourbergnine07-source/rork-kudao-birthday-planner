//
//  BiometricGate.swift
//  Kudao
//

import Foundation
import LocalAuthentication
import Observation
import OSLog

/// Which local authentication the device can offer.
nonisolated enum BiometryKind: Sendable {
    case faceID
    case touchID
    case opticID
    case passcodeOnly

    var symbolName: String {
        switch self {
        case .faceID: "faceid"
        case .touchID: "touchid"
        case .opticID: "opticid"
        case .passcodeOnly: "lock.fill"
        }
    }

    var isBiometric: Bool { self != .passcodeOnly }
}

/// Gate keeping surprise profiles behind Face ID / Touch ID / device passcode.
///
/// Unlocks last for the current session only and are dropped when the app leaves
/// the foreground, so a borrowed phone never exposes a surprise.
@Observable
final class BiometricGate {
    static let shared = BiometricGate()

    private let logger = Logger(subsystem: "com.kudao.app", category: "biometrics")

    private(set) var unlockedProfileIDs: Set<UUID> = []
    private(set) var isAuthenticating: Bool = false

    private init() {}

    var biometryKind: BiometryKind {
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return .passcodeOnly
        }
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .opticID: return .opticID
        default: return .passcodeOnly
        }
    }

    func isUnlocked(_ profileID: UUID) -> Bool {
        unlockedProfileIDs.contains(profileID)
    }

    /// Prompts for authentication unless this profile is already unlocked in this session.
    func unlock(profileID: UUID, reason: String) async -> Bool {
        if unlockedProfileIDs.contains(profileID) { return true }
        guard !isAuthenticating else { return false }

        isAuthenticating = true
        defer { isAuthenticating = false }

        let context = LAContext()
        context.localizedFallbackTitle = ""

        let success = await evaluate(context: context, reason: reason)
        if success {
            unlockedProfileIDs.insert(profileID)
        }
        return success
    }

    /// Called when the app goes to the background: everything locks again.
    func lockAll() {
        guard !unlockedProfileIDs.isEmpty else { return }
        unlockedProfileIDs.removeAll()
    }

    private func evaluate(context: LAContext, reason: String) async -> Bool {
        await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
                if let error {
                    self?.logger.info("Authentication ended: \(error.localizedDescription, privacy: .public)")
                }
                continuation.resume(returning: success)
            }
        }
    }
}
