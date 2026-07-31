//
//  GreetingTone.swift
//  Kudao
//

import Foundation

/// Voice used by the AI when writing the prepared text.
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

    /// A remembrance is never funny: only two voices are offered there.
    static func available(for occasion: OccasionKind) -> [GreetingTone] {
        occasion == .remembrance ? [.warm, .elegant] : allCases
    }

    /// Falls back to a voice the occasion allows.
    func resolved(for occasion: OccasionKind) -> GreetingTone {
        Self.available(for: occasion).contains(self) ? self : .warm
    }

    /// How the tone reads for a remembrance, where "warm" means intimate, not cheerful.
    func title(_ strings: Strings, occasion: OccasionKind) -> String {
        guard occasion == .remembrance else { return title(strings) }
        switch self {
        case .warm: return strings.toneIntimate
        case .elegant: return strings.toneSober
        case .funny: return title(strings)
        }
    }

    /// Instruction handed to the model, adapted to what is being written.
    func promptInstruction(for occasion: OccasionKind) -> String {
        guard occasion == .remembrance else { return promptInstruction }
        switch self {
        case .warm: return "intimate and tender, the voice of someone who loved them, without pathos"
        case .elegant: return "sober and restrained, few words, quiet dignity"
        case .funny: return "gently affectionate, allowing one fond smile at a shared memory, never a joke"
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
