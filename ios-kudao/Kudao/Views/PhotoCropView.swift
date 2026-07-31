//
//  PhotoCropView.swift
//  Kudao
//

import SwiftUI

/// Simple circular crop editor: drag to move, pinch to zoom, tap to confirm.
///
/// The confirmed photo is rendered from exactly the same view the user framed, so
/// what they see inside the circle is what ends up on the profile.
struct PhotoCropView: View {
    let image: UIImage
    let onConfirm: (Data) -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1
    @State private var committedScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var committedOffset: CGSize = .zero
    @State private var isRendering: Bool = false

    private var strings: Strings { settings.strings }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let side = min(geometry.size.width - 40, geometry.size.height - 220)

                VStack(spacing: 22) {
                    Spacer(minLength: 0)

                    PhotoCropCanvas(image: image, side: side, scale: scale, offset: offset)
                        .overlay {
                            // Everything outside the circle dims so the framing reads instantly.
                            ZStack {
                                CropMask().fill(.black.opacity(0.5), style: FillStyle(eoFill: true))
                                Circle().strokeBorder(.white.opacity(0.9), lineWidth: 2)
                            }
                            .allowsHitTesting(false)
                        }
                        .clipShape(.rect(cornerRadius: 18, style: .continuous))
                        .gesture(dragGesture(side: side))
                        .simultaneousGesture(magnifyGesture(side: side))

                    Text(strings.photoCropHint)
                        .font(.system(.footnote, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button {
                        confirm(side: side)
                    } label: {
                        Text(strings.photoUseAction)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Capsule().fill(Palette.warmGradient))
                            .shadow(color: Palette.coral.opacity(0.32), radius: 14, y: 8)
                            .overlay {
                                if isRendering {
                                    ProgressView().tint(.white)
                                }
                            }
                    }
                    .buttonStyle(PressableCardStyle())
                    .disabled(isRendering)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            }
            .background(Palette.background)
            .navigationTitle(strings.photoCropTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(strings.cancelAction) { dismiss() }
                        .font(.system(.body, design: .rounded))
                }
            }
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.coral)
    }

    // MARK: - Gestures

    private func dragGesture(side: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                offset = clamp(
                    CGSize(
                        width: committedOffset.width + value.translation.width,
                        height: committedOffset.height + value.translation.height
                    ),
                    side: side
                )
            }
            .onEnded { _ in
                committedOffset = offset
            }
    }

    private func magnifyGesture(side: CGFloat) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                scale = min(4, max(1, committedScale * value.magnification))
                offset = clamp(offset, side: side)
            }
            .onEnded { _ in
                committedScale = scale
                committedOffset = offset
            }
    }

    /// Keeps the photo covering the circle, so no empty corner can be framed.
    private func clamp(_ candidate: CGSize, side: CGFloat) -> CGSize {
        let displayed = displayedSize(side: side)
        let limitX = max(0, (displayed.width * scale - side) / 2)
        let limitY = max(0, (displayed.height * scale - side) / 2)

        return CGSize(
            width: min(limitX, max(-limitX, candidate.width)),
            height: min(limitY, max(-limitY, candidate.height))
        )
    }

    /// Size the photo occupies once it fills the square frame.
    private func displayedSize(side: CGFloat) -> CGSize {
        let width = max(1, image.size.width)
        let height = max(1, image.size.height)
        let aspect = width / height

        return aspect >= 1
            ? CGSize(width: side * aspect, height: side)
            : CGSize(width: side, height: side / aspect)
    }

    // MARK: - Rendering

    @MainActor
    private func confirm(side: CGFloat) {
        guard side > 0 else { return }
        isRendering = true

        let renderer = ImageRenderer(
            content: PhotoCropCanvas(image: image, side: side, scale: scale, offset: offset)
        )
        // Render straight at the stored resolution, whatever the framing side was.
        renderer.scale = ImageDownscaler.profileMaxDimension / side
        renderer.isOpaque = true

        guard let rendered = renderer.uiImage,
              let data = ImageDownscaler.compress(rendered) else {
            isRendering = false
            return
        }

        isRendering = false
        onConfirm(data)
        dismiss()
    }
}

/// The framed square, shared by the editor and the final render.
private struct PhotoCropCanvas: View {
    let image: UIImage
    let side: CGFloat
    let scale: CGFloat
    let offset: CGSize

    var body: some View {
        Color.black
            .frame(width: side, height: side)
            .overlay {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: side, height: side)
                    .scaleEffect(scale)
                    .offset(offset)
                    .allowsHitTesting(false)
            }
            .clipped()
    }
}

/// Square with a circular hole, filled with the even-odd rule to dim the outside.
private struct CropMask: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        path.addEllipse(in: rect)
        return path
    }
}
