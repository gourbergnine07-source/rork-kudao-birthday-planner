//
//  GiftShopping.swift
//  Kudao
//

import Foundation

/// Where the "buy online" button sends the user for one gift idea.
nonisolated enum GiftDestination: Equatable, Sendable {
    /// Amazon search on a storefront Kudao has an Associates tag for.
    case amazon(URL, marketplace: AmazonMarketplace)
    /// Plain Google Shopping search, used when no tag is configured.
    case webSearch(URL)

    var url: URL {
        switch self {
        case .amazon(let url, _): url
        case .webSearch(let url): url
        }
    }

    /// True when the link earns a commission and therefore needs the disclosure.
    var isAffiliate: Bool {
        switch self {
        case .amazon: true
        case .webSearch: false
        }
    }
}

/// Builds the external shopping search for the AI-generated gift idea.
///
/// The query always comes from `PartyPlan.giftIdea`: Kudao never lets the user
/// type a gift by hand outside the diary → suggestions flow.
nonisolated enum GiftShopping {
    /// Best destination for a gift idea: Amazon when a tag exists, Google otherwise.
    ///
    /// - Parameter affiliateTags: Associates tags keyed by `AmazonMarketplace.rawValue`.
    static func destination(
        for giftIdea: String,
        language: AppLanguage,
        affiliateTags: [String: String]
    ) -> GiftDestination? {
        let marketplace = AmazonMarketplace.resolve(language: language)
        let tag = affiliateTags[marketplace.rawValue]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if !tag.isEmpty, let url = amazonSearchURL(for: giftIdea, marketplace: marketplace, tag: tag) {
            return .amazon(url, marketplace: marketplace)
        }

        guard let fallback = searchURL(for: giftIdea, language: language) else { return nil }
        return .webSearch(fallback)
    }

    /// Amazon search on one storefront, carrying the Associates tag.
    static func amazonSearchURL(
        for giftIdea: String,
        marketplace: AmazonMarketplace,
        tag: String
    ) -> URL? {
        let trimmed = giftIdea.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !cleanTag.isEmpty else { return nil }

        var components = URLComponents()
        components.scheme = "https"
        components.host = marketplace.host
        components.path = "/s"
        components.queryItems = [
            URLQueryItem(name: "k", value: trimmed),
            URLQueryItem(name: "tag", value: cleanTag)
        ]
        return components.url
    }

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
