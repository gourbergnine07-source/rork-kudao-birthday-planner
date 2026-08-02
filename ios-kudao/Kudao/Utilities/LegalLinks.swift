//
//  LegalLinks.swift
//  Kudao
//

import Foundation

/// The public pages Apple requires an app with subscriptions to link to.
///
/// They live on the Kudao website rather than inside the app so the same text is
/// reachable from the App Store listing, from a browser, and without installing
/// anything — which is exactly what App Review checks for.
enum LegalLinks {
    private static let base = "https://ek3qfxdplwz49ny1h3a7x-web.rork.live"

    static let terms = URL(string: "\(base)/terms")
    static let privacy = URL(string: "\(base)/privacy")
    static let support = URL(string: "\(base)/support")
    static let privacyChoices = URL(string: "\(base)/privacy-choices")
}
