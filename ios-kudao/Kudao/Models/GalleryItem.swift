//
//  GalleryItem.swift
//  Kudao
//

import Foundation
import SwiftData

/// How far an upload of one memory has got.
nonisolated enum GalleryUploadState: String, Sendable {
    case uploading
    case uploaded
    case failed
}

/// One photo or video collected in a profile's party gallery.
///
/// The thumbnail lives in SwiftData so the grid renders instantly and offline;
/// the original media is cached as a file and re-downloaded on demand.
@Model
final class GalleryItem {
    var id: UUID = UUID()
    /// Id shared with the gallery room, stable across every participant's device.
    var remoteID: String = ""
    var uploadedByUserID: String = ""
    var uploaderName: String = ""
    var mediaTypeRaw: String = GalleryMediaType.photo.rawValue
    var mime: String = GalleryMediaType.photo.mimeType
    var byteSize: Int = 0
    /// Length of a video in seconds; zero for photos.
    var durationSeconds: Double = 0
    var createdAt: Date = Date()
    /// Short line the uploader wrote about this memory; empty when none.
    var caption: String = ""
    @Attribute(.externalStorage) var thumbnailData: Data?
    var uploadStateRaw: String = GalleryUploadState.uploaded.rawValue

    var profile: BirthdayProfile?

    init(
        remoteID: String,
        uploadedByUserID: String,
        uploaderName: String,
        mediaType: GalleryMediaType,
        mime: String,
        byteSize: Int,
        durationSeconds: Double = 0,
        createdAt: Date = Date(),
        caption: String = "",
        thumbnailData: Data? = nil,
        uploadState: GalleryUploadState = .uploaded,
        profile: BirthdayProfile? = nil
    ) {
        self.id = UUID()
        self.remoteID = remoteID
        self.uploadedByUserID = uploadedByUserID
        self.uploaderName = uploaderName
        self.mediaTypeRaw = mediaType.rawValue
        self.mime = mime
        self.byteSize = byteSize
        self.durationSeconds = durationSeconds
        self.createdAt = createdAt
        self.caption = caption
        self.thumbnailData = thumbnailData
        self.uploadStateRaw = uploadState.rawValue
        self.profile = profile
    }

    var mediaType: GalleryMediaType {
        get { GalleryMediaType.parse(mediaTypeRaw) }
        set { mediaTypeRaw = newValue.rawValue }
    }

    var uploadState: GalleryUploadState {
        get { GalleryUploadState(rawValue: uploadStateRaw) ?? .uploaded }
        set { uploadStateRaw = newValue.rawValue }
    }

    var isVideo: Bool { mediaType == .video }

    var hasCaption: Bool { !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    /// Longest caption Kudao stores, matching the gallery room limit.
    static let captionLimit = 140

    func isMine(_ userID: String) -> Bool {
        uploadedByUserID == userID
    }

    /// "0:42" for videos, empty for photos.
    var durationLabel: String {
        guard isVideo, durationSeconds >= 1 else { return "" }
        let total = Int(durationSeconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
