//
//  CameraCaptureView.swift
//  Kudao
//

import SwiftUI
import UIKit

/// Camera capture for the party gallery: one photo or one short clip.
///
/// Uses the system camera controller so recording, flash and switching lenses all
/// behave exactly as people expect. Devices without a camera never reach this
/// screen: the caller hides the action instead.
struct CameraCaptureView: UIViewControllerRepresentable {
    let onCapture: (PickedMedia) -> Void

    @Environment(\.dismiss) private var dismiss

    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.mediaTypes = ["public.image", "public.movie"]
        controller.videoQuality = .typeMedium
        controller.videoMaximumDuration = 60
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, onFinish: { dismiss() })
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onCapture: (PickedMedia) -> Void
        private let onFinish: () -> Void

        init(onCapture: @escaping (PickedMedia) -> Void, onFinish: @escaping () -> Void) {
            self.onCapture = onCapture
            self.onFinish = onFinish
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let movie = info[.mediaURL] as? URL {
                // The controller's temporary file can vanish, so keep our own copy.
                let copy = FileManager.default.temporaryDirectory
                    .appendingPathComponent("kudao-capture-\(UUID().uuidString).mov")
                if (try? FileManager.default.copyItem(at: movie, to: copy)) != nil {
                    onCapture(.video(copy))
                }
            } else if let image = info[.originalImage] as? UIImage,
                      let data = image.jpegData(compressionQuality: 0.9) {
                onCapture(.photo(data))
            }
            onFinish()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onFinish()
        }
    }
}
