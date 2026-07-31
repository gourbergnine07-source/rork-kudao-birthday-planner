//
//  ParticipantStack.swift
//  Kudao
//

import SwiftUI

/// Overlapping avatars of the people who share a profile.
///
/// Falls back to a single "person" bubble when nobody has joined yet, so the
/// row keeps its shape while an invite is still pending.
struct ParticipantStack: View {
    let names: [String]
    var size: CGFloat = 26
    var ringColor: Color = Palette.surface
    var maxVisible: Int = 4
    var placeholderTint: Color = Palette.violet

    private var visible: [String] {
        Array(names.prefix(maxVisible))
    }

    private var extra: Int {
        max(0, names.count - visible.count)
    }

    var body: some View {
        HStack(spacing: -size * 0.34) {
            if visible.isEmpty {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(placeholderTint)
                    .frame(width: size, height: size)
                    .background(Circle().fill(placeholderTint.opacity(0.16)))
                    .overlay(Circle().strokeBorder(ringColor, lineWidth: 2))
            } else {
                ForEach(Array(visible.enumerated()), id: \.offset) { index, name in
                    AvatarView(
                        name: name.isEmpty ? "?" : name,
                        photoData: nil,
                        size: size,
                        ringColor: ringColor,
                        ringWidth: 2
                    )
                    .zIndex(Double(maxVisible - index))
                }
            }

            if extra > 0 {
                Text("+\(extra)")
                    .font(.system(size: size * 0.36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(width: size, height: size)
                    .background(Circle().fill(Palette.surfaceRaised))
                    .overlay(Circle().strokeBorder(ringColor, lineWidth: 2))
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 20) {
        ParticipantStack(names: ["Giulia", "Marco", "Anna", "Luca", "Sara"])
        ParticipantStack(names: [])
    }
    .padding()
    .background(Palette.background)
}
