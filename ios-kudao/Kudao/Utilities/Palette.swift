//
//  Palette.swift
//  Kudao
//

import SwiftUI
import UIKit

/// Warm celebration palette. Every color adapts to light and dark appearance.
enum Palette {
    nonisolated static var background: Color { dynamic(0xFFF5EC, 0x120E0D) }
    nonisolated static var surface: Color { dynamic(0xFFFFFF, 0x1E1815) }
    nonisolated static var surfaceRaised: Color { dynamic(0xFFEFE3, 0x2A211C) }
    nonisolated static var hairline: Color { dynamic(0xF0DCCB, 0x352923) }

    nonisolated static var coral: Color { dynamic(0xF2542D, 0xFF7A4E) }
    nonisolated static var amber: Color { dynamic(0xE89412, 0xFFB44D) }
    nonisolated static var berry: Color { dynamic(0xC42A6B, 0xFF6FA5) }
    nonisolated static var clay: Color { dynamic(0xA0563B, 0xC9866A) }
    nonisolated static var plum: Color { dynamic(0x5B1E2B, 0x2A1216) }
    nonisolated static var teal: Color { dynamic(0x11776B, 0x4FC9B5) }
    nonisolated static var violet: Color { dynamic(0x6B45A6, 0xB79BFF) }

    /// Muted sage, reserved for remembrance profiles.
    nonisolated static var sage: Color { dynamic(0x5F7F6B, 0x9CC0A9) }
    /// Dusty blue that pairs with sage in the remembrance surfaces.
    nonisolated static var dusk: Color { dynamic(0x4F6E86, 0x93B6CE) }

    nonisolated static var warmGradient: LinearGradient {
        LinearGradient(
            colors: [dynamic(0xF2542D, 0xE3502C), dynamic(0xFF8A3D, 0xF07B33), dynamic(0xFFB03A, 0xE59A2E)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Anniversary gradient: deep rose into warm gold.
    nonisolated static var vowGradient: LinearGradient {
        LinearGradient(
            colors: [dynamic(0xB02A63, 0xA82A5F), dynamic(0xD9527F, 0xC44A72), dynamic(0xE0975F, 0xCC8654)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Remembrance gradient: sage drifting into dusty blue. Quiet on purpose.
    nonisolated static var stillGradient: LinearGradient {
        LinearGradient(
            colors: [dynamic(0x5F7F6B, 0x3F5A4B), dynamic(0x557488, 0x39505F), dynamic(0x6E8FA3, 0x475F6E)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Generic event gradient: dusty blue drifting into slate, the "other" family.
    nonisolated static var eventGradient: LinearGradient {
        LinearGradient(
            colors: [dynamic(0x3F5D74, 0x354F63), dynamic(0x4F6E86, 0x415F73), dynamic(0x7092A8, 0x577487)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    nonisolated static func dynamic(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            uiColor(traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    nonisolated static func uiColor(_ hex: UInt32) -> UIColor {
        UIColor(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            alpha: 1
        )
    }

    /// Stable per-person accent pair used for avatar fallbacks.
    nonisolated static func avatarGradient(for seed: String) -> LinearGradient {
        let pairs: [(UInt32, UInt32)] = [
            (0xFF9C6B, 0xF2542D),
            (0xFFC46B, 0xE8891A),
            (0xFF8FB1, 0xC42A6B),
            (0xD9A05B, 0xA0563B),
            (0xFFB07C, 0xD94F30)
        ]
        let index = abs(seed.unicodeScalars.reduce(into: 0) { $0 = ($0 &* 31 &+ Int($1.value)) % 9_973 }) % pairs.count
        let pair = pairs[index]
        return LinearGradient(
            colors: [Color(uiColor: uiColor(pair.0)), Color(uiColor: uiColor(pair.1))],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
