//
//  AmazonMarketplace.swift
//  Kudao
//

import Foundation

/// The Amazon storefronts Kudao can send a gift search to.
///
/// Each marketplace needs its own Associates tag: a tag issued for amazon.it
/// earns nothing on amazon.fr, so the raw value doubles as the settings key and
/// as the language code that selects the storefront.
nonisolated enum AmazonMarketplace: String, CaseIterable, Identifiable, Sendable {
    case italy = "it"
    case france = "fr"
    case germany = "de"
    case spain = "es"
    /// Fallback storefront for every language Kudao has no local store for.
    case international = "com"

    var id: String { rawValue }

    var host: String {
        switch self {
        case .italy: "www.amazon.it"
        case .france: "www.amazon.fr"
        case .germany: "www.amazon.de"
        case .spain: "www.amazon.es"
        case .international: "www.amazon.com"
        }
    }

    /// "Amazon.it" — how the storefront is labelled in the settings list.
    var displayName: String {
        switch self {
        case .italy: "Amazon.it"
        case .france: "Amazon.fr"
        case .germany: "Amazon.de"
        case .spain: "Amazon.es"
        case .international: "Amazon.com"
        }
    }

    var flag: String {
        switch self {
        case .italy: "🇮🇹"
        case .france: "🇫🇷"
        case .germany: "🇩🇪"
        case .spain: "🇪🇸"
        case .international: "🌍"
        }
    }

    /// Shape of a real Associates tag, shown as the field placeholder.
    var tagPlaceholder: String {
        switch self {
        case .italy: "kudao-21"
        case .france: "kudao-21"
        case .germany: "kudao-21"
        case .spain: "kudao-21"
        case .international: "kudao-20"
        }
    }

    /// Where the tag for this storefront is stored.
    var defaultsKey: String { "kudao.affiliate.amazon.\(rawValue)" }

    /// Environment variable that carries this storefront's tag into the build.
    var configKey: String { "EXPO_PUBLIC_AMAZON_TAG_\(rawValue.uppercased())" }

    /// Tag compiled into the build, used until the user types one of their own.
    ///
    /// Kudao ships as a single Associates account, so the tags belong to the
    /// build rather than to each install: they are injected as public
    /// environment variables (`EXPO_PUBLIC_AMAZON_TAG_IT`, `..._FR`, `..._DE`,
    /// `..._ES`, `..._COM`). The lookup goes through `Config.allValues` on
    /// purpose, so a storefront without a configured variable simply earns
    /// nothing instead of breaking the build.
    var shippedTag: String {
        (Config.allValues[configKey] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Storefront for a gift search, from the profile language and, failing that, the device.
    ///
    /// Italian, French and Spanish map straight onto their local store. English
    /// has no store of its own, so the device languages decide: a German phone
    /// running Kudao in English still shops on amazon.de.
    static func resolve(
        language: AppLanguage,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> AmazonMarketplace {
        switch language {
        case .italian: return .italy
        case .french: return .france
        case .spanish: return .spain
        case .english: return device(from: preferredLanguages) ?? .international
        }
    }

    /// First device language that has a local Amazon storefront.
    private static func device(from preferredLanguages: [String]) -> AmazonMarketplace? {
        for identifier in preferredLanguages {
            guard let code = Locale(identifier: identifier).language.languageCode?.identifier else { continue }
            if let match = AmazonMarketplace(rawValue: code), match != .international {
                return match
            }
        }
        return nil
    }
}
