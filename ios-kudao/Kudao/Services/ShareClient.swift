//
//  ShareClient.swift
//  Kudao
//

import Foundation

/// Failures the share backend can report, mapped once at the transport boundary.
nonisolated enum ShareError: Error, Sendable, Equatable {
    case notConfigured
    case invalidCode
    case codeUsed
    case ownProfile
    case notParticipant
    case readOnly
    case notOwner
    case offline
    case server

    /// Maps the worker's `{ "error": "..." }` payload onto a typed case.
    static func from(status: Int, payload: String?) -> ShareError {
        switch payload {
        case "invalid_code": return .invalidCode
        case "code_used": return .codeUsed
        case "own_profile": return .ownProfile
        case "not_participant": return .notParticipant
        case "read_only": return .readOnly
        case "not_owner", "cannot_remove_owner": return .notOwner
        default: return status == 404 ? .invalidCode : .server
        }
    }

    /// User-facing copy, localized through the active string table.
    func message(_ strings: Strings) -> String {
        switch self {
        case .notConfigured, .server: strings.shareErrorGeneric
        case .invalidCode: strings.shareErrorInvalidCode
        case .codeUsed: strings.shareErrorCodeUsed
        case .ownProfile: strings.shareErrorOwnProfile
        case .notParticipant: strings.shareErrorNoAccess
        case .readOnly: strings.shareErrorReadOnly
        case .notOwner: strings.shareErrorNotOwner
        case .offline: strings.shareErrorOffline
        }
    }
}

// MARK: - Wire format

/// Profile data the owner publishes to the room. Collaborators render it read-only.
nonisolated struct ProfileSnapshot: Codable, Sendable, Equatable {
    var name: String
    var lastName: String
    /// Milliseconds since epoch, so every platform reads the same value.
    var birthDate: Double
    var relationship: String
    var isSurpriseMode: Bool
    var photoBase64: String?
    var plan: PlanSnapshot?
}

nonisolated struct PlanSnapshot: Codable, Sendable, Equatable {
    var giftIdea: String
    var giftCategory: String
    var giftPriceBand: String
    var giftReason: String
    var cakeType: String
    var cakeReason: String
    var venueIdea: String
    var venueReason: String
    var guestCount: Int
    var confidence: String
    var isConfirmed: Bool
    var keywordCount: Int
}

nonisolated struct RoomParticipant: Codable, Sendable, Equatable {
    let userId: String
    let name: String
    let permission: String
    let invitedAt: Double
    let acceptedAt: Double?
    let isOwner: Bool
}

nonisolated struct RoomInvite: Codable, Sendable, Equatable {
    let code: String
    let permission: String
    let invitedAt: Double
}

nonisolated struct RoomNote: Codable, Sendable, Equatable {
    let id: String
    let authorId: String
    let authorName: String
    let text: String
    let createdAt: Double
}

nonisolated struct RoomVote: Codable, Sendable, Equatable {
    let card: String
    let userId: String
    let userName: String
    let value: Int
    let updatedAt: Double
}

nonisolated struct RoomState: Codable, Sendable, Equatable {
    let profileId: String
    let ownerUserId: String
    let ownerName: String
    let permission: String
    let isOwner: Bool
    let snapshot: ProfileSnapshot?
    let participants: [RoomParticipant]
    let pendingInvites: [RoomInvite]
    let notes: [RoomNote]
    let votes: [RoomVote]
}

nonisolated struct CreatedInvite: Codable, Sendable, Equatable {
    let code: String
    let permission: String
    let invitedAt: Double
}

nonisolated struct OutgoingNote: Codable, Sendable, Equatable {
    let id: String
    let text: String
    let createdAt: Double
}

/// Thin HTTP client for the project's share worker.
nonisolated enum ShareClient {
    private static var baseURL: URL? {
        URL(string: Config.EXPO_PUBLIC_RORK_FUNCTIONS_URL)
    }

    // MARK: Requests

    static func createInvite(
        profileID: String,
        ownerUserID: String,
        ownerName: String,
        permission: SharePermission,
        snapshot: ProfileSnapshot
    ) async throws -> CreatedInvite {
        struct Body: Encodable {
            let profileId: String
            let ownerUserId: String
            let ownerName: String
            let permission: String
            let snapshot: ProfileSnapshot
        }

        return try await send(
            path: "/shares",
            method: "POST",
            body: Body(
                profileId: profileID,
                ownerUserId: ownerUserID,
                ownerName: ownerName,
                permission: permission.rawValue,
                snapshot: snapshot
            ),
            decode: CreatedInvite.self
        )
    }

    static func join(code: String, userID: String, userName: String) async throws -> RoomState {
        struct Body: Encodable {
            let code: String
            let userId: String
            let userName: String
        }

        return try await send(
            path: "/shares/join",
            method: "POST",
            body: Body(code: code, userId: userID, userName: userName),
            decode: RoomState.self
        )
    }

    static func state(roomID: String, userID: String) async throws -> RoomState {
        let query = "?userId=\(userID.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? userID)"
        return try await send(
            path: "/rooms/\(roomID)\(query)",
            method: "GET",
            body: Optional<String>.none,
            decode: RoomState.self
        )
    }

    static func pushSnapshot(
        roomID: String,
        ownerUserID: String,
        ownerName: String,
        snapshot: ProfileSnapshot,
        notes: [OutgoingNote]
    ) async throws -> RoomState {
        struct Body: Encodable {
            let ownerUserId: String
            let ownerName: String
            let snapshot: ProfileSnapshot
            let notes: [OutgoingNote]
        }

        return try await send(
            path: "/rooms/\(roomID)/snapshot",
            method: "POST",
            body: Body(ownerUserId: ownerUserID, ownerName: ownerName, snapshot: snapshot, notes: notes),
            decode: RoomState.self
        )
    }

    static func addNote(roomID: String, userID: String, userName: String, note: OutgoingNote) async throws {
        struct Body: Encodable {
            let userId: String
            let userName: String
            let note: OutgoingNote
        }

        _ = try await send(
            path: "/rooms/\(roomID)/notes",
            method: "POST",
            body: Body(userId: userID, userName: userName, note: note),
            decode: Acknowledgement.self
        )
    }

    static func deleteNote(roomID: String, userID: String, noteID: String) async throws {
        struct Body: Encodable {
            let userId: String
            let noteId: String
        }

        _ = try await send(
            path: "/rooms/\(roomID)/notes/delete",
            method: "POST",
            body: Body(userId: userID, noteId: noteID),
            decode: Acknowledgement.self
        )
    }

    static func vote(
        roomID: String,
        userID: String,
        userName: String,
        card: PlanSection,
        value: Int
    ) async throws {
        struct Body: Encodable {
            let userId: String
            let userName: String
            let card: String
            let value: Int
        }

        _ = try await send(
            path: "/rooms/\(roomID)/votes",
            method: "POST",
            body: Body(userId: userID, userName: userName, card: card.rawValue, value: value),
            decode: Acknowledgement.self
        )
    }

    static func removeParticipant(
        roomID: String,
        ownerUserID: String,
        targetUserID: String
    ) async throws -> RoomState {
        struct Body: Encodable {
            let ownerUserId: String
            let targetUserId: String
        }

        return try await send(
            path: "/rooms/\(roomID)/participants/remove",
            method: "POST",
            body: Body(ownerUserId: ownerUserID, targetUserId: targetUserID),
            decode: RoomState.self
        )
    }

    // MARK: Transport

    private struct Acknowledgement: Decodable, Sendable {
        let ok: Bool?
    }

    private struct ErrorPayload: Decodable, Sendable {
        let error: String?
    }

    private static func send<Body: Encodable, Decoded: Decodable>(
        path: String,
        method: String,
        body: Body?,
        decode: Decoded.Type
    ) async throws -> Decoded {
        guard let baseURL, let url = URL(string: baseURL.absoluteString + path) else {
            throw ShareError.notConfigured
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 25
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ShareError.offline
        }

        guard let http = response as? HTTPURLResponse else { throw ShareError.server }

        guard (200..<300).contains(http.statusCode) else {
            let payload = try? JSONDecoder().decode(ErrorPayload.self, from: data)
            throw ShareError.from(status: http.statusCode, payload: payload?.error)
        }

        do {
            return try JSONDecoder().decode(Decoded.self, from: data)
        } catch {
            throw ShareError.server
        }
    }
}
