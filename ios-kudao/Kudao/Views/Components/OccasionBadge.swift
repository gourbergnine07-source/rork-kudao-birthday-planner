//
//  OccasionBadge.swift
//  Kudao
//

import SwiftUI

/// Small coloured pill that tells a birthday from a wedding at a glance.
struct OccasionBadge: View {
    let occasion: OccasionKind
    let strings: Strings
    /// Compact drops the label and keeps only the tinted glyph.
    var isCompact: Bool = false
    /// On a coloured header the pill turns translucent white instead.
    var onDark: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: occasion.symbolName)
                .font(.system(size: isCompact ? 9 : 10, weight: .bold))
            if !isCompact {
                Text(occasion.title(strings))
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(onDark ? Color.white : occasion.accent)
        .padding(.horizontal, isCompact ? 6 : 8)
        .padding(.vertical, isCompact ? 4 : 5)
        .background(
            Capsule().fill(onDark ? Color.white.opacity(0.22) : occasion.accent.opacity(0.14))
        )
        .overlay(
            Capsule().strokeBorder(
                onDark ? Color.white.opacity(0.4) : occasion.accent.opacity(0.28),
                lineWidth: 1
            )
        )
        .accessibilityLabel(occasion.title(strings))
    }
}

/// The wedding glyph SF Symbols does not ship: two interlocking rings.
struct WeddingRings: View {
    var lineWidth: CGFloat = 2.4

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let diameter = side * 0.68
            let overlap = diameter * 0.34

            ZStack {
                Circle()
                    .strokeBorder(lineWidth: lineWidth)
                    .frame(width: diameter, height: diameter)
                    .offset(x: -overlap / 2)
                Circle()
                    .strokeBorder(lineWidth: lineWidth)
                    .frame(width: diameter, height: diameter)
                    .offset(x: overlap / 2)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

/// The icon used on the big occasion cards: rings are drawn, the rest are symbols.
struct OccasionGlyph: View {
    let occasion: OccasionKind
    var size: CGFloat = 30

    var body: some View {
        Group {
            if occasion == .wedding {
                WeddingRings(lineWidth: size * 0.09)
                    .frame(width: size * 1.25, height: size)
            } else {
                Image(systemName: occasion.symbolName)
                    .font(.system(size: size, weight: .medium))
            }
        }
        .accessibilityHidden(true)
    }
}
