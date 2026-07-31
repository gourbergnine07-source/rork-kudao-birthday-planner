//
//  ConfettiView.swift
//  Kudao
//

import SwiftUI

/// Lightweight canvas confetti used on the day of a birthday.
struct ConfettiView: View {
    var colors: [Color] = [.white, Color(uiColor: Palette.uiColor(0xFFE29A)), Color(uiColor: Palette.uiColor(0xFFC2D1))]
    var pieceCount: Int = 26

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Piece {
        let x: Double
        let phase: Double
        let speed: Double
        let width: Double
        let height: Double
        let colorIndex: Int
        let spin: Double
    }

    private var pieces: [Piece] {
        var generator = SeededGenerator(seed: 20_260_731)
        return (0..<pieceCount).map { index in
            Piece(
                x: Double.random(in: 0.02...0.98, using: &generator),
                phase: Double.random(in: 0...1, using: &generator),
                speed: Double.random(in: 0.09...0.22, using: &generator),
                width: Double.random(in: 3.5...7, using: &generator),
                height: Double.random(in: 6...12, using: &generator),
                colorIndex: index % max(1, colors.count),
                spin: Double.random(in: 0.6...2.4, using: &generator)
            )
        }
    }

    var body: some View {
        let items = pieces
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1.0 / 30.0)) { context in
            Canvas { canvas, size in
                let time = reduceMotion ? 0.35 : context.date.timeIntervalSinceReferenceDate
                for piece in items {
                    let cycle = (time * piece.speed + piece.phase).truncatingRemainder(dividingBy: 1)
                    let y = cycle * (size.height + 24) - 12
                    let drift = sin((time * 0.9) + piece.phase * 8) * 10
                    let x = piece.x * size.width + drift
                    let rect = CGRect(
                        x: -piece.width / 2,
                        y: -piece.height / 2,
                        width: piece.width,
                        height: piece.height
                    )
                    var layer = canvas
                    layer.translateBy(x: x, y: y)
                    layer.rotate(by: .radians(time * piece.spin + piece.phase * 6))
                    layer.opacity = 0.55 + 0.35 * (1 - cycle)
                    layer.fill(
                        Path(roundedRect: rect, cornerRadius: 1.5),
                        with: .color(colors[piece.colorIndex])
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Deterministic RNG so confetti layout is stable between renders.
nonisolated struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
