//
//  WarmBackdrop.swift
//  Kudao
//

import SwiftUI

/// Soft, atmospheric background with warm blurred light blooms.
struct WarmBackdrop: View {
    var body: some View {
        ZStack {
            Palette.background

            GeometryReader { proxy in
                let width = proxy.size.width
                ZStack {
                    Circle()
                        .fill(Palette.coral.opacity(0.22))
                        .frame(width: width * 0.9)
                        .blur(radius: 90)
                        .offset(x: -width * 0.28, y: -width * 0.22)

                    Circle()
                        .fill(Palette.amber.opacity(0.20))
                        .frame(width: width * 0.75)
                        .blur(radius: 90)
                        .offset(x: width * 0.42, y: width * 0.05)

                    Circle()
                        .fill(Palette.berry.opacity(0.12))
                        .frame(width: width * 0.7)
                        .blur(radius: 100)
                        .offset(x: -width * 0.1, y: width * 1.05)
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    WarmBackdrop()
}
