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

    nonisolated static var warmGradient: LinearGradient {
        LinearGradient(
            colors: [dynamic(0xF2542D, 0xE3502C), dynamic(0xFF8A3D, 0xF07B33), dynamic(0xFFB03A, 0xE59A2E)],
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
