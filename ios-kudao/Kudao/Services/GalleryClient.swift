//
//  GalleryClient.swift
//  Kudao
//

import Foundation

/// One memory as the gallery room describes it.
nonisolated struct RemoteGalleryItem: Codable, Sendable, Equatable {
    let id: String
    let uploadedByUserId: String
    let uploaderName: String
    let mediaType: String
    let mime: String
    /// Milliseconds since epoch.
    let createdAt: Double
    let byteSize: Int
    let duration: Double
    let thumbnailBase64: String?
    let caption: String?
}

/// Metadata sent before the binary chunks of one upload.
nonisolated struct GalleryUploadStart: Encodable, Sendable {
    let itemId: String
    let userId: String
    let userName: String
    let mediaType: String
    let mime: String
    let createdAt: Double
    let byteSize: Int
    let chunkCount: Int
    let duration: Double
    let thumbnailBase64: String?
    let caption: String
}

/// HTTP client for the party gallery rooms.
///
/// Uploads are chunked so a video never travels in a single request, and every
/// call carries the Kudao user id the worker checks against the share room.
nonisolated enum GalleryClient {
    /// Slice size of a chunked upload; the room accepts up to 1 MB per chunk.
    static let chunkBytes = 512_000

    private static var baseURL: URL? {
        URL(string: Config.EXPO_PUBLIC_RORK_FUNCTIONS_URL)
    }

    // MARK: - Requests

    static func items(roomID: String, userID: String) async throws -> [RemoteGalleryItem] {
        struct Payload: Decodable, Sendable {
            let items: [RemoteGalleryItem]
        }

        let data = try await send(
            path: "/rooms/\(escaped(roomID))/gallery?userId=\(escaped(userID))",
            method: "GET",
            body: nil,
            contentType: nil
        )

        do {
            return try JSONDecoder().decode(Payload.self, from: data).items
        } catch {
            throw ShareError.server
        }
    }

    static func begin(roomID: String, start: GalleryUploadStart) async throws {
        let body = try JSONEncoder().encode(start)
        _ = try await send(
            path: "/rooms/\(escaped(roomID))/gallery/begin",
            method: "POST",
            body: body,
            contentType: "application/json"
        )
    }

    static func uploadChunk(
        roomID: String,
        itemID: String,
        index: Int,
        userID: String,
        bytes: Data
    ) async throws {
        _ = try await send(
            path: "/rooms/\(escaped(roomID))/gallery/chunk?itemId=\(escaped(itemID))"
                + "&index=\(index)&userId=\(escaped(userID))",
            method: "POST",
            body: bytes,
            contentType: "application/octet-stream"
        )
    }

    static func commit(roomID: String, itemID: String, userID: String) async throws {
        struct Body: Encodable {
            let itemId: String
            let userId: String
        }

        _ = try await send(
            path: "/rooms/\(escaped(roomID))/gallery/commit",
            method: "POST",
            body: try JSONEncoder().encode(Body(itemId: itemID, userId: userID)),
            contentType: "application/json"
        )
    }

    /// Writes (or clears) the caption of a memory already in the room.
    static func setCaption(roomID: String, itemID: String, userID: String, caption: String) async throws {
        struct Body: Encodable {
            let itemId: String
            let userId: String
            let caption: String
        }

        _ = try await send(
            path: "/rooms/\(escaped(roomID))/gallery/caption",
            method: "POST",
            body: try JSONEncoder().encode(
                Body(itemId: itemID, userId: userID, caption: caption)
            ),
            contentType: "application/json"
        )
    }

    static func media(roomID: String, itemID: String, userID: String) async throws -> Data {
        try await send(
            path: "/rooms/\(escaped(roomID))/gallery/media?itemId=\(escaped(itemID))"
                + "&userId=\(escaped(userID))",
            method: "GET",
            body: nil,
            contentType: nil
        )
    }

    static func delete(roomID: String, itemID: String, userID: String) async throws {
        struct Body: Encodable {
            let itemId: String
            let userId: String
        }

        _ = try await send(
            path: "/rooms/\(escaped(roomID))/gallery/delete",
            method: "POST",
            body: try JSONEncoder().encode(Body(itemId: itemID, userId: userID)),
            contentType: "application/json"
        )
    }

    // MARK: - Transport

    private struct ErrorPayload: Decodable, Sendable {
        let error: String?
    }

    private static func escaped(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? value
    }

    private static func send(
        path: String,
        method: String,
        body: Data?,
        contentType: String?
    ) async throws -> Data {
        guard let baseURL, let url = URL(string: baseURL.absoluteString + path) else {
            throw ShareError.notConfigured
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        // Videos take a while on a slow connection: keep uploads patient.
        request.timeoutInterval = 90
        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        request.httpBody = body

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

        return data
    }
}
