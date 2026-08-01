//
//  ExternalLink.swift
//  Kudao
//

import UIKit

/// Opens links in the system browser.
///
/// Shopping links must leave the app: Amazon's Associates terms require the
/// storefront to be shown in the real browser, where the user is signed in and
/// their cookies live, never inside an embedded web view.
enum ExternalLink {
    /// Hands the URL to iOS, which opens it in Safari or the user's default browser.
    @discardableResult
    static func open(_ url: URL) -> Bool {
        guard UIApplication.shared.canOpenURL(url) else { return false }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
}
