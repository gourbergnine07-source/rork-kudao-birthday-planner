//
//  GalleryMediaType.swift
//  Kudao
//

import Foundation

/// What a party memory actually is: a photo or a short video.
nonisolated enum GalleryMediaType: String, Sendable, CaseIterable, Identifiable {
    case photo
    case video

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .photo: "photo.fill"
        case .video: "play.circle.fill"
        }
    }

    var fileExtension: String {
        switch self {
        case .photo: "jpg"
        case .video: "mp4"
        }
    }

    var mimeType: String {
        switch self {
        case .photo: "image/jpeg"
        case .video: "video/mp4"
        }
    }

    static func parse(_ raw: String) -> GalleryMediaType {
        GalleryMediaType(rawValue: raw) ?? .photo
    }
}
