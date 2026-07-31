//
//  MediaPermissions.swift
//  Kudao
//

import AVFoundation
import Photos
import UIKit

/// Which media source a permission check refers to.
enum MediaSource: String, Identifiable, Sendable {
    case camera
    case photoLibrary

    var id: String { rawValue }

    func deniedTitle(_ strings: Strings) -> String {
        switch self {
        case .camera: strings.cameraDeniedTitle
        case .photoLibrary: strings.libraryDeniedTitle
        }
    }

    func deniedMessage(_ strings: Strings) -> String {
        switch self {
        case .camera: strings.cameraDeniedMessage
        case .photoLibrary: strings.libraryDeniedMessage
        }
    }
}

/// Asks for camera and photo library access, and points at Settings when refused.
enum MediaPermissions {
    /// True when the camera can be used; requests access the first time.
    static func requestCamera() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }

    /// True when the library can be browsed; limited access counts as granted.
    static func requestPhotoLibrary() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return status == .authorized || status == .limited
        default:
            return false
        }
    }

    /// Opens this app's page in the iOS Settings app.
    @MainActor
    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
