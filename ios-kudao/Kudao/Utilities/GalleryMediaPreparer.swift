//
//  GalleryMediaPreparer.swift
//  Kudao
//

import AVFoundation
import Foundation
import UIKit

/// A memory ready to be uploaded: compressed bytes plus its square thumbnail.
nonisolated struct PreparedMedia: Sendable {
    let mediaType: GalleryMediaType
    /// Photo bytes; nil for videos, which travel as a file.
    let data: Data?
    /// Transcoded video file; nil for photos.
    let fileURL: URL?
    let thumbnail: Data
    let byteSize: Int
    let durationSeconds: Double
}

/// Why a picked photo or video could not be prepared.
nonisolated enum MediaPreparationError: Error, Sendable, Equatable {
    case unreadable
    case tooLarge
    case exportFailed
}

/// Turns what the user picked (or filmed) into something small enough to share.
nonisolated enum GalleryMediaPreparer {
    /// Upper bound accepted by the gallery room, kept a little under the server limit.
    static let maxUploadBytes = 24_000_000
    private static let photoMaxDimension: CGFloat = 1_800
    private static let thumbnailMaxDimension: CGFloat = 480

    // MARK: - Photos

    static func preparePhoto(_ data: Data) throws -> PreparedMedia {
        guard let image = UIImage(data: data) else { throw MediaPreparationError.unreadable }

        guard let compressed = resize(image, maxDimension: photoMaxDimension, quality: 0.82),
              let thumbnail = resize(image, maxDimension: thumbnailMaxDimension, quality: 0.6) else {
            throw MediaPreparationError.unreadable
        }
        guard compressed.count <= maxUploadBytes else { throw MediaPreparationError.tooLarge }

        return PreparedMedia(
            mediaType: .photo,
            data: compressed,
            fileURL: nil,
            thumbnail: thumbnail,
            byteSize: compressed.count,
            durationSeconds: 0
        )
    }

    // MARK: - Videos

    /// Transcodes the clip to a compact MP4 and grabs its first frame as thumbnail.
    static func prepareVideo(at source: URL) async throws -> PreparedMedia {
        let asset = AVURLAsset(url: source)
        let duration = (try? await asset.load(.duration).seconds) ?? 0

        let output = FileManager.default.temporaryDirectory
            .appendingPathComponent("kudao-\(UUID().uuidString).mp4")

        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset960x540) else {
            throw MediaPreparationError.exportFailed
        }

        do {
            try await session.export(to: output, as: .mp4)
        } catch {
            throw MediaPreparationError.exportFailed
        }

        let attributes = try? FileManager.default.attributesOfItem(atPath: output.path)
        let byteSize = (attributes?[.size] as? Int) ?? 0
        guard byteSize > 0 else {
            try? FileManager.default.removeItem(at: output)
            throw MediaPreparationError.exportFailed
        }
        guard byteSize <= maxUploadBytes else {
            try? FileManager.default.removeItem(at: output)
            throw MediaPreparationError.tooLarge
        }

        let thumbnail = try await videoThumbnail(for: AVURLAsset(url: output))

        return PreparedMedia(
            mediaType: .video,
            data: nil,
            fileURL: output,
            thumbnail: thumbnail,
            byteSize: byteSize,
            durationSeconds: duration.isFinite ? max(0, duration) : 0
        )
    }

    private static func videoThumbnail(for asset: AVURLAsset) async throws -> Data {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: thumbnailMaxDimension, height: thumbnailMaxDimension)

        do {
            let frame = try await generator.image(at: CMTime(seconds: 0.1, preferredTimescale: 600))
            let image = UIImage(cgImage: frame.image)
            guard let data = resize(image, maxDimension: thumbnailMaxDimension, quality: 0.6) else {
                throw MediaPreparationError.unreadable
            }
            return data
        } catch {
            throw MediaPreparationError.unreadable
        }
    }

    // MARK: - Helpers

    private static func resize(_ image: UIImage, maxDimension: CGFloat, quality: CGFloat) -> Data? {
        let largestSide = max(image.size.width, image.size.height)
        guard largestSide > 0 else { return nil }

        let scale = min(1, maxDimension / largestSide)
        let target = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
