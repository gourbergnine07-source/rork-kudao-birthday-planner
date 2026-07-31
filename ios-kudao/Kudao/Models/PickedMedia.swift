//
//  PickedMedia.swift
//  Kudao
//

import Foundation

/// Raw media the user picked from the library or captured with the camera,
/// before Kudao compresses it for the shared gallery.
nonisolated enum PickedMedia: Sendable {
    case photo(Data)
    /// Local file of a clip; Kudao owns it and deletes it after transcoding.
    case video(URL)
}

/// A picked memory together with the moment it was actually taken.
///
/// The gallery is a timeline, so a photo shot last week must land next to that
/// week even if it is imported today. `capturedAt` is nil when the library
/// cannot tell us, and the upload time is used instead.
nonisolated struct PickedMediaEntry: Sendable {
    let media: PickedMedia
    let capturedAt: Date?

    init(media: PickedMedia, capturedAt: Date? = nil) {
        self.media = media
        self.capturedAt = capturedAt
    }
}
