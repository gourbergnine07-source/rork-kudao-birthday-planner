//
//  CountdownRing.swift
//  Kudao
//

import SwiftUI

/// A progress ring that fills as the birthday approaches, with the day count inside.
struct CountdownRing: View {
    let progress: Double
    let value: String
    let caption: String
    var tint: Color = Palette.coral
    var size: CGFloat = 62

    @State private var animatedProgress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.16), lineWidth: 5)

            Circle()
                .trim(from: 0, to: max(0.02, animatedProgress))
                .stroke(
                    AngularGradient(
                        colors: [tint.opacity(0.55), tint],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: -2) {
                Text(value)
                    .font(.system(size: size * 0.34, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                Text(caption)
                    .font(.system(size: size * 0.16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            if reduceMotion {
                animatedProgress = progress
            } else {
                withAnimation(.smooth(duration: 0.9).delay(0.05)) {
                    animatedProgress = progress
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.smooth(duration: 0.5)) { animatedProgress = newValue }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        CountdownRing(progress: 0.8, value: "12", caption: "giorni")
        CountdownRing(progress: 1, value: "0", caption: "oggi", tint: Palette.berry)
    }
    .padding()
}
