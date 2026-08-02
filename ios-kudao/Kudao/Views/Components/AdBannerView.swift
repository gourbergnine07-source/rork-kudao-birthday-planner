//
//  AdBannerView.swift
//  Kudao
//

import GoogleMobileAds
import SwiftUI

/// The one banner Kudao shows: a low card pinned under Home.
///
/// It draws nothing at all until an ad has actually arrived, so a failed
/// request never leaves a grey rectangle behind. Subscribers and remembrance
/// profiles never reach the drawing code — `showsAds(in:)` decides that first.
struct AdBannerView: View {
    /// The occasion the surrounding screen belongs to, `nil` on Home.
    var occasion: OccasionKind?
    /// Opens the paywall from the small "remove" affordance.
    var onUpgrade: () -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(SubscriptionService.self) private var subscriptions
    @Environment(AdsService.self) private var ads

    @State private var didLoad: Bool = false

    private var strings: Strings { settings.strings }

    private var isVisible: Bool {
        subscriptions.showsAds(in: occasion) && ads.canRequestAds
    }

    var body: some View {
        Group {
            if isVisible {
                card
            }
        }
        .animation(.smooth(duration: 0.35), value: didLoad)
        .animation(.smooth(duration: 0.25), value: isVisible)
    }

    private var card: some View {
        let width = min(UIScreen.main.bounds.width - 32, 468)
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: width)

        return VStack(spacing: 4) {
            HStack(spacing: 6) {
                Text(strings.adsSponsoredLabel)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(.tertiary)

                Spacer(minLength: 0)

                Button(action: onUpgrade) {
                    HStack(spacing: 3) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text(strings.adsRemoveAction)
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                    }
                    .foregroundStyle(Palette.coral.opacity(0.85))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
            .opacity(didLoad ? 1 : 0)

            BannerAdContainer(adSize: adSize, adUnitID: AdsService.bannerUnitID) { loaded in
                didLoad = loaded
            }
            .frame(width: adSize.size.width, height: adSize.size.height)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Palette.surface.opacity(didLoad ? 0.92 : 0))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Palette.hairline.opacity(didLoad ? 1 : 0), lineWidth: 1)
                )
        )
        .frame(height: didLoad ? nil : 0, alignment: .top)
        .clipped()
        .accessibilityHidden(!didLoad)
    }
}

/// Bridges AdMob's UIKit banner into SwiftUI and reports whether it filled.
private struct BannerAdContainer: UIViewRepresentable {
    let adSize: AdSize
    let adUnitID: String
    let onResult: (Bool) -> Void

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        banner.backgroundColor = .clear
        banner.load(AdsService.makeRequest())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        context.coordinator.onResult = onResult
        if uiView.adSize.size != adSize.size {
            uiView.adSize = adSize
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onResult: onResult)
    }

    final class Coordinator: NSObject, BannerViewDelegate {
        var onResult: (Bool) -> Void

        init(onResult: @escaping (Bool) -> Void) {
            self.onResult = onResult
        }

        nonisolated func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            Task { @MainActor in onResult(true) }
        }

        nonisolated func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            let description = error.localizedDescription
            Task { @MainActor in
                print("[Kudao] Banner unavailable: \(description)")
                onResult(false)
            }
        }
    }
}
