//
//  GalleryCaptionSheet.swift
//  Kudao
//

import SwiftUI

/// Last step before a batch of memories goes up: one short line each.
///
/// Captions are optional; the sheet always offers a way straight to the upload.
struct GalleryCaptionSheet: View {
    let onConfirm: ([PendingUpload]) -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var drafts: [PendingUpload]
    @FocusState private var focused: UUID?

    init(uploads: [PendingUpload], onConfirm: @escaping ([PendingUpload]) -> Void) {
        self.onConfirm = onConfirm
        _drafts = State(initialValue: uploads)
    }

    private var strings: Strings { settings.strings }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 14) {
                        Text(strings.galleryCaptionSheetMessage)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)

                        ForEach($drafts) { $draft in
                            row($draft)
                        }

                        Button {
                            confirm()
                        } label: {
                            Text(strings.galleryUploadAction)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Capsule().fill(Palette.warmGradient))
                                .shadow(color: Palette.coral.opacity(0.3), radius: 14, y: 8)
                        }
                        .buttonStyle(PressableCardStyle())
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(strings.galleryCaptionSheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(strings.cancelAction) { dismiss() }
                        .font(.system(.body, design: .rounded))
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(strings.doneAction) { focused = nil }
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                }
            }
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.coral)
    }

    private func row(_ draft: Binding<PendingUpload>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            preview(draft.wrappedValue)

            VStack(alignment: .leading, spacing: 6) {
                TextField(
                    strings.galleryCaptionPlaceholder,
                    text: draft.caption,
                    axis: .vertical
                )
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .lineLimit(1...3)
                .focused($focused, equals: draft.wrappedValue.id)
                .onChange(of: draft.wrappedValue.caption) { _, value in
                    if value.count > GalleryItem.captionLimit {
                        draft.wrappedValue.caption = String(value.prefix(GalleryItem.captionLimit))
                    }
                }

                HStack {
                    Spacer(minLength: 0)
                    Text("\(draft.wrappedValue.caption.count)/\(GalleryItem.captionLimit)")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }

    private func preview(_ draft: PendingUpload) -> some View {
        Palette.surfaceRaised
            .frame(width: 74, height: 74)
            .overlay {
                if let data = draft.previewData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                } else {
                    Image(systemName: draft.isVideo ? "play.circle.fill" : "photo.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .clipShape(.rect(cornerRadius: 14, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                if draft.isVideo {
                    Image(systemName: "play.fill")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(Circle().fill(.black.opacity(0.55)))
                        .padding(5)
                }
            }
    }

    private func confirm() {
        onConfirm(drafts)
        dismiss()
    }
}
