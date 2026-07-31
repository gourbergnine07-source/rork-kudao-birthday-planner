//
//  SearchField.swift
//  Kudao
//

import SwiftUI

/// Rounded search field matching the warm Kudao surfaces.
struct SearchField: View {
    let placeholder: String
    let clearLabel: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isFocused ? Palette.coral : .secondary)

            TextField(placeholder, text: $text)
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(clearLabel)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            Capsule().fill(Palette.surface)
        )
        .overlay(
            Capsule().strokeBorder(isFocused ? Palette.coral.opacity(0.55) : Palette.hairline, lineWidth: 1)
        )
        .animation(.smooth(duration: 0.22), value: isFocused)
        .animation(.smooth(duration: 0.22), value: text.isEmpty)
    }
}
