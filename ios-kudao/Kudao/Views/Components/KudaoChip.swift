//
//  KudaoChip.swift
//  Kudao
//

import SwiftUI

/// Small pill used for relationship and surprise-mode labels.
struct KudaoChip: View {
    let title: String
    let systemImage: String
    var tint: Color = Palette.coral
    var onDark: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .bold))
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
        }
        .foregroundStyle(onDark ? Color.white : tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(onDark ? Color.white.opacity(0.22) : tint.opacity(0.14))
        )
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    HStack {
        KudaoChip(title: "Partner", systemImage: "heart.fill")
        KudaoChip(title: "Sorpresa", systemImage: "eye.slash.fill", tint: Palette.berry)
    }
    .padding()
}
