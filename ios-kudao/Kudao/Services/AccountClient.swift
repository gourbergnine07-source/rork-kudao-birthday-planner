//
//  AccountClient.swift
//  Kudao
//

import Foundation

/// Why an account could not be created, in the terms the account screen needs.
nonisolated enum AccountSignUpError: Error, Sendable {
    /// The address already belongs to someone.
    case alreadyRegistered
    case invalidEmail
    case weakPassword
    /// No keys, or the endpoint is not deployed — the caller should fall back.
    case unavailable
    case offline
    case server
}

/// Creates Kudao accounts through the `account` edge function.
///
/// Supabase's built-in sign-up mails a confirmation link pointing at the
/// project's Site URL, which is pinned to `localhost:3000` on this managed
/// instance — a dead page on a phone. The edge function creates the account with
/// the service role, already confirmed, so the app can sign in immediately and
/// no one has to leave for their inbox.
nonisolated enum AccountClient {
    private struct SignUpRequest: Encodable, Sendable {
        let action: String
        let email: String
        let password: String
    }

    private struct ErrorPayload: Decodable, Sendable {
        let error: String?
    }

    private static var endpoint: URL? {
        let base = Config.EXPO_PUBLIC_SUPABASE_URL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !base.isEmpty else { return nil }
        return URL(string: "\(base)/functions/v1/account")
    }

    /// Creates a confirmed account. Throws `AccountSignUpError` on every failure.
    static func createAccount(email: String, password: String) async throws {
        let key = Config.EXPO_PUBLIC_SUPABASE_ANON_KEY
        guard let endpoint, !key.isEmpty else { throw AccountSignUpError.unavailable }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 45
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(
            SignUpRequest(action: "signup", email: email, password: password)
        )

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AccountSignUpError.offline
        }

        guard let http = response as? HTTPURLResponse else { throw AccountSignUpError.server }
        if (200..<300).contains(http.statusCode) { return }

        let reason = (try? JSONDecoder().decode(ErrorPayload.self, from: data))?.error

        switch (http.statusCode, reason) {
        case (409, _), (_, "already_registered"):
            throw AccountSignUpError.alreadyRegistered
        case (_, "invalid_email"):
            throw AccountSignUpError.invalidEmail
        case (_, "weak_password"):
            throw AccountSignUpError.weakPassword
        case (404, _):
            // The function is not deployed on this project: let the caller retry
            // with Supabase's own sign-up rather than dead-ending the user.
            throw AccountSignUpError.unavailable
        default:
            throw AccountSignUpError.server
        }
    }
}
