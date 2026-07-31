//
//  ImageDownscaler.swift
//  Kudao
//

import UIKit

/// Keeps stored profile photos small enough for fast list rendering.
nonisolated enum ImageDownscaler {
    /// Profile photos never need more than this: it fills any avatar on any device.
    static let profileMaxDimension: CGFloat = 1_024

    static func compress(_ data: Data, maxDimension: CGFloat = profileMaxDimension) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let largestSide = max(image.size.width, image.size.height)
        guard largestSide > 0 else { return nil }

        let scale = min(1, maxDimension / largestSide)
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resized.jpegData(compressionQuality: 0.85)
    }

    /// Same treatment starting from an image already in memory (a crop, a capture).
    static func compress(_ image: UIImage, maxDimension: CGFloat = profileMaxDimension) -> Data? {
        guard let data = image.jpegData(compressionQuality: 0.95) else { return nil }
        return compress(data, maxDimension: maxDimension)
    }
}
