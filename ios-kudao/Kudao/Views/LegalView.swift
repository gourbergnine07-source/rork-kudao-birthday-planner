//
//  LegalView.swift
//  Kudao
//

import SwiftUI
import UIKit

/// The four public documents behind Kudao, one tap from Settings.
///
/// `PrivacyInfoView` explains privacy in the user's own words; this screen is the
/// paperwork itself — the signed policy, the terms of the subscription, the way to
/// reach a human, and the form for asking for a copy or a deletion. App Review
/// looks for these to be reachable without an account, so every row leaves for the
/// system browser where the page is public.
struct LegalView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    private var strings: Strings { settings.strings }

    /// One document: what it is, why you would open it, and where it lives.
    private struct Document: Identifiable {
        let id: String
        let symbol: String
        let tint: Color
        let title: String
        let body: String
        let url: URL?
    }

    private var documents: [Document] {
        [
            Document(
                id: "privacy",
                symbol: "lock.shield.fill",
                tint: Palette.teal,
                title: strings.legalPrivacyTitle,
                body: strings.legalPrivacyBody,
                url: LegalLinks.privacy
            ),
            Document(
                id: "terms",
                symbol: "doc.text.fill",
                tint: Palette.violet,
                title: strings.legalTermsTitle,
                body: strings.legalTermsBody,
                url: LegalLinks.terms
            ),
            Document(
                id: "support",
                symbol: "lifepreserver.fill",
                tint: Palette.coral,
                title: strings.legalSupportTitle,
                body: strings.legalSupportBody,
                url: LegalLinks.support
            ),
            Document(
                id: "choices",
                symbol: "hand.raised.fill",
                tint: Palette.clay,
                title: strings.legalChoicesTitle,
                body: strings.legalChoicesBody,
                url: LegalLinks.privacyChoices
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 14) {
                        header

                        ForEach(documents) { document in
                            documentRow(document)
                        }

                        footer
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(strings.legalTitle)
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
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(Circle().fill(Palette.warmGradient))
                .shadow(color: Palette.coral.opacity(0.28), radius: 14, y: 7)

            Text(strings.legalIntro)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 2)
    }

    private func documentRow(_ document: Document) -> some View {
        Button {
            open(document.url)
        } label: {
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: document.symbol)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(document.tint)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(document.tint.opacity(0.13)))

                VStack(alignment: .leading, spacing: 5) {
                    Text(document.title)
                        .font(.system(.subheadline, design: .rounded, weight: .heavy))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text(document.body)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 10)
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
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityHint(strings.legalOpensInBrowser)
    }

    private var footer: some View {
        VStack(spacing: 6) {
            Text(strings.legalOpensInBrowser)
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)

            Text(strings.legalCopyright)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 8)
        .padding(.top, 6)
    }

    /// Sends the page to Safari, with a light tap so the hand-off is felt.
    private func open(_ url: URL?) {
        guard let url else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        ExternalLink.open(url)
    }
}

#Preview {
    LegalView()
        .environment(AppSettings())
}
