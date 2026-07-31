//
//  PlanConfirmationView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Reminder follow-up screen: a compact recap of the saved party plan with
/// "Confirm" and "Edit" actions. Opened from a reminder tap or the home badge.
struct PlanConfirmationView: View {
    let profile: BirthdayProfile
    /// Called when the user wants to jump into the suggestions tab.
    let onEdit: () -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var didConfirm: Bool = false

    private var strings: Strings { settings.strings }
    private var countdown: BirthdayCountdown { profile.countdown }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 18) {
                        header

                        if let plan = profile.partyPlan {
                            planRows(plan.suggestion)
                        } else {
                            PlaceholderPanel(
                                icon: "sparkles",
                                title: strings.planReviewNoPlanTitle,
                                message: strings.planReviewNoPlanMessage,
                                tint: Palette.berry
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .safeAreaInset(edge: .bottom) {
                actions
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                    .background(.ultraThinMaterial)
            }
            .navigationTitle(strings.planReviewTitle)
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.coral)
        .presentationDetents([.large])
        .presentationContentInteraction(.scrolls)
        .sensoryFeedback(.success, trigger: didConfirm)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 14) {
            AvatarView(
                name: profile.name,
                photoData: profile.photoData,
                size: 78,
                ringColor: Palette.coral.opacity(0.35),
                ringWidth: 3
            )

            Text(
                countdown.isToday
                    ? String(format: strings.planReviewTodayFormat, profile.name)
                    : String(format: strings.planReviewSubtitleFormat, profile.name, countdown.daysRemaining)
            )
            .font(.system(.headline, design: .rounded, weight: .semibold))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                KudaoChip(
                    title: settings.dayMonth(countdown.nextDate),
                    systemImage: "calendar"
                )
                if let plan = profile.partyPlan, plan.isConfirmed {
                    KudaoChip(title: strings.confirmAction, systemImage: "checkmark.seal.fill")
                } else {
                    KudaoChip(title: strings.pendingBadgeLabel, systemImage: "exclamationmark.circle.fill")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Plan recap

    private func planRows(_ suggestion: PartySuggestion) -> some View {
        VStack(spacing: 10) {
            ForEach(PlanSection.allCases) { section in
                row(section, suggestion: suggestion)
            }
        }
    }

    private func row(_ section: PlanSection, suggestion: PartySuggestion) -> some View {
        let headline = suggestion.headline(for: section, strings: strings)

        return HStack(spacing: 13) {
            ZStack {
                Circle()
                    .fill(section.accent.opacity(0.14))
                    .frame(width: 38, height: 38)
                Image(systemName: section.symbolName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(section.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(section.title(strings))
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(headline.isEmpty ? "—" : headline)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            if section == .gift {
                Text(suggestion.giftPriceBand.title(strings))
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(Palette.berry)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Palette.berry.opacity(0.12)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - Actions

    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                onEdit()
                dismiss()
            } label: {
                Text(strings.modifyAction)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(Palette.coral)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Capsule().fill(Palette.coral.opacity(0.14)))
            }
            .buttonStyle(PressableCardStyle())

            Button {
                confirm()
            } label: {
                Label(strings.confirmAction, systemImage: "checkmark")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Capsule().fill(Palette.warmGradient))
                    .shadow(color: Palette.coral.opacity(0.3), radius: 12, y: 6)
            }
            .buttonStyle(PressableCardStyle())
            .disabled(profile.partyPlan == nil)
            .opacity(profile.partyPlan == nil ? 0.5 : 1)
        }
        .animation(reduceMotion ? nil : .smooth(duration: 0.25), value: didConfirm)
    }

    private func confirm() {
        if let plan = profile.partyPlan, !plan.isConfirmed {
            plan.confirmedAt = Date()
            try? modelContext.save()
        }
        didConfirm = true
        dismiss()
    }
}
