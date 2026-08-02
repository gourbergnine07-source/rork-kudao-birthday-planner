//
//  PaywallView.swift
//  Kudao
//

import SwiftUI
import RevenueCat

/// Kudao Premium, asked for once and never nagged about.
///
/// The tone matters here: the app's free half is genuinely free, so the screen
/// opens by saying so rather than by hiding it in the small print.
struct PaywallView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(SubscriptionService.self) private var subscriptions
    @Environment(\.dismiss) private var dismiss

    @State private var selection: Package?
    @State private var showsRestoreEmpty: Bool = false

    private var strings: Strings { settings.strings }

    /// The package the buy button will actually charge for.
    private var activePackage: Package? {
        selection ?? subscriptions.packages.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 26) {
                        hero
                        benefits
                        extras

                        if subscriptions.packages.isEmpty {
                            unavailable
                        } else {
                            plans
                            callToAction
                        }

                        footer
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(Circle().fill(Palette.surfaceRaised))
                    }
                    .accessibilityLabel(strings.cancelAction)
                }
            }
            .task { await subscriptions.loadOfferings() }
            .alert(strings.paywallRestoreEmptyTitle, isPresented: $showsRestoreEmpty) {
                Button(strings.doneAction, role: .cancel) {}
            } message: {
                Text(strings.paywallRestoreEmptyMessage)
            }
            .alert(
                strings.paywallErrorTitle,
                isPresented: Binding(
                    get: { subscriptions.errorMessage != nil },
                    set: { if !$0 { subscriptions.errorMessage = nil } }
                )
            ) {
                Button(strings.doneAction, role: .cancel) { subscriptions.errorMessage = nil }
            } message: {
                Text(subscriptions.errorMessage ?? "")
            }
            .onChange(of: subscriptions.isPremium) { _, isPremium in
                if isPremium { dismiss() }
            }
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.berry)
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Palette.vowGradient)
                    .frame(width: 84, height: 84)
                    .shadow(color: Palette.berry.opacity(0.38), radius: 18, y: 9)

                Image(systemName: "sparkles")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(.top, 6)

            Text(strings.paywallTitle)
                .font(.system(size: 27, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(strings.paywallSubtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Benefits

    private var benefits: some View {
        VStack(spacing: 14) {
            benefitRow(
                symbol: "infinity",
                tint: Palette.berry,
                title: strings.paywallBenefitEventsTitle,
                caption: strings.paywallBenefitEventsCaption
            )
            benefitRow(
                symbol: "hand.raised.fill",
                tint: Palette.teal,
                title: strings.paywallBenefitAdsTitle,
                caption: strings.paywallBenefitAdsCaption
            )
            benefitRow(
                symbol: "photo.stack.fill",
                tint: Palette.amber,
                title: strings.paywallBenefitToolsTitle,
                caption: strings.paywallBenefitToolsCaption
            )
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }

    // MARK: - Concrete actions

    /// The three things people actually do inside a profile, spelled out.
    ///
    /// The block above sells the idea; this one names the buttons, so the screen
    /// never asks for money against a promise the user cannot picture.
    private var extras: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(strings.paywallExtrasTitle.uppercased())
                .font(.system(.caption2, design: .rounded, weight: .heavy))
                .tracking(1)
                .foregroundStyle(.secondary)

            extraRow(
                symbol: "person.2.badge.plus.fill",
                tint: Palette.violet,
                title: strings.inviteSomeoneAction,
                caption: strings.paywallExtraInviteCaption
            )
            extraRow(
                symbol: "cart.fill",
                tint: Palette.berry,
                title: strings.buyOnAmazonAction,
                caption: strings.paywallExtraShopCaption
            )
            extraRow(
                symbol: "map.fill",
                tint: Palette.teal,
                title: strings.findStoreAction,
                caption: strings.paywallExtraStoreCaption
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func extraRow(symbol: String, tint: Color, title: String, caption: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 26, height: 26)
                .background(Circle().fill(tint.opacity(0.13)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                Text(caption)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private func benefitRow(symbol: String, tint: Color, title: String, caption: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(Circle().fill(tint.opacity(0.14)))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                Text(caption)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Plans

    private var plans: some View {
        VStack(spacing: 12) {
            ForEach(subscriptions.packages, id: \.identifier) { package in
                planCard(package)
            }
        }
    }

    private func planCard(_ package: Package) -> some View {
        let isSelected = activePackage?.identifier == package.identifier

        return Button {
            selection = package
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Palette.berry : Palette.hairline, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Palette.berry)
                            .frame(width: 13, height: 13)
                            .transition(.scale)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title(for: package))
                            .font(.system(.headline, design: .rounded, weight: .bold))

                        if let savings = savingsPercent(for: package) {
                            Text(String(format: strings.paywallSavingsFormat, savings))
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Palette.teal))
                        }
                    }

                    if let renewal = renewalCaption(for: package) {
                        Text(renewal)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 0)

                Text(package.storeProduct.localizedPriceString)
                    .font(.system(.headline, design: .rounded, weight: .heavy))
                    .foregroundStyle(isSelected ? Palette.berry : .primary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        isSelected ? Palette.berry.opacity(0.75) : Palette.hairline,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.07 : 0.03), radius: 10, y: 5)
        }
        .buttonStyle(PressableCardStyle())
        .animation(.smooth(duration: 0.22), value: isSelected)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var callToAction: some View {
        VStack(spacing: 12) {
            Button {
                guard let package = activePackage else { return }
                Task { await subscriptions.purchase(package) }
            } label: {
                ZStack {
                    if subscriptions.isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(strings.paywallSubscribeAction)
                            .font(.system(.headline, design: .rounded, weight: .heavy))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Capsule().fill(Palette.vowGradient))
                .shadow(color: Palette.berry.opacity(0.34), radius: 16, y: 8)
            }
            .buttonStyle(PressableCardStyle())
            .disabled(subscriptions.isPurchasing || activePackage == nil)

            Button {
                Task {
                    let restored = await subscriptions.restore()
                    if !restored && subscriptions.errorMessage == nil {
                        showsRestoreEmpty = true
                    }
                }
            } label: {
                Text(strings.paywallRestoreAction)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Palette.clay)
            }
            .disabled(subscriptions.isPurchasing)
        }
    }

    private var unavailable: some View {
        VStack(spacing: 10) {
            if subscriptions.isLoadingOfferings {
                ProgressView()
                    .padding(.vertical, 12)
            } else {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Palette.clay)

                Text(strings.paywallUnavailableTitle)
                    .font(.system(.headline, design: .rounded, weight: .bold))

                Text(strings.paywallUnavailableMessage)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button(strings.paywallRetryAction) {
                    Task { await subscriptions.loadOfferings() }
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.surfaceRaised)
        )
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Label(strings.paywallFreeNote, systemImage: "gift.fill")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(Palette.teal)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(strings.paywallTermsNote)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            legalLinks
        }
    }

    /// Apple requires the terms and the privacy policy to be reachable from the
    /// paywall itself, not buried in a settings screen.
    private var legalLinks: some View {
        HStack(spacing: 8) {
            if let terms = LegalLinks.terms {
                Button(strings.paywallTermsLink) { ExternalLink.open(terms) }
            }

            if LegalLinks.terms != nil && LegalLinks.privacy != nil {
                Text("\u{00B7}")
                    .foregroundStyle(.quaternary)
            }

            if let privacy = LegalLinks.privacy {
                Button(strings.paywallPrivacyLink) { ExternalLink.open(privacy) }
            }
        }
        .font(.system(.caption2, design: .rounded, weight: .semibold))
        .foregroundStyle(.secondary)
        .padding(.top, 2)
    }

    // MARK: - Package wording

    private func title(for package: Package) -> String {
        switch package.packageType {
        case .annual: strings.paywallYearlyTitle
        case .monthly: strings.paywallMonthlyTitle
        default: package.storeProduct.localizedTitle
        }
    }

    /// "12,50 € / mese" style line under a yearly plan, so the comparison with
    /// the monthly card is honest instead of implied by a badge alone.
    private func renewalCaption(for package: Package) -> String? {
        guard package.packageType == .annual else { return nil }
        guard let perMonth = package.storeProduct.pricePerMonth else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = package.storeProduct.currencyCode
        formatter.locale = settings.locale
        guard let amount = formatter.string(from: perMonth) else { return nil }

        return "\(amount) / \(strings.paywallMonthlyTitle.lowercased())"
    }

    /// How much the yearly plan saves against twelve monthly renewals.
    private func savingsPercent(for package: Package) -> Int? {
        guard package.packageType == .annual else { return nil }
        guard let monthly = subscriptions.packages.first(where: { $0.packageType == .monthly }) else { return nil }

        let yearOfMonthly = (monthly.storeProduct.price as NSDecimalNumber).doubleValue * 12
        let yearly = (package.storeProduct.price as NSDecimalNumber).doubleValue
        guard yearOfMonthly > 0, yearly < yearOfMonthly else { return nil }

        let saved = Int(((yearOfMonthly - yearly) / yearOfMonthly * 100).rounded())
        return saved >= 5 ? saved : nil
    }
}
