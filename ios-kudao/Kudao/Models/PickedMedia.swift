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
