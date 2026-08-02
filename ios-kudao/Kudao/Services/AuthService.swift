//
//  AuthService.swift
//  Kudao
//

import Foundation
import Observation
import OSLog
import Supabase

/// What the account screen is currently asking the user to do.
nonisolated enum AuthStep: String, Sendable, CaseIterable, Identifiable {
    case signIn
    case signUp

    var id: String { rawValue }
}

/// Outcome of a sign-up, so the UI knows whether to celebrate or ask for a click.
nonisolated enum AuthOutcome: Sendable, Equatable {
    /// A session exists: the user is in.
    case signedIn
    /// The address must be confirmed from the email before signing in.
    case confirmationSent(email: String)
}

/// Email sign-in on top of Supabase Auth.
///
/// The account is optional in Kudao: everything works offline and the recovery
/// code still restores a backup on its own. Signing in simply gives the vault a
/// second, memorable door — one that survives losing both the phone and the code.
@Observable
final class AuthService {
    private let logger = Logger(subsystem: "com.kudao.app", category: "auth")

    /// The signed-in user, or nil while the app is anonymous.
    private(set) var user: User?
    private(set) var isWorking: Bool = false
    /// Set after a sign-up that needs the confirmation link to be opened.
    private(set) var pendingConfirmationEmail: String?
    /// Set after a password-reset request, so the UI can confirm it.
    private(set) var didSendPasswordReset: Bool = false
    var errorMessage: String?

    private var watcher: Task<Void, Never>?

    init() {
        guard let client = SupabaseBackend.client else { return }

        // `authStateChanges` replays the stored session first, so a returning
        // user is restored without an extra network round-trip.
        watcher = Task { [weak self] in
            for await state in client.auth.authStateChanges {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self?.user = state.session?.user
                }
            }
        }
    }

    deinit {
        watcher?.cancel()
    }

    var isSignedIn: Bool { user != nil }

    /// False when the build has no database keys (previews, local runs).
    var isAvailable: Bool { SupabaseBackend.isConfigured }

    var email: String { user?.email ?? "" }

    /// First letter of the address, used for the account avatar.
    var initial: String {
        String(email.first.map(String.init)?.uppercased() ?? "?")
    }

    func clearError() {
        errorMessage = nil
    }

    func clearNotices() {
        pendingConfirmationEmail = nil
        didSendPasswordReset = false
    }

    // MARK: - Sign in and out

    /// Signs in with an existing account. Returns true when a session was created.
    @discardableResult
    func signIn(email rawEmail: String, password: String, strings: Strings) async -> Bool {
        guard let client = SupabaseBackend.client else {
            errorMessage = strings.authUnavailableMessage
            return false
        }

        let address = Self.normalize(rawEmail)
        guard Self.isValidEmail(address) else {
            errorMessage = strings.authInvalidEmailMessage
            return false
        }
        guard !password.isEmpty else {
            errorMessage = strings.authMissingPasswordMessage
            return false
        }

        isWorking = true
        errorMessage = nil
        clearNotices()
        defer { isWorking = false }

        do {
            let session = try await client.auth.signIn(email: address, password: password)
            user = session.user
            return true
        } catch {
            errorMessage = message(for: error, strings: strings)
            return false
        }
    }

    /// Creates an account and signs straight in.
    ///
    /// The account is made by the `account` edge function, already confirmed, so
    /// nobody has to chase a link in their inbox. Only if that endpoint cannot be
    /// reached does this fall back to Supabase's own sign-up, which does send a
    /// confirmation email.
    func signUp(email rawEmail: String, password: String, strings: Strings) async -> AuthOutcome? {
        guard let client = SupabaseBackend.client else {
            errorMessage = strings.authUnavailableMessage
            return nil
        }

        let address = Self.normalize(rawEmail)
        guard Self.isValidEmail(address) else {
            errorMessage = strings.authInvalidEmailMessage
            return nil
        }
        guard password.count >= Self.minimumPasswordLength else {
            errorMessage = String(format: strings.authWeakPasswordFormat, Self.minimumPasswordLength)
            return nil
        }

        isWorking = true
        errorMessage = nil
        clearNotices()
        defer { isWorking = false }

        do {
            try await AccountClient.createAccount(email: address, password: password)
        } catch let error as AccountSignUpError {
            switch error {
            case .alreadyRegistered:
                errorMessage = strings.authEmailTakenMessage
                return nil
            case .invalidEmail:
                errorMessage = strings.authInvalidEmailMessage
                return nil
            case .weakPassword:
                errorMessage = String(format: strings.authWeakPasswordFormat, Self.minimumPasswordLength)
                return nil
            case .offline:
                errorMessage = strings.authOfflineMessage
                return nil
            case .unavailable, .server:
                logger.error("Account endpoint unusable, falling back to Supabase sign-up")
                return await legacySignUp(
                    client: client,
                    address: address,
                    password: password,
                    strings: strings
                )
            }
        } catch {
            errorMessage = message(for: error, strings: strings)
            return nil
        }

        // The address is confirmed the moment it is created, so the password
        // works right away and the user never has to leave the app.
        do {
            let session = try await client.auth.signIn(email: address, password: password)
            user = session.user
            return .signedIn
        } catch {
            errorMessage = message(for: error, strings: strings)
            return nil
        }
    }

    /// Supabase's own sign-up, kept only for when the edge function is unreachable.
    private func legacySignUp(
        client: SupabaseClient,
        address: String,
        password: String,
        strings: Strings
    ) async -> AuthOutcome? {
        do {
            let response = try await client.auth.signUp(email: address, password: password)
            if let session = response.session {
                user = session.user
                return .signedIn
            }
            pendingConfirmationEmail = address
            return .confirmationSent(email: address)
        } catch {
            errorMessage = message(for: error, strings: strings)
            return nil
        }
    }

    /// Sends the "forgot my password" email.
    func sendPasswordReset(email rawEmail: String, strings: Strings) async {
        guard let client = SupabaseBackend.client else {
            errorMessage = strings.authUnavailableMessage
            return
        }

        let address = Self.normalize(rawEmail)
        guard Self.isValidEmail(address) else {
            errorMessage = strings.authInvalidEmailMessage
            return
        }

        isWorking = true
        errorMessage = nil
        clearNotices()
        defer { isWorking = false }

        do {
            try await client.auth.resetPasswordForEmail(address)
            didSendPasswordReset = true
        } catch {
            errorMessage = message(for: error, strings: strings)
        }
    }

    /// Re-sends the confirmation email for an address that never activated.
    func resendConfirmation(strings: Strings) async {
        guard let client = SupabaseBackend.client, let address = pendingConfirmationEmail else { return }

        isWorking = true
        errorMessage = nil
        defer { isWorking = false }

        do {
            try await client.auth.resend(email: address, type: .signup)
        } catch {
            errorMessage = message(for: error, strings: strings)
        }
    }

    func signOut(strings: Strings) async {
        guard let client = SupabaseBackend.client else { return }

        isWorking = true
        errorMessage = nil
        defer { isWorking = false }

        do {
            try await client.auth.signOut()
        } catch {
            // A failed network sign-out still clears the local session below.
            logger.error("Sign out failed: \(error.localizedDescription, privacy: .public)")
        }
        user = nil
        clearNotices()
    }

    // MARK: - Helpers

    static let minimumPasswordLength = 8

    private static func normalize(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Deliberately permissive: the server is the real judge of an address.
    static func isValidEmail(_ address: String) -> Bool {
        guard address.count >= 6, !address.hasPrefix("@"), !address.hasSuffix("@") else { return false }
        let parts = address.split(separator: "@")
        guard parts.count == 2, let domain = parts.last else { return false }
        return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
    }

    /// Maps Supabase's English errors onto the wording of the active language.
    private func message(for error: Error, strings: Strings) -> String {
        let text = String(describing: error).lowercased()

        if text.contains("invalid login credentials") || text.contains("invalid_credentials") {
            return strings.authWrongCredentialsMessage
        }
        if text.contains("email not confirmed") || text.contains("email_not_confirmed") {
            return strings.authNotConfirmedMessage
        }
        if text.contains("already registered") || text.contains("user_already_exists") {
            return strings.authEmailTakenMessage
        }
        if text.contains("password") && text.contains("least") {
            return String(format: strings.authWeakPasswordFormat, Self.minimumPasswordLength)
        }
        if text.contains("rate limit") || text.contains("over_email_send_rate_limit") {
            return strings.authRateLimitMessage
        }
        if text.contains("offline") || text.contains("network") || text.contains("timed out") {
            return strings.authOfflineMessage
        }

        logger.error("Auth request failed: \(error.localizedDescription, privacy: .public)")
        return strings.authGenericErrorMessage
    }
}
