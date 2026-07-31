//
//  GalleryService.swift
//  Kudao
//

import Foundation
import Observation
import OSLog
import SwiftData

/// Keeps a profile's party gallery in step with its gallery room.
///
/// Thumbnails are mirrored into SwiftData so the grid works offline, while the
/// originals are cached as files and fetched only when somebody opens them.
@Observable
final class GalleryService {
    private let logger = Logger(subsystem: "com.kudao.app", category: "gallery")

    /// Rooms currently pulling their item list.
    private(set) var syncingRooms: Set<String> = []
    /// How many memories are still being uploaded right now.
    private(set) var pendingUploads: Int = 0
    /// Progress of the upload batch in flight, from 0 to 1.
    private(set) var uploadProgress: Double = 0
    private(set) var errorMessage: String?
    /// Bumped after every merge so the grid can refresh its derived state.
    private(set) var revision: Int = 0

    var isUploading: Bool { pendingUploads > 0 }

    func isSyncing(_ profile: BirthdayProfile) -> Bool {
        syncingRooms.contains(profile.roomID)
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Reading

    /// Local mirror of one profile's gallery, newest first.
    func items(for profile: BirthdayProfile, context: ModelContext) -> [GalleryItem] {
        let all = (try? context.fetch(FetchDescriptor<GalleryItem>())) ?? []
        return all
            .filter { $0.profile?.id == profile.id && !$0.isDeleted }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// Pulls the room's item list and merges it into SwiftData.
    func sync(
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async {
        let roomID = profile.roomID
        guard !syncingRooms.contains(roomID) else { return }

        syncingRooms.insert(roomID)
        defer { syncingRooms.remove(roomID) }

        do {
            let remote = try await GalleryClient.items(roomID: roomID, userID: identity.userID)
            merge(remote, into: profile, identity: identity, context: context)
            errorMessage = nil
        } catch {
            errorMessage = Self.message(error, strings)
        }
    }

    /// Local file of one memory, downloading the original the first time it is opened.
    func mediaURL(
        for item: GalleryItem,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings
    ) async -> URL? {
        let remoteID = item.remoteID
        let mediaType = item.mediaType

        if let cached = GalleryMediaStore.cachedURL(remoteID: remoteID, mediaType: mediaType) {
            return cached
        }
        guard item.uploadState == .uploaded else { return nil }

        do {
            let data = try await GalleryClient.media(
                roomID: profile.roomID,
                itemID: remoteID,
                userID: identity.userID
            )
            return GalleryMediaStore.write(data, remoteID: remoteID, mediaType: mediaType)
        } catch {
            errorMessage = Self.message(error, strings)
            return nil
        }
    }

    // MARK: - Uploading

    /// Prepares and uploads a batch of picked photos and videos, one after the other.
    func upload(
        sources: [PendingUpload],
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async {
        guard !sources.isEmpty else { return }

        pendingUploads += sources.count
        errorMessage = nil
        let total = Double(sources.count)
        var completed = 0.0

        for source in sources {
            defer {
                pendingUploads = max(0, pendingUploads - 1)
                completed += 1
                uploadProgress = min(1, completed / total)
            }

            do {
                let prepared = try await prepare(source.media)
                try await store(
                    prepared,
                    caption: source.cleanCaption,
                    capturedAt: source.capturedAt,
                    profile: profile,
                    identity: identity,
                    strings: strings,
                    context: context
                )
            } catch let error as MediaPreparationError {
                errorMessage = Self.message(error, strings)
            } catch {
                errorMessage = Self.message(error, strings)
            }
        }

        uploadProgress = 0
        await sync(profile: profile, identity: identity, strings: strings, context: context)
    }

    private func prepare(_ source: PickedMedia) async throws -> PreparedMedia {
        switch source {
        case .photo(let data):
            return try await Task.detached(priority: .userInitiated) {
                try GalleryMediaPreparer.preparePhoto(data)
            }.value
        case .video(let url):
            let prepared = try await GalleryMediaPreparer.prepareVideo(at: url)
            try? FileManager.default.removeItem(at: url)
            return prepared
        }
    }

    /// Writes the local mirror first, then pushes the bytes to the room.
    private func store(
        _ prepared: PreparedMedia,
        caption: String,
        capturedAt: Date? = nil,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async throws {
        let remoteID = UUID().uuidString
        // A memory belongs to the moment it was taken, not to the moment it was imported.
        let createdAt = min(capturedAt ?? Date(), Date())

        let item = GalleryItem(
            remoteID: remoteID,
            uploadedByUserID: identity.userID,
            uploaderName: identity.outgoingName(strings),
            mediaType: prepared.mediaType,
            mime: prepared.mediaType.mimeType,
            byteSize: prepared.byteSize,
            durationSeconds: prepared.durationSeconds,
            createdAt: createdAt,
            caption: caption,
            thumbnailData: prepared.thumbnail,
            uploadState: .uploading,
            profile: profile
        )
        context.insert(item)
        save(context)
        revision += 1

        // Cache the original locally so it can be viewed even before the upload lands.
        let payload: Data
        if let data = prepared.data {
            GalleryMediaStore.write(data, remoteID: remoteID, mediaType: prepared.mediaType)
            payload = data
        } else if let fileURL = prepared.fileURL {
            let cached = GalleryMediaStore.adopt(
                fileAt: fileURL,
                remoteID: remoteID,
                mediaType: prepared.mediaType
            )
            guard let cached, let data = try? Data(contentsOf: cached, options: .mappedIfSafe) else {
                item.uploadState = .failed
                save(context)
                throw MediaPreparationError.unreadable
            }
            payload = data
        } else {
            item.uploadState = .failed
            save(context)
            throw MediaPreparationError.unreadable
        }

        do {
            try await push(
                payload,
                remoteID: remoteID,
                prepared: prepared,
                caption: caption,
                createdAt: createdAt,
                profile: profile,
                identity: identity,
                strings: strings
            )
            item.uploadState = .uploaded
        } catch {
            item.uploadState = .failed
            save(context)
            throw error
        }

        save(context)
        revision += 1
    }

    /// begin → upload → commit: the row is reserved, the file goes straight to
    /// Storage through a one-shot signed URL, then the memory is published.
    private func push(
        _ payload: Data,
        remoteID: String,
        prepared: PreparedMedia,
        caption: String,
        createdAt: Date,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings
    ) async throws {
        let uploadURL = try await GalleryClient.begin(
            roomID: profile.roomID,
            start: GalleryUploadStart(
                itemId: remoteID,
                userId: identity.userID,
                userName: identity.outgoingName(strings),
                mediaType: prepared.mediaType.rawValue,
                mime: prepared.mediaType.mimeType,
                createdAt: createdAt.timeIntervalSince1970 * 1000,
                byteSize: payload.count,
                duration: prepared.durationSeconds,
                thumbnailBase64: prepared.thumbnail.base64EncodedString(),
                caption: caption
            )
        )

        try await GalleryClient.upload(payload, to: uploadURL, mime: prepared.mediaType.mimeType)

        try await GalleryClient.commit(
            roomID: profile.roomID,
            itemID: remoteID,
            userID: identity.userID
        )
    }

    /// Retries an upload that failed, reusing the media already cached on disk.
    func retry(
        item: GalleryItem,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async {
        guard item.uploadState == .failed,
              let cached = GalleryMediaStore.cachedURL(remoteID: item.remoteID, mediaType: item.mediaType),
              let payload = try? Data(contentsOf: cached, options: .mappedIfSafe),
              let thumbnail = item.thumbnailData else {
            errorMessage = strings.galleryRetryUnavailable
            return
        }

        pendingUploads += 1
        errorMessage = nil
        item.uploadState = .uploading
        save(context)

        defer {
            pendingUploads = max(0, pendingUploads - 1)
            revision += 1
        }

        do {
            try await push(
                payload,
                remoteID: item.remoteID,
                prepared: PreparedMedia(
                    mediaType: item.mediaType,
                    data: payload,
                    fileURL: nil,
                    thumbnail: thumbnail,
                    byteSize: payload.count,
                    durationSeconds: item.durationSeconds
                ),
                caption: item.caption,
                createdAt: item.createdAt,
                profile: profile,
                identity: identity,
                strings: strings
            )
            item.uploadState = .uploaded
        } catch {
            item.uploadState = .failed
            errorMessage = Self.message(error, strings)
        }
        save(context)
    }

    // MARK: - Captions

    /// Saves the caption locally first, then mirrors it to everyone else.
    func updateCaption(
        _ text: String,
        for item: GalleryItem,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async {
        let caption = String(
            text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(GalleryItem.captionLimit)
        )
        guard caption != item.caption else { return }

        let previous = item.caption
        item.caption = caption
        save(context)
        revision += 1

        guard item.uploadState == .uploaded else { return }

        do {
            try await GalleryClient.setCaption(
                roomID: profile.roomID,
                itemID: item.remoteID,
                userID: identity.userID,
                caption: caption
            )
        } catch {
            // Put the old line back so the grid never shows something the room refused.
            item.caption = previous
            save(context)
            revision += 1
            errorMessage = Self.message(error, strings)
        }
    }

    // MARK: - Deleting

    /// Uploaders remove their own memories, the profile owner can remove any.
    func delete(
        item: GalleryItem,
        profile: BirthdayProfile,
        identity: KudaoIdentity,
        strings: Strings,
        context: ModelContext
    ) async {
        let remoteID = item.remoteID
        let mediaType = item.mediaType
        let wasUploaded = item.uploadState == .uploaded

        context.delete(item)
        save(context)
        GalleryMediaStore.remove(remoteID: remoteID, mediaType: mediaType)
        revision += 1

        guard wasUploaded else { return }

        do {
            try await GalleryClient.delete(
                roomID: profile.roomID,
                itemID: remoteID,
                userID: identity.userID
            )
        } catch {
            errorMessage = Self.message(error, strings)
        }
    }

    // MARK: - Merge

    private func merge(
        _ remote: [RemoteGalleryItem],
        into profile: BirthdayProfile,
        identity: KudaoIdentity,
        context: ModelContext
    ) {
        let local = items(for: profile, context: context)
        let remoteIDs = Set(remote.map(\.id))

        for entry in remote {
            if let existing = local.first(where: { $0.remoteID == entry.id }) {
                existing.uploaderName = entry.uploaderName
                existing.uploadedByUserID = entry.uploadedByUserId
                existing.byteSize = entry.byteSize
                existing.durationSeconds = entry.duration
                existing.caption = entry.caption ?? ""
                existing.uploadState = .uploaded
                if existing.thumbnailData == nil, let base64 = entry.thumbnailBase64 {
                    existing.thumbnailData = Data(base64Encoded: base64)
                }
                continue
            }

            let imported = GalleryItem(
                remoteID: entry.id,
                uploadedByUserID: entry.uploadedByUserId,
                uploaderName: entry.uploaderName,
                mediaType: GalleryMediaType.parse(entry.mediaType),
                mime: entry.mime,
                byteSize: entry.byteSize,
                durationSeconds: entry.duration,
                createdAt: Date(timeIntervalSince1970: entry.createdAt / 1000),
                caption: entry.caption ?? "",
                thumbnailData: entry.thumbnailBase64.flatMap { Data(base64Encoded: $0) },
                uploadState: .uploaded,
                profile: profile
            )
            context.insert(imported)
        }

        // Memories somebody removed upstream disappear here too; uploads still
        // in flight or failed locally are kept so the user can retry them.
        for item in local where item.uploadState == .uploaded && !remoteIDs.contains(item.remoteID) {
            GalleryMediaStore.remove(remoteID: item.remoteID, mediaType: item.mediaType)
            context.delete(item)
        }

        save(context)
        revision += 1
    }

    private func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            logger.error("Saving the gallery failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private static func message(_ error: Error, _ strings: Strings) -> String {
        if let preparation = error as? MediaPreparationError {
            switch preparation {
            case .tooLarge: return strings.galleryTooLargeMessage
            case .unreadable, .exportFailed: return strings.galleryPrepareFailedMessage
            }
        }
        return (error as? ShareError ?? .server).message(strings)
    }
}
