//
//  GalleryMediaStore.swift
//  Kudao
//

import Foundation
import OSLog

/// On-disk cache of the gallery originals.
///
/// Thumbnails live in SwiftData, so a purged cache only means the full photo or
/// video is downloaded again the next time somebody opens it.
nonisolated enum GalleryMediaStore {
    private static let logger = Logger(subsystem: "com.kudao.app", category: "gallery-store")
    private static let folderName = "GalleryMedia"

    private static var folder: URL? {
        let manager = FileManager.default
        guard let base = try? manager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return nil }

        let directory = base.appendingPathComponent(folderName, isDirectory: true)
        if !manager.fileExists(atPath: directory.path) {
            try? manager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    /// Where one memory is cached; nil only when the cache directory is unavailable.
    static func url(remoteID: String, mediaType: GalleryMediaType) -> URL? {
        let safeName = remoteID.replacingOccurrences(of: "/", with: "-")
        return folder?.appendingPathComponent("\(safeName).\(mediaType.fileExtension)")
    }

    static func cachedURL(remoteID: String, mediaType: GalleryMediaType) -> URL? {
        guard let url = url(remoteID: remoteID, mediaType: mediaType),
              FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }

    @discardableResult
    static func write(_ data: Data, remoteID: String, mediaType: GalleryMediaType) -> URL? {
        guard let url = url(remoteID: remoteID, mediaType: mediaType) else { return nil }
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            logger.error("Caching a gallery media failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    /// Moves a freshly prepared file (a transcoded video) into the cache.
    @discardableResult
    static func adopt(fileAt source: URL, remoteID: String, mediaType: GalleryMediaType) -> URL? {
        guard let destination = url(remoteID: remoteID, mediaType: mediaType) else { return nil }
        let manager = FileManager.default
        do {
            if manager.fileExists(atPath: destination.path) {
                try manager.removeItem(at: destination)
            }
            try manager.moveItem(at: source, to: destination)
            return destination
        } catch {
            logger.error("Storing a gallery media failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    static func remove(remoteID: String, mediaType: GalleryMediaType) {
        guard let url = url(remoteID: remoteID, mediaType: mediaType) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
