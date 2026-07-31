//
//  PhotoLibraryDates.swift
//  Kudao
//

import Foundation
import OSLog
import Photos

/// Reads the capture date of assets picked from the photo library.
///
/// `PhotosPickerItem` only carries the bytes, so the gallery would otherwise
/// timestamp every import with "now" and scramble the chronology. When the
/// library is not readable the lookup simply comes back empty.
nonisolated enum PhotoLibraryDates {
    private static let logger = Logger(subsystem: "com.kudao.app", category: "gallery")

    /// Capture dates keyed by asset local identifier.
    static func captureDates(for identifiers: [String]) -> [String: Date] {
        let cleaned = identifiers.filter { !$0.isEmpty }
        guard !cleaned.isEmpty else { return [:] }

        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else {
            logger.debug("Capture dates unavailable: library not readable.")
            return [:]
        }

        var dates: [String: Date] = [:]
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: cleaned, options: nil)
        assets.enumerateObjects { asset, _, _ in
            if let created = asset.creationDate {
                dates[asset.localIdentifier] = created
            }
        }
        return dates
    }
}
