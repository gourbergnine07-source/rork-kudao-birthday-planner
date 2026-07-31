//
//  CloudVault.swift
//  Kudao
//

import Foundation
import Security

/// The recovery code that unlocks the cloud copy of the user's data.
///
/// It is the only credential Kudao ever holds: it lives in the Keychain on the
/// device and is shown to the user so they can restore everything elsewhere.
/// The database only ever stores its SHA-256 hash.
nonisolated enum CloudVaultCode {
    /// No look-alike characters (0/O, 1/I) so codes can be read out loud.
    private static let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
    private static let length = 12
    private static let keychainAccount = "kudao.cloud.recoveryCode"
    private static let keychainService = "app.kudao.cloudbackup"

    /// Fresh 12-character code, e.g. `K7QD2M4X9BTR`.
    static func generate() -> String {
        String((0..<length).map { _ in alphabet.randomElement() ?? "K" })
    }

    /// Strips spaces and dashes and upper-cases, so typing style never matters.
    static func normalize(_ raw: String) -> String {
        raw.uppercased().filter { $0.isLetter || $0.isNumber }
    }

    /// `K7QD-2M4X-9BTR`, easier to read and to type back in.
    static func format(_ raw: String) -> String {
        let cleaned = normalize(raw)
        guard !cleaned.isEmpty else { return "" }
        return stride(from: 0, to: cleaned.count, by: 4)
            .map { offset -> String in
                let start = cleaned.index(cleaned.startIndex, offsetBy: offset)
                let end = cleaned.index(start, offsetBy: min(4, cleaned.count - offset))
                return String(cleaned[start..<end])
            }
            .joined(separator: "-")
    }

    static func isValid(_ raw: String) -> Bool {
        normalize(raw).count >= 10
    }

    // MARK: Keychain

    static func load() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        guard
            SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
            let data = item as? Data,
            let code = String(data: data, encoding: .utf8),
            !code.isEmpty
        else { return nil }

        return code
    }

    static func save(_ code: String) {
        let normalized = normalize(code)
        guard let data = normalized.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]

        SecItemDelete(query as CFDictionary)

        var insert = query
        insert[kSecValueData as String] = data
        insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(insert as CFDictionary, nil)
    }

    static func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        SecItemDelete(query as CFDictionary)
    }
}

/// Ids deleted on this device, kept until the cloud copy has been told about them.
///
/// Without this, the next sync would happily download a profile the user had
/// just thrown away.
nonisolated enum CloudTombstones {
    private static let profilesKey = "kudao.cloud.deletedProfiles"
    private static let entriesKey = "kudao.cloud.deletedEntries"

    /// Deleted profile ids.
    static var profiles: [String] {
        UserDefaults.standard.stringArray(forKey: profilesKey) ?? []
    }

    /// Deleted note ids, stored as `noteID|profileID` so the row can be located.
    static var entries: [(id: String, profileID: String)] {
        (UserDefaults.standard.stringArray(forKey: entriesKey) ?? []).compactMap { pair in
            let parts = pair.split(separator: "|", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { return nil }
            return (parts[0], parts[1])
        }
    }

    static func recordProfile(_ id: UUID) {
        var current = profiles
        let value = id.uuidString
        guard !current.contains(value) else { return }
        current.append(value)
        UserDefaults.standard.set(current, forKey: profilesKey)
    }

    static func recordEntry(_ id: UUID, profileID: UUID) {
        var current = UserDefaults.standard.stringArray(forKey: entriesKey) ?? []
        let value = "\(id.uuidString)|\(profileID.uuidString)"
        guard !current.contains(value) else { return }
        current.append(value)
        UserDefaults.standard.set(current, forKey: entriesKey)
    }

    /// Called once the server has acknowledged the deletions.
    static func clear() {
        UserDefaults.standard.removeObject(forKey: profilesKey)
        UserDefaults.standard.removeObject(forKey: entriesKey)
    }
}
