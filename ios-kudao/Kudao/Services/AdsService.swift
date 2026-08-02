//
//  AdsService.swift
//  Kudao
//

import Foundation
import GoogleMobileAds
import Observation
import SwiftUI
import UIKit
import UserMessagingPlatform

/// AdMob, kept on a short leash.
///
/// Kudao shows one discreet banner at the bottom of Home and, at most, one
/// interstitial per session when the app comes back from the background. Every
/// other surface stays clean, and subscribers plus remembrance profiles never
/// see an ad at all — that decision lives in `SubscriptionService.showsAds(in:)`.
///
/// Nothing here ever blocks the interface: if consent, the network or the
/// identifiers are missing, the ad space simply does not exist.
@Observable
@MainActor
final class AdsService {
    /// Google's public test identifiers. They always fill, they earn nothing,
    /// and they are what a build without configured identifiers falls back to —
    /// requesting live ads from an unconfigured build is how AdMob accounts get
    /// suspended.
    enum TestIdentifiers {
        static let appID: String = "ca-app-pub-3940256099942544~1458002511"
        static let banner: String = "ca-app-pub-3940256099942544/2435281174"
        static let interstitial: String = "ca-app-pub-3940256099942544/4411468910"
    }

    /// Builds every ad request Kudao ever sends.
    ///
    /// `npa=1` asks Google for non-personalised ads, always. That single flag is
    /// what keeps three declarations honest at once: the privacy manifest says
    /// `NSPrivacyTracking = false`, the App Store label claims no tracking, and
    /// the app never shows an App Tracking Transparency prompt. Without it, a
    /// European user who accepts the consent form would receive personalised
    /// ads — tracking, in Apple's sense, with no permission ever asked for.
    ///
    /// Consent is still gathered through the User Messaging Platform: it governs
    /// whether an ad may be requested at all, which is a separate question from
    /// whether that ad may be targeted.
    static func makeRequest() -> Request {
        let request = Request()
        let extras = Extras()
        extras.additionalParameters = ["npa": "1"]
        request.register(extras)
        return request
    }

    /// Names of the project settings holding the live identifiers.
    private enum Keys {
        static let appID: String = "EXPO_PUBLIC_ADMOB_IOS_APP_ID"
        static let banner: String = "EXPO_PUBLIC_ADMOB_IOS_BANNER_UNIT_ID"
        static let interstitial: String = "EXPO_PUBLIC_ADMOB_IOS_INTERSTITIAL_UNIT_ID"
    }

    /// The identifier the SDK actually uses: it reads `GADApplicationIdentifier`
    /// from Info.plist and ignores anything set in code.
    static var plistAppID: String {
        let value = Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String
        return (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Live inventory is requested only when all three identifiers are present
    /// **and** the account compiled into Info.plist is the same one that owns the
    /// ad units. A mismatch would mean requests billed to nobody and, worse, the
    /// kind of invalid traffic that gets AdMob accounts suspended, so the app
    /// quietly falls back to demo inventory instead.
    static var isLiveInventoryReady: Bool {
        guard let app = setting(Keys.appID),
              setting(Keys.banner) != nil,
              setting(Keys.interstitial) != nil else { return false }
        return app == plistAppID
    }

    static var appID: String { isLiveInventoryReady ? (setting(Keys.appID) ?? "") : TestIdentifiers.appID }
    static var bannerUnitID: String { isLiveInventoryReady ? (setting(Keys.banner) ?? "") : TestIdentifiers.banner }
    static var interstitialUnitID: String {
        isLiveInventoryReady ? (setting(Keys.interstitial) ?? "") : TestIdentifiers.interstitial
    }

    /// True while the build is still serving Google's demo inventory.
    static var isUsingTestInventory: Bool { !isLiveInventoryReady }

    /// Reads a project setting, returning `nil` when it is absent or blank.
    ///
    /// `Config.allValues` is a dictionary rather than a named constant because
    /// the file behind it is regenerated at build time: a lookup degrades to the
    /// fallback instead of failing to compile.
    private static func setting(_ name: String) -> String? {
        let value = (Config.allValues[name] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    // MARK: - State

    /// True once consent has been settled and the SDK has been started.
    private(set) var canRequestAds: Bool = false
    /// Whether European privacy rules require an always-available way to
    /// reopen the consent choices. Drives the row in App Settings.
    private(set) var isPrivacyOptionsRequired: Bool = false

    private var hasStarted: Bool = false
    private var interstitial: InterstitialAd?
    private var hasShownInterstitial: Bool = false
    private var pauseDepth: Int = 0
    private var backgroundedAt: Date?
    private let launchedAt: Date = Date()

    /// Interstitials wait at least this long after a cold start, so the first
    /// minute with Kudao is never an advertisement.
    private static let quietStart: TimeInterval = 60
    /// A real "I put the phone down and came back" pause, not an app switch.
    private static let minimumAwayTime: TimeInterval = 25

    /// True while a screen has asked for silence: writing in the diary,
    /// creating a profile, preparing a message.
    var isPaused: Bool { pauseDepth > 0 }

    // MARK: - Lifecycle

    /// Gathers consent, starts the SDK and pre-loads the session's interstitial.
    /// Safe to call repeatedly; only the first call does the work.
    func start() async {
        guard !hasStarted else { return }
        hasStarted = true

        // The SDK raises an uncaught exception — a crash on launch, before the
        // first screen — when Info.plist carries no application identifier. A
        // build that somehow ships without it runs without advertising instead
        // of not running at all.
        guard !Self.plistAppID.isEmpty else {
            print("[Kudao] AdMob disabled: Info.plist has no GADApplicationIdentifier.")
            return
        }

        await gatherConsent()
        MobileAds.shared.start(completionHandler: nil)
        canRequestAds = ConsentInformation.shared.canRequestAds

        if Self.isUsingTestInventory {
            let configured = Self.setting(Keys.appID)
            if let configured, configured != Self.plistAppID {
                print("[Kudao] AdMob app id mismatch: Info.plist has \(Self.plistAppID), settings have \(configured). Serving test ads.")
            } else {
                print("[Kudao] AdMob is serving test ads — set \(Keys.banner) and \(Keys.interstitial) to earn.")
            }
        }

        await loadInterstitial()
    }

    /// Called when the app leaves the screen, to measure how long it was away.
    func noteEnteredBackground() {
        backgroundedAt = Date()
    }

    /// Called when the app returns. Shows the session's single interstitial if
    /// this is genuinely a return, and if nothing on screen deserves quiet.
    func noteBecameActive(isPremium: Bool) {
        guard !isPremium, canRequestAds, !hasShownInterstitial, !isPaused else { return }
        guard let away = backgroundedAt, Date().timeIntervalSince(away) >= Self.minimumAwayTime else { return }
        guard Date().timeIntervalSince(launchedAt) >= Self.quietStart else { return }
        guard let ad = interstitial else { return }

        hasShownInterstitial = true
        interstitial = nil
        ad.present(from: nil)
    }

    /// Silences interstitials while a delicate screen is open.
    func pause() {
        pauseDepth += 1
    }

    func resume() {
        pauseDepth = max(0, pauseDepth - 1)
    }

    /// Reopens the European consent choices from App Settings.
    func presentPrivacyOptions() async {
        do {
            try await ConsentForm.presentPrivacyOptionsForm(from: nil)
            canRequestAds = ConsentInformation.shared.canRequestAds
        } catch {
            print("[Kudao] Could not open the ad privacy options: \(error.localizedDescription)")
        }
    }

    // MARK: - Private

    /// Asks the User Messaging Platform whether this person, in this country,
    /// has to be shown a consent form, and shows it if so. Kudao's audience is
    /// largely European, so this is not optional.
    private func gatherConsent() async {
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { error in
                if let error {
                    print("[Kudao] Consent information unavailable: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }

        do {
            try await ConsentForm.loadAndPresentIfRequired(from: nil)
        } catch {
            print("[Kudao] Consent form not presented: \(error.localizedDescription)")
        }

        isPrivacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }

    private func loadInterstitial() async {
        guard canRequestAds, interstitial == nil, !hasShownInterstitial else { return }
        do {
            interstitial = try await InterstitialAd.load(
                with: Self.interstitialUnitID,
                request: Self.makeRequest()
            )
        } catch {
            print("[Kudao] Interstitial unavailable: \(error.localizedDescription)")
        }
    }
}

/// Marks a screen where an interstitial would be an intrusion: the profile
/// form, the diary composer, the message screen.
private struct AdPauseModifier: ViewModifier {
    @Environment(AdsService.self) private var ads

    func body(content: Content) -> some View {
        content
            .onAppear { ads.pause() }
            .onDisappear { ads.resume() }
    }
}

extension View {
    /// Keeps full-screen ads away while this screen is on display.
    func pausesInterstitials() -> some View {
        modifier(AdPauseModifier())
    }
}
