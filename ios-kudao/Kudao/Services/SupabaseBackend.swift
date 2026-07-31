//
//  SupabaseBackend.swift
//  Kudao
//

import Foundation
import Supabase

/// Single entry point to the managed Postgres database.
///
/// Kudao has no sign-in, so the client always talks as the `anon` role and every
/// call goes through a `kudao_*` database function that requires the backup code.
/// The tables themselves are locked by row level security with no policies, so
/// nothing is reachable without that code.
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
            supabaseKey: Config.EXPO_PUBLIC_SUPABASE_ANON_KEY,
            options: .init(
                auth: .init(
                    // The app never signs anybody in: returning nil keeps the
                    // request on the anon role instead of sending a bogus JWT.
                    accessToken: { nil }
                )
            )
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
