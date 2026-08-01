//
//  SubscriptionService.swift
//  Kudao
//

import Foundation
import Observation
import RevenueCat

/// Kudao Premium, and the single answer to "can this person open this profile?".
///
/// The rule the whole app leans on is deliberately narrow: birthdays and
/// remembrances are free forever, weddings and generic events need an active
/// subscription. Nothing is ever deleted when a subscription lapses — the
/// profiles simply stop opening until Premium comes back.
@Observable
@MainActor
final class SubscriptionService {
    /// Entitlement lookup key configured in RevenueCat.
    static let entitlementID: String = "premium"

    private(set) var isPremium: Bool = false
    private(set) var offerings: Offerings?
    private(set) var isLoadingOfferings: Bool = false
    private(set) var isPurchasing: Bool = false
    /// True once the first entitlement check has come back, so the UI can avoid
    /// flashing a paywall at a subscriber during launch.
    private(set) var hasResolvedStatus: Bool = false
    var errorMessage: String?

    /// False when no API key is available, e.g. a local build with no secrets.
    /// Every purchase path becomes a no-op instead of trapping in the SDK.
    let isAvailable: Bool

    init() {
        isAvailable = Purchases.isConfigured
        guard isAvailable else {
            hasResolvedStatus = true
            return
        }
        Task { await observeCustomerInfo() }
        Task { await refresh() }
        Task { await loadOfferings() }
    }

    // MARK: - Configuration

    /// Called once from the app's `init()`. Safe to call when no key exists:
    /// the SDK stays unconfigured and the app runs entirely on the free tier.
    static func configure() {
        guard !Purchases.isConfigured else { return }
        let key = apiKey
        guard !key.isEmpty else {
            print("[Kudao] RevenueCat API key missing — purchases disabled for this build.")
            return
        }
        #if DEBUG
        Purchases.logLevel = .warn
        #endif
        Purchases.configure(withAPIKey: key)
    }

    /// Debug builds prefer the Test Store so purchases work without App Store
    /// Connect; release builds prefer the App Store key. Either one falls back
    /// to the other so a half-configured project still runs.
    ///
    /// Values are read through `allValues` rather than a named constant because
    /// `EnvConfig.swift` is regenerated at build time from the project settings:
    /// a dictionary lookup degrades to "no key" instead of failing to compile.
    private static var apiKey: String {
        #if DEBUG
        let preference = ["EXPO_PUBLIC_REVENUECAT_TEST_API_KEY", "EXPO_PUBLIC_REVENUECAT_IOS_API_KEY"]
        #else
        let preference = ["EXPO_PUBLIC_REVENUECAT_IOS_API_KEY", "EXPO_PUBLIC_REVENUECAT_TEST_API_KEY"]
        #endif

        for name in preference {
            let value = (Config.allValues[name] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !value.isEmpty { return value }
        }
        return ""
    }

    // MARK: - Access rules

    /// Weddings and generic events are the paid family.
    nonisolated static func requiresPremium(_ occasion: OccasionKind) -> Bool {
        switch occasion {
        case .birthday, .remembrance: false
        case .wedding, .other: true
        }
    }

    /// Whether a profile of this kind can be created or opened right now.
    func canAccess(_ occasion: OccasionKind) -> Bool {
        isPremium || !Self.requiresPremium(occasion)
    }

    /// A padlock is only worth drawing on an occasion this user cannot use yet.
    func isLocked(_ occasion: OccasionKind) -> Bool {
        !canAccess(occasion)
    }

    /// Ads never appear for subscribers, and never inside a remembrance —
    /// grief is not an advertising surface. `nil` means "outside any profile".
    func showsAds(in occasion: OccasionKind? = nil) -> Bool {
        guard !isPremium else { return false }
        return occasion != .remembrance
    }

    // MARK: - Store

    /// Monthly first, yearly second, whatever order the dashboard returns.
    var packages: [Package] {
        guard let current = offerings?.current else { return [] }
        let ordered = [current.monthly, current.annual].compactMap { $0 }
        guard ordered.isEmpty else { return ordered }
        return current.availablePackages
    }

    func loadOfferings() async {
        guard isAvailable, offerings == nil, !isLoadingOfferings else { return }
        isLoadingOfferings = true
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            errorMessage = error.localizedDescription
            print("[Kudao] Could not load offerings: \(error.localizedDescription)")
        }
        isLoadingOfferings = false
    }

    /// Re-reads the entitlement. Called on launch and every time the app
    /// returns to the foreground, so an expiry that happened elsewhere lands.
    func refresh() async {
        guard isAvailable else { return }
        do {
            let info = try await Purchases.shared.customerInfo()
            apply(info)
        } catch {
            print("[Kudao] Could not refresh subscription status: \(error.localizedDescription)")
        }
        hasResolvedStatus = true
    }

    func purchase(_ package: Package) async {
        guard isAvailable, !isPurchasing else { return }
        isPurchasing = true
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                apply(result.customerInfo)
            }
        } catch ErrorCode.purchaseCancelledError {
            // The user backed out of the sheet: not something to apologise for.
        } catch ErrorCode.paymentPendingError {
            // Waiting on parental approval or a bank confirmation.
        } catch {
            errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }

    /// Returns whether anything was actually restored, so the caller can tell
    /// "welcome back" apart from "nothing to restore on this Apple ID".
    @discardableResult
    func restore() async -> Bool {
        guard isAvailable, !isPurchasing else { return false }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let info = try await Purchases.shared.restorePurchases()
            apply(info)
            return isPremium
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Private

    private func observeCustomerInfo() async {
        for await info in Purchases.shared.customerInfoStream {
            apply(info)
        }
    }

    private func apply(_ info: CustomerInfo) {
        isPremium = info.entitlements[Self.entitlementID]?.isActive == true
        hasResolvedStatus = true
    }
}
