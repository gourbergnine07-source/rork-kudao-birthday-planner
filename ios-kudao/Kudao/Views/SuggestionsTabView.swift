//
//  SuggestionsTabView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Suggestions tab: the AI party plan built from the diary preferences.
struct SuggestionsTabView: View {
    let profile: BirthdayProfile
    let engine: SuggestionEngine

    @Environment(AppSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var editingSection: PlanSection?

    private var strings: Strings { settings.strings }
    private var keywordCount: Int { SuggestionEngine.keywordCount(for: profile) }

    var body: some View {
        VStack(spacing: 16) {
            if keywordCount == 0 {
                PlaceholderPanel(
                    icon: "sparkles",
                    title: strings.suggestionsNoTagsTitle,
                    message: strings.suggestionsNoTagsMessage,
                    tint: Palette.berry
                )
            } else if let plan = profile.partyPlan {
                planContent(plan)
            } else if engine.isGeneratingPlan {
                generatingPanel
            } else {
                startPanel
            }
        }
        .animation(reduceMotion ? nil : .smooth(duration: 0.32), value: profile.partyPlan?.generatedAt)
        .task(id: profile.id) {
            guard profile.partyPlan == nil,
                  keywordCount > 0,
                  !engine.hasAttemptedAutoGeneration else { return }
            engine.generatePlan(for: profile, language: settings.language, context: modelContext)
        }
        .sheet(item: $editingSection) { section in
            SuggestionEditSheet(
                section: section,
                suggestion: profile.partyPlan?.suggestion ?? Self.emptySuggestion,
                strings: strings
            ) { edited in
                engine.applyManualEdit(edited, to: profile, context: modelContext)
            }
        }
    }

    private static let emptySuggestion = PartySuggestion(
        giftIdea: "",
        giftCategory: "",
        giftPriceBand: .medium,
        giftReason: "",
        cakeType: "",
        cakeReason: "",
        venueIdea: "",
        venueReason: "",
        guestCount: 8,
        confidence: .low
    )

    // MARK: - Plan

    @ViewBuilder
    private func planContent(_ plan: PartyPlan) -> some View {
        let suggestion = plan.suggestion

        planHeader(plan)

        if suggestion.confidence == .low {
            lowConfidenceBanner
        }

        if let message = engine.errorMessage {
            errorBanner(message)
        }

        ForEach(PlanSection.allCases) { section in
            card(section, suggestion: suggestion)
        }

        if plan.isConfirmed, let confirmedAt = plan.confirmedAt {
            confirmedBanner(confirmedAt)
        } else {
            confirmButton(plan)
        }
    }

    private func planHeader(_ plan: PartyPlan) -> some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                confidencePill(plan.suggestion.confidence)
                Text(String(format: strings.basedOnTagsFormat, plan.sourceKeywordCount))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Button {
                engine.generatePlan(for: profile, language: settings.language, context: modelContext)
            } label: {
                HStack(spacing: 6) {
                    if engine.isGeneratingPlan {
                        ProgressView()
                            .controlSize(.mini)
                            .tint(Palette.coral)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 12, weight: .bold))
                    }
                    Text(strings.regenerateAllAction)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                }
                .foregroundStyle(Palette.coral)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(Palette.coral.opacity(0.12)))
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(engine.isBusy)
            .opacity(engine.isBusy ? 0.5 : 1)
        }
    }

    private func confidencePill(_ confidence: SuggestionConfidence) -> some View {
        HStack(spacing: 5) {
            Image(systemName: confidence.symbolName)
                .font(.system(size: 11, weight: .bold))
            Text("\(strings.confidenceLabel) \(confidence.title(strings))")
                .font(.system(.caption, design: .rounded, weight: .bold))
        }
        .foregroundStyle(confidence.accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(confidence.accent.opacity(0.14)))
    }

    private var lowConfidenceBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "pencil.and.scribble")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.amber)
            Text(strings.lowConfidenceBanner)
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette.amber.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Palette.amber.opacity(0.28), lineWidth: 1)
        )
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.berry)
            VStack(alignment: .leading, spacing: 2) {
                Text(strings.suggestionsErrorTitle)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                Text(message)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Button {
                engine.clearError()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.secondary)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Palette.surfaceRaised))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette.berry.opacity(0.1))
        )
    }

    // MARK: - Cards

    private func card(_ section: PlanSection, suggestion: PartySuggestion) -> some View {
        let headline = suggestion.headline(for: section, strings: strings)
        let reason = suggestion.reason(for: section)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(section.accent.opacity(0.14))
                        .frame(width: 34, height: 34)
                    Image(systemName: section.symbolName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(section.accent)
                }

                Text(section.title(strings))
                    .font(.system(.subheadline, design: .rounded, weight: .bold))

                Spacer(minLength: 0)

                if section == .gift {
                    priceBadge(suggestion.giftPriceBand)
                }
            }

            Button {
                editingSection = section
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(headline.isEmpty ? "—" : headline)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Image(systemName: "pencil")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.tertiary)
                    }

                    if !reason.isEmpty {
                        Text(reason)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint(strings.editSuggestionTitle)

            HStack(spacing: 8) {
                Spacer(minLength: 0)
                Button {
                    engine.regenerate(
                        section: section,
                        for: profile,
                        language: settings.language,
                        context: modelContext
                    )
                } label: {
                    HStack(spacing: 6) {
                        if engine.isRegenerating(section) {
                            ProgressView()
                                .controlSize(.mini)
                                .tint(section.accent)
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11, weight: .bold))
                        }
                        Text(strings.regenerateAction)
                            .font(.system(.caption, design: .rounded, weight: .bold))
                    }
                    .foregroundStyle(section.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(section.accent.opacity(0.12)))
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(engine.isBusy)
                .opacity(engine.isBusy ? 0.5 : 1)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
    }

    private func priceBadge(_ band: PriceBand) -> some View {
        HStack(spacing: 6) {
            HStack(spacing: 2) {
                ForEach(1...3, id: \.self) { index in
                    Capsule()
                        .fill(index <= band.level ? Palette.berry : Palette.berry.opacity(0.2))
                        .frame(width: 4, height: index <= band.level ? 11 : 7)
                }
            }
            Text(band.title(strings))
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(Palette.berry)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill(Palette.berry.opacity(0.1)))
        .accessibilityLabel("\(strings.priceBandLabel): \(band.title(strings))")
    }

    // MARK: - Confirmation

    private func confirmButton(_ plan: PartyPlan) -> some View {
        VStack(spacing: 8) {
            if plan.isManuallyEdited {
                Label(strings.unconfirmedChanges, systemImage: "pencil.line")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Button {
                engine.confirmPlan(for: profile, context: modelContext)
            } label: {
                Label(strings.confirmAllAction, systemImage: "checkmark.seal.fill")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Capsule().fill(Palette.warmGradient))
                    .shadow(color: Palette.coral.opacity(0.32), radius: 14, y: 8)
            }
            .buttonStyle(PressableCardStyle())
            .disabled(engine.isBusy)
            .opacity(engine.isBusy ? 0.6 : 1)
        }
        .padding(.top, 4)
        .sensoryFeedback(.success, trigger: plan.confirmedAt)
    }

    private func confirmedBanner(_ date: Date) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Palette.teal)
            Text(String(format: strings.confirmedAtFormat, settings.noteTimestamp(date)))
                .font(.system(.footnote, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Palette.teal.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Palette.teal.opacity(0.3), lineWidth: 1)
        )
        .padding(.top, 4)
    }

    // MARK: - Loading / start

    private var generatingPanel: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Palette.berry)
                    .symbolEffect(.variableColor.iterative, options: reduceMotion ? .nonRepeating : .repeating)
                VStack(alignment: .leading, spacing: 2) {
                    Text(strings.suggestionsGeneratingTitle)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                    Text(strings.suggestionsGeneratingMessage)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            ForEach(PlanSection.allCases) { section in
                SkeletonCard(accent: section.accent, reduceMotion: reduceMotion)
            }
        }
    }

    private var startPanel: some View {
        VStack(spacing: 14) {
            if let message = engine.errorMessage {
                errorBanner(message)
            }

            PlaceholderPanel(
                icon: "sparkles",
                title: strings.suggestionsEmptyTitle,
                message: strings.suggestionsEmptyMessage,
                tint: Palette.berry
            )

            Button {
                engine.generatePlan(for: profile, language: settings.language, context: modelContext)
            } label: {
                Label(strings.generateAction, systemImage: "wand.and.sparkles")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Capsule().fill(Palette.warmGradient))
                    .shadow(color: Palette.coral.opacity(0.3), radius: 14, y: 8)
            }
            .buttonStyle(PressableCardStyle())
        }
    }
}

/// Pulsing block shown while the first plan is being generated.
private struct SkeletonCard: View {
    let accent: Color
    let reduceMotion: Bool

    @State private var isPulsing: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(accent.opacity(0.18))
                    .frame(width: 34, height: 34)
                Capsule()
                    .fill(Palette.surfaceRaised)
                    .frame(width: 90, height: 12)
                Spacer(minLength: 0)
            }
            Capsule()
                .fill(Palette.surfaceRaised)
                .frame(height: 18)
            Capsule()
                .fill(Palette.surfaceRaised)
                .frame(width: 180, height: 11)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .opacity(isPulsing ? 0.55 : 1)
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
            value: isPulsing
        )
        .onAppear { isPulsing = true }
    }
}

/// Manual override for one card of the plan.
private struct SuggestionEditSheet: View {
    let section: PlanSection
    let suggestion: PartySuggestion
    let strings: Strings
    let onSave: (PartySuggestion) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @State private var priceBand: PriceBand = .medium
    @State private var guestCount: Int = 8

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if section == .guests {
                        Stepper(value: $guestCount, in: 2...120) {
                            Text(String(format: strings.guestsUnitFormat, guestCount))
                                .font(.system(.body, design: .rounded, weight: .semibold))
                        }
                    } else {
                        TextField(section.title(strings), text: $text, axis: .vertical)
                            .font(.system(.body, design: .rounded))
                            .lineLimit(1...4)
                    }
                } header: {
                    Text(section.title(strings))
                        .font(.system(.caption, design: .rounded, weight: .bold))
                }

                if section == .gift {
                    Section {
                        Picker(strings.priceBandLabel, selection: $priceBand) {
                            ForEach(PriceBand.allCases) { band in
                                Text(band.title(strings)).tag(band)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(strings.editSuggestionTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(strings.cancelAction) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(strings.doneAction) {
                        onSave(edited())
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .disabled(section != .guests && text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .tint(Palette.coral)
        .onAppear {
            switch section {
            case .gift:
                text = suggestion.giftIdea
                priceBand = suggestion.giftPriceBand
            case .cake:
                text = suggestion.cakeType
            case .venue:
                text = suggestion.venueIdea
            case .guests:
                guestCount = suggestion.guestCount
            }
        }
    }

    private func edited() -> PartySuggestion {
        var result = suggestion
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        switch section {
        case .gift:
            result.giftIdea = cleaned
            result.giftPriceBand = priceBand
        case .cake:
            result.cakeType = cleaned
        case .venue:
            result.venueIdea = cleaned
        case .guests:
            result.guestCount = guestCount
        }
        return result
    }
}
