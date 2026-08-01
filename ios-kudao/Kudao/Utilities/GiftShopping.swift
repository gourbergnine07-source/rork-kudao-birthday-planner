//
//  GiftShopping.swift
//  Kudao
//

import Foundation

/// Where the "buy online" button sends the user for one gift idea.
nonisolated enum GiftDestination: Equatable, Sendable {
    /// Amazon search on the storefront that matches the language.
    ///
    /// `tag` is the Associates tag actually attached to the URL. It is `nil`
    /// when no tag is configured for that storefront: the link still goes to
    /// Amazon, it simply earns nothing.
    case amazon(URL, marketplace: AmazonMarketplace, tag: String?)
    /// Plain Google Shopping search, offered as the alternative.
    case webSearch(URL)

    var url: URL {
        switch self {
        case .amazon(let url, _, _): url
        case .webSearch(let url): url
        }
    }

    /// True when the link earns a commission and therefore needs the disclosure.
    var isAffiliate: Bool {
        switch self {
        case .amazon(_, _, let tag): tag?.isEmpty == false
        case .webSearch: false
        }
    }

    /// Storefront the link points at, `nil` for the Google search.
    var marketplace: AmazonMarketplace? {
        switch self {
        case .amazon(_, let marketplace, _): marketplace
        case .webSearch: nil
        }
    }

    var tag: String? {
        switch self {
        case .amazon(_, _, let tag): tag
        case .webSearch: nil
        }
    }
}

/// Builds the external shopping search for the AI-generated gift idea.
///
/// The query always comes from `PartyPlan.giftIdea`: Kudao never lets the user
/// type a gift by hand outside the diary → suggestions flow.
nonisolated enum GiftShopping {
    /// Amazon search for a gift idea, carrying the Associates tag when there is one.
    ///
    /// The button always lands on Amazon. A missing tag only costs the commission,
    /// it never redirects the user somewhere else than they expect.
    ///
    /// - Parameter affiliateTags: Associates tags keyed by `AmazonMarketplace.rawValue`.
    static func destination(
        for giftIdea: String,
        language: AppLanguage,
        affiliateTags: [String: String]
    ) -> GiftDestination? {
        let marketplace = AmazonMarketplace.resolve(language: language)
        let raw = AmazonMarketplace.sanitize(affiliateTags[marketplace.rawValue] ?? "")
        let tag = raw.isEmpty ? nil : raw

        guard let url = amazonSearchURL(for: giftIdea, marketplace: marketplace, tag: tag) else {
            return nil
        }
        return .amazon(url, marketplace: marketplace, tag: tag)
    }

    /// Google Shopping destination for the same idea, used as the manual alternative.
    static func webDestination(for giftIdea: String, language: AppLanguage) -> GiftDestination? {
        guard let url = searchURL(for: giftIdea, language: language) else { return nil }
        return .webSearch(url)
    }

    /// Amazon search on one storefront, with the Associates tag when provided.
    static func amazonSearchURL(
        for giftIdea: String,
        marketplace: AmazonMarketplace,
        tag: String?
    ) -> URL? {
        let trimmed = giftIdea.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var components = URLComponents()
        components.scheme = "https"
        components.host = marketplace.host
        components.path = "/s"

        var items = [URLQueryItem(name: "k", value: trimmed)]
        if let tag, !tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            items.append(URLQueryItem(name: "tag", value: tag.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        components.queryItems = items

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
