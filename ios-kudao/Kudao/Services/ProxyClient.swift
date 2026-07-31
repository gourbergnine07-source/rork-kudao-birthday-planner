//
//  ProxyClient.swift
//  Kudao
//

import Foundation

/// Errors surfaced by the Rork toolkit proxy, mapped once at the transport boundary.
nonisolated enum ProxyError: LocalizedError {
    case authError
    case insufficientBalance
    case payloadTooLarge
    case rateLimited
    case serverError(Int)
    case clientError(Int)
    case noData
    case badResponse

    var errorDescription: String? {
        switch self {
        case .authError: "AI features are currently unavailable. Please restart the app."
        case .insufficientBalance: "AI features are temporarily unavailable. Please try again later."
        case .payloadTooLarge: "The note is too long. Please shorten it."
        case .rateLimited: "Too many requests. Please wait a moment and try again."
        case .serverError: "Something went wrong. Please try again."
        case .clientError: "Something went wrong. Please try again."
        case .noData: "No response from the AI service. Please try again."
        case .badResponse: "The AI response could not be understood."
        }
    }
}

/// Shared transport for every call against the Rork toolkit proxy.
nonisolated enum ProxyClient {
    static var vercelChatCompletionsURL: URL? {
        URL(string: "\(Config.EXPO_PUBLIC_TOOLKIT_URL)/v2/vercel/v1/chat/completions")
    }

    static func jsonRequest(url: URL, body: [String: Any], timeout: TimeInterval = 60) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Config.EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = timeout
        return request
    }

    /// Two formats per RFC 7231 §7.1.3: delta-seconds or an HTTP date.
    static func retryAfterSeconds(from response: HTTPURLResponse) -> Double? {
        guard let value = response.value(forHTTPHeaderField: "Retry-After") else { return nil }

        if let seconds = Double(value.trimmingCharacters(in: .whitespaces)) {
            return max(0, seconds)
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        if let date = formatter.date(from: value) {
            return max(0, date.timeIntervalSinceNow)
        }
        return nil
    }

    /// Jitter desynchronises retries when many clients fail at the same instant.
    static func exponentialDelay(attempt: Int) -> Double {
        pow(2.0, Double(attempt)) + Double.random(in: 0...0.5)
    }

    /// Retries 429 / 5xx / transport errors up to `maxAttempts` total, honouring
    /// `Retry-After` and reusing one idempotency key across attempts.
    static func sendWithRetry(
        _ request: URLRequest,
        maxAttempts: Int = 3,
        session: URLSession = .shared
    ) async throws -> (Data, HTTPURLResponse) {
        var req = request
        if req.value(forHTTPHeaderField: "idempotency-key") == nil {
            req.setValue(UUID().uuidString, forHTTPHeaderField: "idempotency-key")
        }

        var lastTransportError: Error?

        for attempt in 0..<maxAttempts {
            let isLastAttempt = attempt == maxAttempts - 1

            do {
                let (data, response) = try await session.data(for: req)
                guard let http = response as? HTTPURLResponse else {
                    throw ProxyError.serverError(0)
                }

                switch http.statusCode {
                case 200...299:
                    return (data, http)

                case 401:
                    throw ProxyError.authError
                case 402:
                    throw ProxyError.insufficientBalance
                case 413:
                    throw ProxyError.payloadTooLarge

                case 429:
                    if isLastAttempt { throw ProxyError.rateLimited }
                    let wait = retryAfterSeconds(from: http) ?? exponentialDelay(attempt: attempt)
                    try await Task.sleep(for: .seconds(wait))
                    continue

                case 500...599:
                    if isLastAttempt { throw ProxyError.serverError(http.statusCode) }
                    let wait = retryAfterSeconds(from: http) ?? exponentialDelay(attempt: attempt)
                    try await Task.sleep(for: .seconds(wait))
                    continue

                default:
                    throw ProxyError.clientError(http.statusCode)
                }
            } catch let error as ProxyError {
                throw error
            } catch {
                lastTransportError = error
                if isLastAttempt { throw error }
                try await Task.sleep(for: .seconds(exponentialDelay(attempt: attempt)))
                continue
            }
        }

        throw lastTransportError ?? ProxyError.serverError(0)
    }
}
