//
//  FilledFieldHighlight.swift
//  Kudao
//

import SwiftUI

/// Which parts of the profile form a contact import just wrote into.
enum FilledField: Hashable {
    case photo
    case name
    case date
    case contact
}

/// A short glow around a field that was just filled in for the user.
///
/// Importing a contact changes several fields at once, some of them below the
/// fold. The outline makes it obvious what the app touched — and, just as
/// usefully, what it left alone — then fades away so the form goes back to
/// looking ordinary.
private struct FilledFieldHighlight: ViewModifier {
    let isActive: Bool
    let shape: AnyShape

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .background {
                shape
                    .fill(Palette.sage.opacity(isActive ? 0.14 : 0))
            }
            .overlay {
                shape
                    .stroke(Palette.sage.opacity(isActive ? 0.9 : 0), lineWidth: 2)
                    .shadow(color: Palette.sage.opacity(isActive ? 0.35 : 0), radius: 10)
                    .allowsHitTesting(false)
            }
            .scaleEffect(isActive && !reduceMotion ? 1.012 : 1)
            .animation(reduceMotion ? .easeOut(duration: 0.2) : .smooth(duration: 0.35), value: isActive)
    }
}

extension View {
    /// Outlines a card that a contact import just filled in.
    func filledFieldHighlight(_ isActive: Bool, cornerRadius: CGFloat = 22) -> some View {
        modifier(
            FilledFieldHighlight(
                isActive: isActive,
                shape: AnyShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
        )
    }

    /// Same glow, around a round element such as the avatar.
    func filledFieldHighlightCircle(_ isActive: Bool) -> some View {
        modifier(FilledFieldHighlight(isActive: isActive, shape: AnyShape(Circle())))
    }
}
