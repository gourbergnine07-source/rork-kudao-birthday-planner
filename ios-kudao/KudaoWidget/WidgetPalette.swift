//
//  WidgetPalette.swift
//  KudaoWidget
//
//  Warm Kudao palette, duplicated here because the widget is a separate binary.
//

import SwiftUI
import UIKit

nonisolated enum WidgetPalette {
    static var coral: Color { dynamic(0xF2542D, 0xFF7A4E) }
    static var berry: Color { dynamic(0xC42A6B, 0xFF6FA5) }
    static var cream: Color { dynamic(0xFFF5EC, 0x120E0D) }

    static var warmGradient: LinearGradient {
        LinearGradient(
            colors: [
                dynamic(0xF2542D, 0xE3502C),
                dynamic(0xFF8A3D, 0xF07B33),
                dynamic(0xFFB03A, 0xE59A2E),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func dynamic(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            uiColor(traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    static func uiColor(_ hex: UInt32) -> UIColor {
        UIColor(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
