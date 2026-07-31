//
//  GiftShopping.swift
//  Kudao
//

import Foundation

/// Builds the external shopping search for the AI-generated gift idea.
///
/// The query always comes from `PartyPlan.giftIdea`: Kudao never lets the user
/// type a gift by hand outside the diary → suggestions flow.
nonisolated enum GiftShopping {
    /// Google Shopping search for one gift idea, or nil when the idea is empty.
    static func searchURL(for giftIdea: String, language: AppLanguage) -> URL? {
        let trimmed = giftIdea.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [
            URLQueryItem(name: "tbm", value: "shop"),
            URLQueryItem(name: "q", value: trimmed),
            URLQueryItem(name: "hl", value: language.rawValue)
        ]
        return components?.url
    }
}
