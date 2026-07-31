//
//  DiaryCategory.swift
//  Kudao
//

import SwiftUI

/// Buckets the AI extraction can assign to a diary note.
/// Raw values match the JSON contract used in the extraction prompt.
nonisolated enum DiaryCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case food = "cibo"
    case travel = "viaggi"
    case shopping = "shopping"
    case hobby = "hobby"
    case places = "luoghi"
    case other = "altro"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .food: "fork.knife"
        case .travel: "airplane.departure"
        case .shopping: "bag.fill"
        case .hobby: "paintpalette.fill"
        case .places: "mappin.and.ellipse"
        case .other: "sparkles"
        }
    }

    /// Tolerant parsing: the model may answer with a synonym or a different case.
    static func parse(_ raw: String) -> DiaryCategory {
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let exact = DiaryCategory(rawValue: normalized) { return exact }
        switch normalized {
        case "food", "comida", "cuisine", "nourriture": return .food
        case "travel", "viajes", "voyages", "viaggio": return .travel
        case "compras", "shopping list", "acquisti": return .shopping
        case "hobbies", "aficiones", "loisirs", "hobbys": return .hobby
        case "places", "lugares", "lieux", "posti": return .places
        default: return .other
        }
    }
}

extension DiaryCategory {
    @MainActor
    var accent: Color {
        switch self {
        case .food: Palette.coral
        case .travel: Palette.teal
        case .shopping: Palette.berry
        case .hobby: Palette.amber
        case .places: Palette.violet
        case .other: Palette.clay
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .food: strings.catFood
        case .travel: strings.catTravel
        case .shopping: strings.catShopping
        case .hobby: strings.catHobby
        case .places: strings.catPlaces
        case .other: strings.catOther
        }
    }
}
