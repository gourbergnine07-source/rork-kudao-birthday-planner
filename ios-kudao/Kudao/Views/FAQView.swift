//
//  FAQView.swift
//  Kudao
//

import SwiftUI
import UIKit

/// The help desk: every common question, grouped and openable one at a time.
///
/// Answers stay closed by default so the whole map of topics is visible at a
/// glance; tapping a row unfolds it in place rather than pushing a new screen,
/// because most questions are answered in two sentences and a navigation stack
/// would cost more taps than it saves. Searching opens every match automatically
/// — when you are hunting for one specific sentence, being made to tap again is
/// pure friction.
struct FAQView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var expanded: Set<String> = []
    @State private var searchText: String = ""
    @State private var toggleCount: Int = 0

    private var strings: Strings { settings.strings }

    private var query: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var allSections: [FAQSection] {
        FAQCatalog.sections(for: settings.language)
    }

    /// Sections keeping only the entries that match, empty ones dropped.
    private var visibleSections: [FAQSection] {
        guard !query.isEmpty else { return allSections }
        let searched = query
        return allSections.compactMap { section in
            let hits = section.entries.filter { $0.matches(searched) }
            guard !hits.isEmpty else { return nil }
            return FAQSection(id: section.id, title: section.title, entries: hits)
        }
    }

    private var hasResults: Bool { !visibleSections.isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header

                        SearchField(
                            placeholder: strings.faqSearchPlaceholder,
                            clearLabel: strings.searchClear,
                            text: $searchText
                        )

                        if hasResults {
                            ForEach(visibleSections) { section in
                                sectionBlock(section)
                            }
                        } else {
                            PlaceholderPanel(
                                icon: "magnifyingglass",
                                title: strings.noResultsTitle,
                                message: String(format: strings.noResultsMessageFormat, query)
                            )
                            .padding(.top, 6)
                        }

                        helpCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle(strings.faqTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(strings.doneAction) { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
            .environment(\.locale, settings.locale)
            .sensoryFeedback(.selection, trigger: toggleCount)
        }
        .tint(Palette.coral)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.bubble.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(Circle().fill(Palette.warmGradient))
                .shadow(color: Palette.coral.opacity(0.28), radius: 14, y: 7)

            Text(strings.faqIntro)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(String(format: strings.faqCountFormat, FAQCatalog.count(for: settings.language)))
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(Palette.coral)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Palette.coral.opacity(0.12)))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 2)
    }

    // MARK: - Sections

    private func sectionBlock(_ section: FAQSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(section.title, systemImage: symbol(for: section.id))
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(tint(for: section.id))
                .textCase(.uppercase)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(section.entries) { entry in
                    FAQRow(
                        entry: entry,
                        tint: tint(for: section.id),
                        isOpen: expanded.contains(entry.id) || !query.isEmpty,
                        onTap: { toggle(entry.id) }
                    )
                }
            }
        }
        .padding(.top, 2)
    }

    // MARK: - Fallback

    private var helpCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "lifepreserver.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Palette.coral)

            Text(strings.faqHelpTitle)
                .font(.system(.subheadline, design: .rounded, weight: .heavy))
                .foregroundStyle(.primary)

            Text(strings.faqHelpBody)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                openSupport()
            } label: {
                Text(strings.faqHelpAction)
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 11)
                    .background(Capsule().fill(Palette.warmGradient))
            }
            .buttonStyle(PressableCardStyle())
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.surfaceRaised)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func toggle(_ id: String) {
        // While searching every row is already open, so collapsing one would
        // fight the filter. Leave the tap inert instead of flickering.
        guard query.isEmpty else { return }

        toggleCount += 1
        withAnimation(.smooth(duration: 0.26)) {
            if expanded.contains(id) {
                expanded.remove(id)
            } else {
                expanded.insert(id)
            }
        }
    }

    private func openSupport() {
        guard let url = LegalLinks.support else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        ExternalLink.open(url)
    }

    // MARK: - Styling

    private func symbol(for sectionID: String) -> String {
        switch sectionID {
        case "start": "sparkles"
        case "reminders": "bell.badge.fill"
        case "sharing": "person.2.fill"
        case "premium": "crown.fill"
        case "privacy": "lock.shield.fill"
        case "backup": "icloud.fill"
        default: "questionmark.circle.fill"
        }
    }

    private func tint(for sectionID: String) -> Color {
        switch sectionID {
        case "start": Palette.coral
        case "reminders": Palette.amber
        case "sharing": Palette.violet
        case "premium": Palette.berry
        case "privacy": Palette.teal
        case "backup": Palette.sage
        default: Palette.clay
        }
    }
}

/// One question that unfolds its answer in place.
///
/// Split out of `FAQView` because the open/closed state feeds colour, border
/// width, shadow and rotation at once, and the type checker cannot untangle that
/// many conditionals inside a larger body.
private struct FAQRow: View {
    let entry: FAQEntry
    let tint: Color
    let isOpen: Bool
    let onTap: () -> Void

    private var borderColor: Color {
        isOpen ? tint.opacity(0.45) : Palette.hairline
    }

    private var borderWidth: CGFloat { isOpen ? 1.5 : 1 }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                questionLine

                if isOpen {
                    answerLine
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(shape.fill(Palette.surface))
            .overlay(shape.strokeBorder(borderColor, lineWidth: borderWidth))
            .shadow(color: Color.black.opacity(isOpen ? 0.05 : 0.03), radius: isOpen ? 10 : 6, y: 4)
            .contentShape(shape)
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel(entry.question)
        .accessibilityValue(isOpen ? entry.answer : "")
        .accessibilityAddTraits(isOpen ? [.isSelected] : [])
    }

    private var questionLine: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(entry.question)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(isOpen ? tint : Color.secondary.opacity(0.55))
                .rotationEffect(.degrees(isOpen ? 0 : -90))
                .padding(.top, 2)
        }
    }

    private var answerLine: some View {
        Text(entry.answer)
            .font(.system(.footnote, design: .rounded))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 10)
            .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

#Preview {
    FAQView()
        .environment(AppSettings())
}
