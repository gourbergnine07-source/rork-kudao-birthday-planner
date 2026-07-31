//
//  NotificationSettingsView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Lead times of every reminder, chosen once per category of occasion.
///
/// A birthday wants a week of warning, an anniversary maybe two, a remembrance
/// nothing at all — so each `OccasionKind` carries its own default. New profiles
/// inherit the value of their category, and existing ones can be re-aligned with
/// one tap without losing the ones that were tuned by hand.
struct NotificationSettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(NotificationService.self) private var notifications
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var profiles: [BirthdayProfile]

    /// Category whose "apply to existing" button was just used, for the confirmation swap.
    @State private var appliedOccasion: OccasionKind?

    private var strings: Strings { settings.strings }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 18) {
                        permissionCard
                        timeCard

                        ForEach(OccasionKind.allCases) { occasion in
                            occasionCard(occasion)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 36)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(strings.notificationSettingsMenuTitle)
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
        .task {
            await notifications.refreshStatus()
        }
        .onDisappear {
            rescheduleAll()
        }
    }

    // MARK: - Permission

    @ViewBuilder
    private var permissionCard: some View {
        switch notifications.authorizationStatus {
        case .denied:
            NotificationCard(
                title: strings.notificationsDeniedTitle,
                systemImage: "bell.slash.fill",
                tint: Palette.berry
            ) {
                Text(strings.notificationsDeniedMessage)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(strings.openSettingsAction) {
                    notifications.openSystemSettings()
                }
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(Palette.berry)
            }

        case .notDetermined:
            NotificationCard(
                title: strings.notificationSettingsMenuTitle,
                systemImage: "bell.badge.fill",
                tint: Palette.coral
            ) {
                Text(strings.notificationSettingsCaption)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    Task {
                        await notifications.requestAuthorization()
                        rescheduleAll()
                    }
                } label: {
                    Text(strings.enableNotificationsAction)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Capsule().fill(Palette.coral))
                }
                .buttonStyle(PressableCardStyle())
            }

        default:
            NotificationCard(
                title: strings.notificationSettingsMenuTitle,
                systemImage: "bell.badge.fill",
                tint: Palette.coral
            ) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Palette.teal)
                    Text(strings.notificationsActiveLabel)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                    Spacer(minLength: 0)
                }

                Text(strings.notificationSettingsCaption)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Time of day

    private var timeCard: some View {
        @Bindable var bindable = settings

        return NotificationCard(
            title: strings.defaultReminderTimeLabel,
            systemImage: "clock.fill",
            tint: Palette.teal
        ) {
            HStack(spacing: 10) {
                Text(strings.defaultReminderTimeLabel)
                    .font(.system(.body, design: .rounded, weight: .semibold))

                Spacer(minLength: 0)

                DatePicker(
                    strings.defaultReminderTimeLabel,
                    selection: $bindable.reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .tint(Palette.teal)
            }

            Label(strings.defaultsAppliedNote, systemImage: "info.circle.fill")
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - One category of occasion

    private func occasionCard(_ occasion: OccasionKind) -> some View {
        let owned = profiles.filter { $0.occasion == occasion }
        let pending = outOfSync(occasion)

        return NotificationCard(
            title: occasion.pluralTitle(strings),
            systemImage: occasion.symbolName,
            tint: occasion.accent
        ) {
            LeadTimeRow(
                label: strings.mainReminderLabel,
                icon: "calendar.badge.clock",
                value: daysBinding(occasion),
                range: ReminderDefaults.daysRange,
                presets: [0, 1, 3, 7, 14, 30],
                tint: occasion.accent,
                strings: strings
            )

            if occasion.wantsSuggestions {
                Divider().overlay(Palette.hairline)

                LeadTimeRow(
                    label: strings.defaultGiftDaysLabel,
                    icon: "gift.fill",
                    value: giftDaysBinding(occasion),
                    range: ReminderDefaults.giftDaysRange,
                    presets: [3, 7, 10, 14, 30],
                    tint: occasion.accent,
                    strings: strings
                )
            }

            Divider().overlay(Palette.hairline)

            if owned.isEmpty {
                Text(strings.noProfilesInCategoryLabel)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.tertiary)
            } else {
                if let preview = nextFireLabel(for: owned) {
                    Label(preview, systemImage: "clock.badge.checkmark")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if pending.isEmpty {
                    Label(
                        appliedOccasion == occasion
                            ? strings.appliedToExistingLabel
                            : String(format: strings.profilesCountFormat, owned.count),
                        systemImage: appliedOccasion == occasion ? "checkmark.circle.fill" : "person.2.fill"
                    )
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(appliedOccasion == occasion ? AnyShapeStyle(Palette.teal) : AnyShapeStyle(.tertiary))
                    .contentTransition(.symbolEffect(.replace))
                } else {
                    Button {
                        apply(to: occasion)
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 12, weight: .bold))
                            Text(String(format: strings.applyToExistingFormat, pending.count))
                                .font(.system(.caption, design: .rounded, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .foregroundStyle(occasion.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(occasion.accent.opacity(0.12)))
                    }
                    .buttonStyle(PressableCardStyle())
                }
            }

            if settings.hasCustomReminderDefaults(for: occasion) {
                Button(strings.resetToShippedAction) {
                    withAnimation(.smooth(duration: 0.2)) {
                        settings.resetReminderDefaults(for: occasion)
                    }
                }
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(.tertiary)
            }
        }
        .animation(.smooth(duration: 0.25), value: pending.count)
    }

    // MARK: - Bindings and helpers

    private func daysBinding(_ occasion: OccasionKind) -> Binding<Int> {
        Binding(
            get: { settings.reminderDays(for: occasion) },
            set: { newValue in
                settings.setReminderDays(newValue, for: occasion)
                appliedOccasion = nil
            }
        )
    }

    private func giftDaysBinding(_ occasion: OccasionKind) -> Binding<Int> {
        Binding(
            get: { settings.giftReminderDays(for: occasion) },
            set: { newValue in
                settings.setGiftReminderDays(newValue, for: occasion)
                appliedOccasion = nil
            }
        )
    }

    /// Existing profiles of a category that no longer match its defaults.
    private func outOfSync(_ occasion: OccasionKind) -> [BirthdayProfile] {
        let days = settings.reminderDays(for: occasion)
        let giftDays = settings.giftReminderDays(for: occasion)

        return profiles.filter { profile in
            guard profile.occasion == occasion else { return false }
            if profile.reminderDaysBefore != days { return true }
            return occasion.wantsSuggestions && profile.giftReminderDaysBefore != giftDays
        }
    }

    /// "Programmato per giovedì 3 giugno", using the soonest profile of the category.
    private func nextFireLabel(for owned: [BirthdayProfile]) -> String? {
        let dates = owned.compactMap(\.birthdayReminderDate).sorted()
        guard let next = dates.first else { return nil }
        return String(format: strings.reminderScheduledFormat, settings.weekdayDayMonth(next))
    }

    private func apply(to occasion: OccasionKind) {
        let targets = outOfSync(occasion)
        guard !targets.isEmpty else { return }

        let days = settings.reminderDays(for: occasion)
        let giftDays = settings.giftReminderDays(for: occasion)

        for profile in targets {
            profile.reminderDaysBefore = days
            if occasion.wantsSuggestions {
                profile.giftReminderDaysBefore = giftDays
            }
        }

        try? modelContext.save()
        appliedOccasion = occasion
        rescheduleAll()
    }

    private func rescheduleAll() {
        let all = profiles
        let strings = self.strings
        let privacy = ReminderPrivacy(hidesSurprisePreviews: settings.hidesSurpriseNotificationPreviews)

        Task {
            await notifications.sync(profiles: all, strings: strings, privacy: privacy)
        }
    }
}

/// One lead time: a big readable value, quick presets and a fine-tuning stepper.
private struct LeadTimeRow: View {
    let label: String
    let icon: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let presets: [Int]
    let tint: Color
    let strings: Strings

    private var formatted: String {
        guard value > 0 else { return strings.reminderOnTheDayLabel }
        return String(format: value == 1 ? strings.dayBeforeFormat : strings.daysBeforeFormat, value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(formatted)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(tint)
                        .contentTransition(.numericText())
                }

                Spacer(minLength: 0)

                Stepper("", value: $value, in: range)
                    .labelsHidden()
                    .tint(tint)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(label) \(formatted)")

            HStack(spacing: 6) {
                ForEach(presets.filter(range.contains), id: \.self) { preset in
                    presetChip(preset)
                }
                Spacer(minLength: 0)
            }
        }
        .animation(.smooth(duration: 0.2), value: value)
        .sensoryFeedback(.selection, trigger: value)
    }

    private func presetChip(_ preset: Int) -> some View {
        let isActive = preset == value

        return Button {
            value = preset
        } label: {
            Text(preset == 0 ? "0" : "\(preset)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(isActive ? .white : .secondary)
                .frame(minWidth: 34)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(isActive ? AnyShapeStyle(tint) : AnyShapeStyle(Palette.surfaceRaised))
                )
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel(
            preset == 0
                ? strings.reminderOnTheDayLabel
                : String(format: preset == 1 ? strings.dayBeforeFormat : strings.daysBeforeFormat, preset)
        )
    }
}

/// Titled container matching the other settings cards.
private struct NotificationCard<Content: View>: View {
    let title: String
    let systemImage: String
    let tint: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(tint)
                .textCase(.uppercase)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
    }
}

#Preview {
    NotificationSettingsView()
        .environment(AppSettings())
        .environment(NotificationService.shared)
        .modelContainer(KudaoModelContainer.preview())
}
