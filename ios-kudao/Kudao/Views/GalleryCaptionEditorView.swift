//
//  GalleryCaptionEditorView.swift
//  Kudao
//

import SwiftUI

/// Writes or rewrites the caption of a memory already in the gallery.
struct GalleryCaptionEditorView: View {
    let item: GalleryItem
    let onSave: (String) -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var text: String
    @FocusState private var isFocused: Bool

    init(item: GalleryItem, onSave: @escaping (String) -> Void) {
        self.item = item
        self.onSave = onSave
        _text = State(initialValue: item.caption)
    }

    private var strings: Strings { settings.strings }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                VStack(spacing: 18) {
                    if let data = item.thumbnailData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 132, height: 132)
                            .clipShape(.rect(cornerRadius: 20, style: .continuous))
                            .shadow(color: .black.opacity(0.14), radius: 12, y: 6)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        TextField(strings.galleryCaptionPlaceholder, text: $text, axis: .vertical)
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .lineLimit(2...5)
                            .focused($isFocused)
                            .onChange(of: text) { _, value in
                                if value.count > GalleryItem.captionLimit {
                                    text = String(value.prefix(GalleryItem.captionLimit))
                                }
                            }

                        HStack {
                            Spacer(minLength: 0)
                            Text("\(text.count)/\(GalleryItem.captionLimit)")
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(.tertiary)
                                .monospacedDigit()
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Palette.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Palette.hairline, lineWidth: 1)
                    )

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
            }
            .navigationTitle(strings.galleryCaptionEditorTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(strings.cancelAction) { dismiss() }
                        .font(.system(.body, design: .rounded))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(strings.saveAction) {
                        onSave(text)
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
            .onAppear { isFocused = true }
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.coral)
        .presentationDetents([.medium, .large])
    }
}
