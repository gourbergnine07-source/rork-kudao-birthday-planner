//
//  GreetingTone.swift
//  Kudao
//

import Foundation

/// Voice used by the AI when writing the birthday message.
nonisolated enum GreetingTone: String, CaseIterable, Identifiable, Sendable {
    case warm
    case funny
    case elegant

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .warm: "heart.fill"
        case .funny: "face.smiling.inverse"
        case .elegant: "sparkle"
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .warm: strings.toneWarm
        case .funny: strings.toneFunny
        case .elegant: strings.toneElegant
        }
    }

    /// Instruction handed to the model.
    var promptInstruction: String {
        switch self {
        case .warm: "affectionate and sincere, like a close person speaking from the heart"
        case .funny: "playful and witty, with one light joke, never sarcastic or mean"
        case .elegant: "elegant and composed, warm but polished, no slang"
        }
    }
}
