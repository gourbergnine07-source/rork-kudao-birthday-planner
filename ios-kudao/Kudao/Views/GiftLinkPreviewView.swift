//
//  GiftLinkPreviewView.swift
//  Kudao
//

import SwiftUI
import UIKit

/// A shopping link waiting to be inspected before it leaves the app.
struct GiftLinkPreview: Identifiable, Equatable {
    let id: UUID = UUID()
    /// The AI-generated gift idea used as the search query.
    let query: String
    /// Amazon destination, tagged when the storefront has an Associates tag.
    let amazon: GiftDestination
    /// Google Shopping search for the same idea, offered as the alternative.
    let web: GiftDestination?
}

/// Shows exactly which URL the gift button will open, before opening it.
///
/// Affiliate links are opaque by nature — this sheet makes the storefront, the
/// tag and the full query visible, so the user can check the tag is really
/// attached before Safari takes over.
struct GiftLinkPreviewView: View {
    let preview: GiftLinkPreview

    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var hasCopied: Bool = false

    private var strings: Strings { settings.strings }

    private var destination: GiftDestination { preview.amazon }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    detailCard
                    urlCard
                    actions
                    if destination.isAffiliate {
                        disclosure
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .background(Palette.background)
            .navigationTitle(strings.linkPreviewTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(strings.doneAction) { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationContentInteraction(.scrolls)
        .presentationDragIndicator(.visible)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: destination.isAffiliate ? "link.badge.plus" : "link")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Circle().fill(Palette.berry.gradient))
                .shadow(color: Palette.berry.opacity(0.32), radius: 12, y: 6)

            Text(preview.query)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 6)
    }

    private var detailCard: some View {
        VStack(spacing: 0) {
            detailRow(
                label: strings.linkPreviewStoreLabel,
                value: (destination.marketplace?.flag ?? "🌍") + "  " + (destination.marketplace?.displayName ?? "—"),
                isMonospaced: false
            )

            Divider().overlay(Palette.hairline)

            detailRow(
                label: strings.linkPreviewQueryLabel,
                value: preview.query,
                isMonospaced: false
            )

            Divider().overlay(Palette.hairline)

            if let tag = destination.tag {
                detailRow(label: strings.affiliateTagLabel, value: tag, isMonospaced: true, tint: Palette.amber)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Palette.amber)
                        Text(strings.linkPreviewNoTag)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    }
                    Text(strings.linkPreviewNoTagHint)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }

    private func detailRow(
        label: String,
        value: String,
        isMonospaced: Bool,
        tint: Color = .primary
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer(minLength: 8)

            Text(value)
                .font(isMonospaced
                    ? .system(.footnote, design: .monospaced)
                    : .system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(tint)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var urlCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(strings.linkPreviewUrlLabel)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(destination.url.absoluteString)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Palette.surfaceRaised)
        )
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button {
                ExternalLink.open(destination.url)
                dismiss()
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: "safari.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text(strings.linkPreviewOpenAction)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Capsule().fill(Palette.berry.gradient))
            }
            .buttonStyle(PressableCardStyle())

            Button {
                UIPasteboard.general.string = destination.url.absoluteString
                withAnimation(.smooth(duration: 0.25)) { hasCopied = true }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: hasCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .font(.system(size: 14, weight: .bold))
                    Text(hasCopied ? strings.linkPreviewCopiedLabel : strings.linkPreviewCopyAction)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                }
                .foregroundStyle(hasCopied ? Palette.teal : Palette.clay)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    Capsule().strokeBorder(
                        (hasCopied ? Palette.teal : Palette.clay).opacity(0.35),
                        lineWidth: 1
                    )
                )
            }
            .buttonStyle(PressableCardStyle())

            if let web = preview.web {
                Button {
                    ExternalLink.open(web.url)
                    dismiss()
                } label: {
                    Text(strings.linkPreviewGoogleAction)
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var disclosure: some View {
        Label(strings.affiliateDisclosure, systemImage: "info.circle")
            .font(.system(.caption2, design: .rounded))
            .foregroundStyle(.tertiary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
