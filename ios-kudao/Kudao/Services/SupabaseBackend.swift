//
//  SupabaseBackend.swift
//  Kudao
//

import Foundation
import Supabase

/// Single entry point to the managed Postgres database.
///
/// The client owns the session: signing in with an email address attaches a
/// real JWT to every call, while a signed-out device keeps talking as `anon`.
/// Either way the tables stay locked by row level security with no policies —
/// all reads and writes go through the `kudao_*` functions, which accept the
/// recovery code, the signed-in account, or both.
enum SupabaseBackend {
    /// False in previews or if the project keys were not injected at build time.
    nonisolated static var isConfigured: Bool {
        !Config.EXPO_PUBLIC_SUPABASE_URL.isEmpty && !Config.EXPO_PUBLIC_SUPABASE_ANON_KEY.isEmpty
    }

    nonisolated static let client: SupabaseClient? = {
        guard
            !Config.EXPO_PUBLIC_SUPABASE_ANON_KEY.isEmpty,
            let url = URL(string: Config.EXPO_PUBLIC_SUPABASE_URL)
        else { return nil }

        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: Config.EXPO_PUBLIC_SUPABASE_ANON_KEY
        )
    }()
}

/// Errors surfaced by the cloud backup layer, already mapped to user wording.
nonisolated enum CloudBackupError: Error, Sendable {
    /// The build has no Supabase keys.
    case unavailable
    /// The code typed by the user does not match any vault.
    case unknownCode
    /// Anything else (offline, server error).
    case transport
}
