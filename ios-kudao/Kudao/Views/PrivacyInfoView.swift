//
//  PrivacyInfoView.swift
//  Kudao
//

import SwiftUI

/// Plain-language account of where everything written in Kudao ends up.
///
/// A birthday app collects the most personal things a phone holds — dates,
/// photographs of people, notes about a friend, a grief that has a name — so the
/// answer to "where does this go?" cannot live only in a web page nobody opens.
/// This screen says it in the app, in the user's language, in the order that
/// worries people: what stays, what leaves, and how to take it all back.
struct PrivacyInfoView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(AdsService.self) private var ads
    @Environment(SubscriptionService.self) private var subscriptions
    @Environment(\.dismiss) private var dismiss

    private var strings: Strings { settings.strings }

    /// One line of the story, in the order it matters.
    private struct Topic: Identifiable {
        let id: String
        let symbol: String
        let tint: Color
        let title: String
        let body: String
    }

    private var topics: [Topic] {
        [
            Topic(
                id: "device",
                symbol: "iphone",
                tint: Palette.teal,
                title: strings.privacyInfoOnDeviceTitle,
                body: strings.privacyInfoOnDeviceBody
            ),
            Topic(
                id: "shared",
                symbol: "person.2.fill",
                tint: Palette.violet,
                title: strings.privacyInfoSharedTitle,
                body: strings.privacyInfoSharedBody
            ),
            Topic(
                id: "contacts",
                symbol: "person.crop.circle.badge.checkmark",
                tint: Palette.clay,
                title: strings.privacyInfoContactsTitle,
                body: strings.privacyInfoContactsBody
            ),
            Topic(
                id: "purchases",
                symbol: "creditcard.fill",
                tint: Palette.berry,
                title: strings.privacyInfoPurchasesTitle,
                body: strings.privacyInfoPurchasesBody
            ),
            Topic(
                id: "ads",
                symbol: "megaphone.fill",
                tint: Palette.amber,
                title: strings.privacyInfoAdsTitle,
                body: strings.privacyInfoAdsBody
            ),
            Topic(
                id: "amazon",
                symbol: "cart.fill",
                tint: Palette.coral,
                title: strings.privacyInfoAmazonTitle,
                body: strings.privacyInfoAmazonBody
            ),
            Topic(
                id: "control",
                symbol: "hand.raised.fill",
                tint: Palette.sage,
                title: strings.privacyInfoControlTitle,
                body: strings.privacyInfoControlBody
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 16) {
                        header

                        ForEach(topics) { topic in
                            topicCard(topic)
                        }

                        if ads.isPrivacyOptionsRequired && !subscriptions.isPremium {
                            consentButton
                        }

                        Text(strings.privacyInfoFooter)
                            .font(.system(.footnote, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(strings.privacyInfoTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(strings.doneAction) { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.coral)
    }

    // MARK: - Pieces

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(Circle().fill(Palette.warmGradient))
                .shadow(color: Palette.coral.opacity(0.28), radius: 14, y: 7)

            Text(strings.privacyInfoIntro)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 2)
    }

    private func topicCard(_ topic: Topic) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: topic.symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(topic.tint)
                .frame(width: 34, height: 34)
                .background(Circle().fill(topic.tint.opacity(0.13)))

            VStack(alignment: .leading, spacing: 5) {
                Text(topic.title)
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .foregroundStyle(.primary)

                Text(topic.body)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 9, y: 4)
        .accessibilityElement(children: .combine)
    }

    /// Reopens the European ad consent choices, where the rules require them.
    private var consentButton: some View {
        Button {
            Task { await ads.presentPrivacyOptions() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .heavy))
                Text(strings.adsPrivacyOptionsTitle)
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
            }
            .foregroundStyle(Palette.coral)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                Capsule().fill(Palette.coral.opacity(0.12))
            )
        }
        .buttonStyle(PressableCardStyle())
    }
}

#Preview {
    PrivacyInfoView()
        .environment(AppSettings())
        .environment(AdsService())
        .environment(SubscriptionService())
}
