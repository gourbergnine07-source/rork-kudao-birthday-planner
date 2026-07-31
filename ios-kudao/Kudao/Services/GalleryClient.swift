//
//  GalleryClient.swift
//  Kudao
//

import Foundation

/// One memory as the gallery service describes it.
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

/// Metadata sent before the bytes of one upload.
nonisolated struct GalleryUploadStart: Sendable {
    let itemId: String
    let userId: String
    let userName: String
    let mediaType: String
    let mime: String
    let createdAt: Double
    let byteSize: Int
    let duration: Double
    let thumbnailBase64: String?
    let caption: String
}

/// Client for the party gallery, stored in the managed Postgres database.
///
/// Metadata lives in `gallery_items` and the media files in a private Storage
/// bucket. Neither is reachable from the app directly: every call goes through
/// the `gallery` edge function, which checks the profile's share room first and
/// then hands back a short-lived signed URL for the bytes.
nonisolated enum GalleryClient {
    // MARK: - Requests

    static func items(roomID: String, userID: String) async throws -> [RemoteGalleryItem] {
        struct Payload: Decodable, Sendable {
            let items: [RemoteGalleryItem]
        }

        let data = try await call(
            GalleryAction(action: "list", roomId: roomID, userId: userID)
        )

        do {
            return try JSONDecoder().decode(Payload.self, from: data).items
        } catch {
            throw ShareError.server
        }
    }

    /// Reserves the row and returns the one-shot URL the media is uploaded to.
    static func begin(roomID: String, start: GalleryUploadStart) async throws -> URL {
        struct Payload: Decodable, Sendable {
            let uploadUrl: String
        }

        let data = try await call(
            GalleryAction(
                action: "begin",
                roomId: roomID,
                userId: start.userId,
                itemId: start.itemId,
                userName: start.userName,
                mediaType: start.mediaType,
                mime: start.mime,
                byteSize: start.byteSize,
                duration: start.duration,
                createdAt: start.createdAt,
                thumbnailBase64: start.thumbnailBase64,
                caption: start.caption
            )
        )

        guard
            let payload = try? JSONDecoder().decode(Payload.self, from: data),
            let url = URL(string: payload.uploadUrl)
        else { throw ShareError.server }

        return url
    }

    /// Sends the media straight to Storage through the signed URL.
    static func upload(_ bytes: Data, to url: URL, mime: String) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.timeoutInterval = 120
        request.setValue(mime, forHTTPHeaderField: "Content-Type")
        request.setValue("true", forHTTPHeaderField: "x-upsert")

        let response: URLResponse
        do {
            (_, response) = try await URLSession.shared.upload(for: request, from: bytes)
        } catch {
            throw ShareError.offline
        }

        guard let http = response as? HTTPURLResponse else { throw ShareError.server }
        guard (200..<300).contains(http.statusCode) else {
            throw http.statusCode == 413 ? ShareError.server : ShareError.server
        }
    }

    static func commit(roomID: String, itemID: String, userID: String) async throws {
        _ = try await call(
            GalleryAction(action: "commit", roomId: roomID, userId: userID, itemId: itemID)
        )
    }

    /// Writes (or clears) the caption of a memory already in the gallery.
    static func setCaption(roomID: String, itemID: String, userID: String, caption: String) async throws {
        _ = try await call(
            GalleryAction(
                action: "caption",
                roomId: roomID,
                userId: userID,
                itemId: itemID,
                caption: caption
            )
        )
    }

    /// Downloads the original media through a freshly signed URL.
    static func media(roomID: String, itemID: String, userID: String) async throws -> Data {
        struct Payload: Decodable, Sendable {
            let url: String
        }

        let data = try await call(
            GalleryAction(action: "media", roomId: roomID, userId: userID, itemId: itemID)
        )

        guard
            let payload = try? JSONDecoder().decode(Payload.self, from: data),
            let url = URL(string: payload.url)
        else { throw ShareError.server }

        var request = URLRequest(url: url)
        request.timeoutInterval = 120

        let bytes: Data
        let response: URLResponse
        do {
            (bytes, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ShareError.offline
        }

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw ShareError.server
        }

        return bytes
    }

    static func delete(roomID: String, itemID: String, userID: String) async throws {
        _ = try await call(
            GalleryAction(action: "delete", roomId: roomID, userId: userID, itemId: itemID)
        )
    }

    // MARK: - Transport

    /// Every field the edge function understands; unused ones stay out of the JSON.
    private struct GalleryAction: Encodable, Sendable {
        let action: String
        let roomId: String
        let userId: String
        var itemId: String?
        var userName: String?
        var mediaType: String?
        var mime: String?
        var byteSize: Int?
        var duration: Double?
        var createdAt: Double?
        var thumbnailBase64: String?
        var caption: String?
    }

    private struct ErrorPayload: Decodable, Sendable {
        let error: String?
    }

    private static var endpoint: URL? {
        let base = Config.EXPO_PUBLIC_SUPABASE_URL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !base.isEmpty else { return nil }
        return URL(string: "\(base)/functions/v1/gallery")
    }

    private static func call(_ payload: GalleryAction) async throws -> Data {
        let key = Config.EXPO_PUBLIC_SUPABASE_ANON_KEY
        guard let endpoint, !key.isEmpty else { throw ShareError.notConfigured }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 45
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(payload)

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
