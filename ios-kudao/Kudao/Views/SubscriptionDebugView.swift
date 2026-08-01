//
//  SubscriptionDebugView.swift
//  Kudao
//

#if DEBUG

import SwiftUI
import UIKit
import RevenueCat

/// Developer-only console for the Kudao Premium purchase flow.
///
/// It exists because a failed purchase is ambiguous from the paywall alone:
/// a missing offering, a product Apple has not finished reviewing and a
/// cancelled sheet all look like "nothing happened". This screen separates
/// those cases — it shows which store the build is talking to, which packages
/// came back, what the entitlement says right now, and it can buy a package
/// directly, bypassing the paywall UI entirely.
///
/// Intentionally not localized: it never ships to a user. The whole file is
/// compiled out of release builds.
struct SubscriptionDebugView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(SubscriptionService.self) private var subscriptions
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var log: [LogEntry] = []
    @State private var isShowingPaywall: Bool = false
    @State private var didCopy: Bool = false

    var body: some View {
        NavigationStack {
            List {
                environmentSection
                checklistSection
                entitlementSection
                packagesSection
                accessSection
                actionsSection
                overrideSection
                logSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Purchase debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
            .sheet(isPresented: $isShowingPaywall) {
                PaywallView()
            }
            .task {
                await subscriptions.loadOfferings()
                note("Screen opened — \(SubscriptionService.environment.label)")
            }
        }
        .tint(Palette.coral)
    }

    // MARK: - Environment

    private var environmentSection: some View {
        Section {
            row("Store", SubscriptionService.environment.label)
            row("SDK configured", subscriptions.isAvailable ? "yes" : "no")
            row("API key", SubscriptionService.apiKeyFingerprint)
            row("Entitlement id", SubscriptionService.entitlementID)
            row("App user id", subscriptions.appUserID ?? "—", isCompact: true)
            row("Status resolved", subscriptions.hasResolvedStatus ? "yes" : "waiting")
        } header: {
            Text("Environment")
        } footer: {
            Text(environmentHint)
        }
    }

    /// The single most confusing part of testing purchases is that the answer
    /// depends on how the app was launched, so it is spelled out here.
    private var environmentHint: String {
        switch SubscriptionService.environment {
        case .testStore:
            return """
            This build talks to the RevenueCat Test Store, so purchases complete \
            here in the simulator with no Apple ID and no charge. It exercises the \
            paywall, the entitlement and every locked screen — but not Apple's \
            payment sheet. For that, install the TestFlight build.
            """
        case .appStore:
            return """
            This build talks to the real App Store. On TestFlight, purchases run \
            in Apple's sandbox: the payment sheet appears, asks for a sandbox \
            Apple ID and charges nothing. Renewals are accelerated — a month \
            renews every 5 minutes, a year every hour.
            """
        case .unconfigured:
            return "No RevenueCat key is present in this build, so every purchase path is a no-op."
        }
    }

    // MARK: - Checklist

    /// Fastest read on the screen: everything green means the store side is
    /// wired correctly and any failure from here is in the app or in Apple's
    /// review state, not in the configuration.
    private var checklistSection: some View {
        Section("Preflight") {
            check("RevenueCat configured", subscriptions.isAvailable)
            check("Offering loaded", subscriptions.offerings?.current != nil)
            check(
                "Offering is “default”",
                subscriptions.offerings?.current?.identifier == "default",
                detail: subscriptions.offerings?.current?.identifier
            )
            check("Monthly package", hasPackage(.monthly))
            check("Annual package", hasPackage(.annual))
            check("Prices resolved", arePricesResolved)
            check(
                "Entitlement known to store",
                subscriptions.lastCustomerInfo?.entitlements.all[SubscriptionService.entitlementID] != nil,
                detail: subscriptions.lastCustomerInfo == nil ? "no customer info yet" : "never purchased on this account"
            )
        }
    }

    private func hasPackage(_ type: PackageType) -> Bool {
        subscriptions.packages.contains { $0.packageType == type }
    }

    /// An empty price string means StoreKit did not return the product, which
    /// is what a not-yet-approved or mis-typed product id looks like.
    private var arePricesResolved: Bool {
        let packages = subscriptions.packages
        guard !packages.isEmpty else { return false }
        return packages.allSatisfy { !$0.storeProduct.localizedPriceString.isEmpty }
    }

    // MARK: - Entitlement

    @ViewBuilder
    private var entitlementSection: some View {
        Section("Entitlement") {
            row("Premium active", subscriptions.isPremium ? "YES" : "no", tint: subscriptions.isPremium ? Palette.teal : nil)

            if let entitlement = subscriptions.lastCustomerInfo?.entitlements.all[SubscriptionService.entitlementID] {
                row("Product", entitlement.productIdentifier, isCompact: true)
                row("Source", String(describing: entitlement.store))
                row("Sandbox", entitlement.isSandbox ? "yes" : "no")
                row("Period", String(describing: entitlement.periodType))
                row("Will renew", entitlement.willRenew ? "yes" : "no")
                row("Bought", format(entitlement.latestPurchaseDate))
                row("Expires", format(entitlement.expirationDate))

                if let issue = entitlement.billingIssueDetectedAt {
                    row("Billing issue", format(issue), tint: Palette.berry)
                }
                if let cancelled = entitlement.unsubscribeDetectedAt {
                    row("Cancelled at", format(cancelled), tint: Palette.clay)
                }
            } else {
                Text("No premium entitlement has ever been recorded for this install.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let info = subscriptions.lastCustomerInfo {
                row("Checked", format(info.requestDate))
                if !info.activeSubscriptions.isEmpty {
                    row("Active subs", info.activeSubscriptions.sorted().joined(separator: ", "), isCompact: true)
                }
            }
        }
    }

    // MARK: - Packages

    @ViewBuilder
    private var packagesSection: some View {
        Section {
            if subscriptions.packages.isEmpty {
                HStack(spacing: 10) {
                    if subscriptions.isLoadingOfferings {
                        ProgressView()
                        Text("Loading offerings…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No packages returned. Check the offering in the RevenueCat dashboard, then reload below.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                ForEach(subscriptions.packages, id: \.identifier) { package in
                    packageRow(package)
                }
            }
        } header: {
            Text("Packages")
        } footer: {
            Text("Buying from here skips the paywall UI, so a failure points at the store rather than at the screen.")
        }
    }

    private func packageRow(_ package: Package) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(package.identifier)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                Spacer(minLength: 8)
                Text(package.storeProduct.localizedPriceString.isEmpty ? "no price" : package.storeProduct.localizedPriceString)
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .foregroundStyle(package.storeProduct.localizedPriceString.isEmpty ? Palette.berry : Palette.teal)
            }

            Text(package.storeProduct.productIdentifier)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)

            Button {
                buy(package)
            } label: {
                Text(subscriptions.isPurchasing ? "Working…" : "Buy this package")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Palette.vowGradient))
            }
            .buttonStyle(.plain)
            .disabled(subscriptions.isPurchasing)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Access rules

    /// Mirrors the real gate so a tester can confirm the rules flipped after a
    /// purchase, without hunting through the app for a locked profile.
    private var accessSection: some View {
        Section {
            ForEach(OccasionKind.allCases) { occasion in
                HStack {
                    Image(systemName: occasion.symbolName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(occasion.accent)
                        .frame(width: 22)

                    Text(occasion.title(settings.strings))
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))

                    Spacer(minLength: 8)

                    if subscriptions.isLocked(occasion) {
                        Label("locked", systemImage: "lock.fill")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(Palette.berry)
                    } else {
                        Label(
                            SubscriptionService.requiresPremium(occasion) ? "unlocked" : "free",
                            systemImage: SubscriptionService.requiresPremium(occasion) ? "lock.open.fill" : "gift.fill"
                        )
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(Palette.teal)
                    }

                    Text(subscriptions.showsAds(in: occasion) ? "ads" : "no ads")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Palette.surfaceRaised))
                }
            }
        } header: {
            Text("Access rules")
        } footer: {
            Text("Remembrance never shows ads, subscription or not.")
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        Section("Actions") {
            Button {
                isShowingPaywall = true
                note("Paywall opened")
            } label: {
                Label("Open the paywall", systemImage: "sparkles")
            }

            Button {
                Task {
                    note("Restoring…")
                    let restored = await subscriptions.restore()
                    if let error = subscriptions.errorMessage {
                        note("Restore failed — \(error)", isFailure: true)
                    } else {
                        note(restored ? "Restore returned premium" : "Restore found nothing on this account")
                    }
                }
            } label: {
                Label("Restore purchases", systemImage: "arrow.clockwise.circle")
            }
            .disabled(subscriptions.isPurchasing)

            Button {
                Task {
                    await subscriptions.refresh()
                    note("Status refreshed — premium is \(subscriptions.isPremium ? "active" : "inactive")")
                }
            } label: {
                Label("Refresh entitlement", systemImage: "arrow.triangle.2.circlepath")
            }

            Button {
                Task {
                    await subscriptions.reloadOfferings()
                    note("Offerings reloaded — \(subscriptions.packages.count) package(s)")
                }
            } label: {
                Label("Reload offerings", systemImage: "tray.and.arrow.down")
            }

            if let url = subscriptions.lastCustomerInfo?.managementURL {
                Button {
                    openURL(url)
                    note("Opened subscription management")
                } label: {
                    Label("Manage subscription", systemImage: "gear")
                }
            }

            Button {
                UIPasteboard.general.string = diagnosticsDump
                didCopy = true
                note("Diagnostics copied to clipboard")
            } label: {
                Label(didCopy ? "Copied" : "Copy diagnostics", systemImage: didCopy ? "checkmark" : "doc.on.doc")
            }
        }
    }

    // MARK: - Override

    private var overrideSection: some View {
        Section {
            Picker(
                "Force state",
                selection: Binding(
                    get: { subscriptions.debugPremiumOverride },
                    set: { value in
                        subscriptions.applyDebugPremiumOverride(value)
                        switch value {
                        case .some(true): note("Forced premium ON (local only)")
                        case .some(false): note("Forced premium OFF (local only)")
                        case .none: note("Override cleared — following the real entitlement")
                        }
                    }
                )
            ) {
                Text("Real store").tag(Bool?.none)
                Text("Force premium").tag(Bool?.some(true))
                Text("Force free").tag(Bool?.some(false))
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Local override")
        } footer: {
            Text("Flips the app between locked and unlocked without a purchase. Nothing is sent to RevenueCat or Apple, and it resets when the app restarts.")
        }
    }

    // MARK: - Log

    @ViewBuilder
    private var logSection: some View {
        Section("Log") {
            if log.isEmpty {
                Text("No events yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(log) { entry in
                    HStack(alignment: .top, spacing: 8) {
                        Text(entry.date, format: .dateTime.hour().minute().second())
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.tertiary)
                        Text(entry.message)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(entry.isFailure ? Palette.berry : .primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    // MARK: - Pieces

    private func row(_ title: String, _ value: String, tint: Color? = nil, isCompact: Bool = false) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(.subheadline, design: .rounded))
            Spacer(minLength: 12)
            Text(value)
                .font(.system(isCompact ? .caption2 : .subheadline, design: .monospaced))
                .foregroundStyle(tint ?? .secondary)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }

    private func check(_ title: String, _ isPassing: Bool, detail: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: isPassing ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isPassing ? Palette.teal : Palette.berry)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                if !isPassing, let detail {
                    Text(detail)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
    }

    private func format(_ date: Date?) -> String {
        guard let date else { return "—" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    // MARK: - Behaviour

    private func buy(_ package: Package) {
        Task {
            subscriptions.errorMessage = nil
            note("Buying \(package.identifier)…")
            await subscriptions.purchase(package)

            if let error = subscriptions.errorMessage {
                note("Purchase failed — \(error)", isFailure: true)
            } else if subscriptions.isPremium {
                note("Purchase complete — premium is ACTIVE")
            } else {
                note("Purchase ended without an entitlement (cancelled or pending approval)")
            }
        }
    }

    private func note(_ message: String, isFailure: Bool = false) {
        log.insert(LogEntry(message: message, isFailure: isFailure), at: 0)
        if log.count > 40 { log.removeLast(log.count - 40) }
    }

    /// One block of text worth pasting into a bug report.
    private var diagnosticsDump: String {
        var lines: [String] = [
            "Kudao purchase diagnostics",
            "store: \(SubscriptionService.environment.label)",
            "key: \(SubscriptionService.apiKeyFingerprint)",
            "configured: \(subscriptions.isAvailable)",
            "appUserID: \(subscriptions.appUserID ?? "—")",
            "premium: \(subscriptions.isPremium)",
            "offering: \(subscriptions.offerings?.current?.identifier ?? "—")",
            "packages: \(subscriptions.packages.map(\.identifier).joined(separator: ", "))"
        ]

        for package in subscriptions.packages {
            lines.append("  \(package.identifier) → \(package.storeProduct.productIdentifier) @ \(package.storeProduct.localizedPriceString)")
        }

        if let entitlement = subscriptions.lastCustomerInfo?.entitlements.all[SubscriptionService.entitlementID] {
            lines.append("entitlement: active=\(entitlement.isActive) store=\(entitlement.store) sandbox=\(entitlement.isSandbox)")
            lines.append("  product=\(entitlement.productIdentifier) expires=\(format(entitlement.expirationDate))")
        } else {
            lines.append("entitlement: none recorded")
        }

        if let error = subscriptions.errorMessage {
            lines.append("lastError: \(error)")
        }

        return lines.joined(separator: "\n")
    }

    private struct LogEntry: Identifiable {
        let id: UUID = UUID()
        let date: Date = Date()
        let message: String
        let isFailure: Bool
    }
}

#Preview {
    SubscriptionDebugView()
        .environment(AppSettings())
        .environment(SubscriptionService())
}

#endif
