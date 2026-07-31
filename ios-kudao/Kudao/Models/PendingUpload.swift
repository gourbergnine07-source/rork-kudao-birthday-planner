//
//  PendingUpload.swift
//  Kudao
//

import Foundation

/// A memory waiting to be uploaded, together with the caption the user is writing.
///
/// The preview is a small JPEG built on the spot so the caption sheet can show
/// what is being described without waiting for the full compression pass.
struct PendingUpload: Identifiable, Sendable {
    let id: UUID = UUID()
    let media: PickedMedia
    let previewData: Data?
    /// When the memory was taken, so the timeline stays honest after an import.
    let capturedAt: Date?
    var caption: String = ""

    init(media: PickedMedia, previewData: Data?, capturedAt: Date? = nil, caption: String = "") {
        self.media = media
        self.previewData = previewData
        self.capturedAt = capturedAt
        self.caption = caption
    }

    var isVideo: Bool {
        switch media {
        case .photo: false
        case .video: true
        }
    }

    /// Caption without stray whitespace, trimmed to what the room accepts.
    var cleanCaption: String {
        String(
            caption
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .prefix(GalleryItem.captionLimit)
        )
    }
}
