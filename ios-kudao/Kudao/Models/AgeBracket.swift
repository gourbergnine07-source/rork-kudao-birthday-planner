//
//  AgeBracket.swift
//  Kudao
//

import Foundation

/// Life stage derived from the birth date, used to keep every AI suggestion age-appropriate.
///
/// Raw values stay Italian because they travel inside the prompts as `fascia_eta`,
/// the same convention the plan JSON keys already follow.
nonisolated enum AgeBracket: String, CaseIterable, Identifiable, Sendable {
    case child = "bambino"
    case teen = "adolescente"
    case adult = "adulto"
    case senior = "anziano"

    var id: String { rawValue }

    /// 0-12 child, 13-17 teen, 18-64 adult, 65+ senior.
    static func forAge(_ age: Int) -> AgeBracket {
        switch age {
        case ..<13: .child
        case 13...17: .teen
        case 18...64: .adult
        default: .senior
        }
    }

    var symbolName: String {
        switch self {
        case .child: "teddybear.fill"
        case .teen: "gamecontroller.fill"
        case .adult: "figure.wave"
        case .senior: "leaf.fill"
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .child: strings.ageBracketChild
        case .teen: strings.ageBracketTeen
        case .adult: strings.ageBracketAdult
        case .senior: strings.ageBracketSenior
        }
    }

    /// Only children get the optional "favourite character" field in the profile form.
    var wantsFavoriteCharacter: Bool { self == .child }

    /// Guidance handed to the planner so gift, cake and venue fit the life stage.
    var planGuidance: String {
        switch self {
        case .child:
            return """
            Child (0-12). Gifts: toys, games, building sets, creative or outdoor kits, books for \
            their reading level. Cake: themed and colourful, kid-friendly flavours. Venue: family \
            friendly (home party, playground, farm, pool, amusement or trampoline park). \
            Guest count includes classmates and family. Never suggest alcohol, nightlife, \
            perfume, expensive tech or anything unsafe for a child.
            """
        case .teen:
            return """
            Teenager (13-17). Gifts: hobbies, gaming, music, sport, style, small accessories, \
            experiences with friends. Cake: modern and not childish. Venue: pizzeria, bowling, \
            karaoke, escape room, beach or a party at home with friends. \
            Never suggest alcohol, nightclubs or anything for adults only.
            """
        case .adult:
            return """
            Adult (18-64). Gifts, cake and venue can be anything that fits an adult life: \
            experiences, hobbies, design objects, restaurants, wine bars, short trips.
            """
        case .senior:
            return """
            Senior (65+). Gifts: meaningful, comfortable and practical — memories and photo books, \
            plants, quality food, warm clothing, hobbies, an experience with the family. \
            Cake: classic, less sugary, traditional flavours. Venue: calm and comfortable — home, \
            a traditional restaurant, a family lunch. Keep the guest count intimate. \
            Avoid loud parties, nightclubs, complicated technology and gadgets that need setup.
            """
        }
    }

    /// Guidance handed to the greeting writer so the wording fits the life stage.
    var greetingGuidance: String {
        switch self {
        case .child:
            return "simple and playful words a child understands, short sentences, no irony, no sarcasm"
        case .teen:
            return "informal and current, close to how a teenager speaks, never forced adult slang"
        case .adult:
            return "a natural adult register"
        case .senior:
            return "respectful, warm and unhurried, happy to look back at shared time together"
        }
    }
}
