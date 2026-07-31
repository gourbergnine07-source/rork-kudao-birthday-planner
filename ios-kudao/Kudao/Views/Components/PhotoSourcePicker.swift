//
//  PhotoSourcePicker.swift
//  Kudao
//

import PhotosUI
import SwiftUI

/// Tappable wrapper that turns any label into a full profile-photo picker.
///
/// It offers camera and library, asks for the right permission, sends what came
/// back through the circular crop editor, and hands over compressed JPEG bytes.
struct PhotoSourcePicker<Content: View>: View {
    let onPicked: (Data) -> Void
    /// Provided only when the current photo can be dropped.
    var onRemoved: (() -> Void)?
    @ViewBuilder var label: () -> Content

    @Environment(AppSettings.self) private var settings

    @State private var pickerItem: PhotosPickerItem?
    @State private var isPickingFromLibrary: Bool = false
    @State private var isCapturing: Bool = false
    @State private var cropSubject: CropSubject?
    @State private var deniedSource: MediaSource?
    @State private var isLoading: Bool = false

    private var strings: Strings { settings.strings }

    var body: some View {
        Menu {
            if CameraCaptureView.isAvailable {
                Button {
                    startCamera()
                } label: {
                    Label(strings.photoSourceCameraAction, systemImage: "camera.fill")
                }
            }

            Button {
                startLibrary()
            } label: {
                Label(strings.photoSourceLibraryAction, systemImage: "photo.on.rectangle.angled")
            }

            if let onRemoved {
                Divider()
                Button(role: .destructive) {
                    onRemoved()
                } label: {
                    Label(strings.removePhoto, systemImage: "trash")
                }
            }
        } label: {
            label()
                .overlay {
                    if isLoading {
                        Circle()
                            .fill(.black.opacity(0.35))
                            .overlay { ProgressView().tint(.white) }
                            .allowsHitTesting(false)
                    }
                }
        }
        .accessibilityLabel(onRemoved == nil ? strings.addPhoto : strings.changePhoto)
        .photosPicker(isPresented: $isPickingFromLibrary, selection: $pickerItem, matching: .images)
        .fullScreenCover(isPresented: $isCapturing) {
            CameraCaptureView(
                onCapture: { media in
                    guard case .photo(let data) = media, let image = UIImage(data: data) else { return }
                    cropSubject = CropSubject(image: image)
                },
                allowsVideo: false
            )
            .ignoresSafeArea()
        }
        .sheet(item: $cropSubject) { subject in
            PhotoCropView(image: subject.image) { data in
                onPicked(data)
            }
        }
        .alert(
            deniedSource?.deniedTitle(strings) ?? "",
            isPresented: Binding(
                get: { deniedSource != nil },
                set: { if !$0 { deniedSource = nil } }
            ),
            presenting: deniedSource
        ) { _ in
            Button(strings.openSettingsAction) { MediaPermissions.openSettings() }
            Button(strings.cancelAction, role: .cancel) {}
        } message: { source in
            Text(source.deniedMessage(strings))
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            load(item)
        }
    }

    // MARK: - Sources

    private func startCamera() {
        Task {
            guard await MediaPermissions.requestCamera() else {
                deniedSource = .camera
                return
            }
            isCapturing = true
        }
    }

    private func startLibrary() {
        Task {
            guard await MediaPermissions.requestPhotoLibrary() else {
                deniedSource = .photoLibrary
                return
            }
            isPickingFromLibrary = true
        }
    }

    /// Loads the picked asset, then opens the crop editor.
    private func load(_ item: PhotosPickerItem) {
        isLoading = true
        Task {
            let data = try? await item.loadTransferable(type: Data.self)
            pickerItem = nil
            isLoading = false

            guard let data, let image = UIImage(data: data) else { return }
            cropSubject = CropSubject(image: image)
        }
    }
}

/// Identifiable box so the crop editor can be presented from an optional image.
private struct CropSubject: Identifiable {
    let id: UUID = UUID()
    let image: UIImage
}
