//
//  PlaceholderPanel.swift
//  Kudao
//

import SwiftUI

/// Friendly empty state used across tabs and search results.
struct PlaceholderPanel: View {
    let icon: String
    let title: String
    let message: String
    var badge: String?
    var tint: Color = Palette.coral

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.14))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(tint)
            }

            Text(title)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)

            Text(message)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let badge {
                Text(badge.uppercased())
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(tint.opacity(0.12)))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }
}
