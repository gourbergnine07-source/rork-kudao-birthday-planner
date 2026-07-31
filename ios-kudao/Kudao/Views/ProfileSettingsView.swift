//
//  ProfileSettingsView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Per-profile settings: reminder scheduling and diary export.
struct ProfileSettingsView: View {
    let profile: BirthdayProfile

    @Environment(AppSettings.self) private var settings
    @Environment(NotificationService.self) private var notifications
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var exportingFormat: DiaryExportFormat?
    @State private var exportedFile: ExportedFile?
    @State private var exportFailed: Bool = false

    private var strings: Strings { settings.strings }

    /// One value that changes whenever any reminder preference changes.
    private var reminderSignature: String {
        [
            profile.isReminderEnabled ? "1" : "0",
            String(profile.reminderDaysBefore),
            profile.isGiftReminderEnabled ? "1" : "0",
            String(profile.giftReminderDaysBefore),
        ].joined(separator: "|")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 18) {
                        if notifications.isDenied {
                            deniedBanner
                        }

                        birthdayReminderCard
                        giftReminderCard
                        exportCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 36)
                    .padding(.top, 6)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(strings.remindersMenuTitle)
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
        .onChange(of: reminderSignature) { _, _ in
            persistAndReschedule()
        }
        .sheet(item: $exportedFile) { file in
            ShareSheet(url: file.url)
        }
        .alert(strings.exportFailedTitle, isPresented: $exportFailed) {
            Button(strings.doneAction, role: .cancel) {}
        } message: {
            Text(strings.exportFailedMessage)
        }
    }

    // MARK: - Reminder cards

    private var birthdayReminderCard: some View {
        @Bindable var bindable = profile

        return SettingsCard(
            title: strings.remindersSectionTitle,
            systemImage: "bell.badge.fill",
            tint: Palette.coral
        ) {
            Toggle(isOn: $bindable.isReminderEnabled) {
                Text(strings.reminderToggleTitle)
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
            .tint(Palette.coral)

            Text(strings.reminderToggleDescription)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if profile.isReminderEnabled {
                Divider().overlay(Palette.hairline)

                DaysStepper(
                    label: strings.reminderDaysTitle,
                    value: $bindable.reminderDaysBefore,
                    range: 1...60,
                    tint: Palette.coral,
                    strings: strings
                )

                fireDateLabel(profile.birthdayReminderDate)
            }
        }
    }

    private var giftReminderCard: some View {
        @Bindable var bindable = profile

        return SettingsCard(
            title: strings.giftReminderDaysTitle,
            systemImage: "gift.fill",
            tint: Palette.berry
        ) {
            Toggle(isOn: $bindable.isGiftReminderEnabled) {
                Text(strings.giftReminderToggleTitle)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .tint(Palette.berry)
            .disabled(!profile.isReminderEnabled)

            Text(strings.giftReminderDescription)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if profile.isReminderEnabled && profile.isGiftReminderEnabled {
                Divider().overlay(Palette.hairline)

                DaysStepper(
                    label: strings.reminderDaysTitle,
                    value: $bindable.giftReminderDaysBefore,
                    range: 1...120,
                    tint: Palette.berry,
                    strings: strings
                )

                fireDateLabel(profile.giftReminderDate)

                if let giftIdea = profile.partyPlan?.giftIdea, !giftIdea.isEmpty {
                    Label(giftIdea, systemImage: "sparkles")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                        .foregroundStyle(Palette.berry)
                        .lineLimit(2)
                }
            }
        }
        .opacity(profile.isReminderEnabled ? 1 : 0.55)
    }

    @ViewBuilder
    private func fireDateLabel(_ date: Date?) -> some View {
        HStack(spacing: 7) {
            Image(systemName: date == nil ? "bell.slash" : "clock.badge.checkmark")
                .font(.system(size: 11, weight: .bold))
            Text(
                date.map { String(format: strings.reminderScheduledFormat, settings.weekdayDayMonth($0)) }
                    ?? strings.reminderDisabledLabel
            )
            .font(.system(.caption, design: .rounded, weight: .medium))
            Spacer(minLength: 0)
        }
        .foregroundStyle(.secondary)
    }

    private var deniedBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Palette.amber)
                Text(strings.notificationsDeniedTitle)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                Spacer(minLength: 0)
            }

            Text(strings.notificationsDeniedMessage)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                notifications.openSystemSettings()
            } label: {
                Text(strings.openSettingsAction)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(Palette.amber)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Palette.amber.opacity(0.16)))
            }
            .buttonStyle(PressableCardStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.amber.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.amber.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Export

    private var exportCard: some View {
        SettingsCard(
            title: strings.exportSectionTitle,
            systemImage: "square.and.arrow.up",
            tint: Palette.teal
        ) {
            Text(strings.exportSectionDescription)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                ForEach(DiaryExportFormat.allCases) { format in
                    exportButton(format)
                }
            }

            if exportingFormat != nil {
                HStack(spacing: 8) {
                    ProgressView().controlSize(.mini).tint(Palette.teal)
                    Text(strings.exportPreparing)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func exportButton(_ format: DiaryExportFormat) -> some View {
        Button {
            export(format)
        } label: {
            VStack(spacing: 7) {
                Image(systemName: format.symbolName)
                    .font(.system(size: 19, weight: .semibold))
                Text(format.title(strings))
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(Palette.teal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Palette.teal.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Palette.teal.opacity(0.28), lineWidth: 1)
            )
        }
        .buttonStyle(PressableCardStyle())
        .disabled(exportingFormat != nil)
    }

    // MARK: - Actions

    private func export(_ format: DiaryExportFormat) {
        guard exportingFormat == nil else { return }
        exportingFormat = format

        let snapshot = DiaryExportService.snapshot(of: profile)
        let strings = self.strings
        let locale = settings.locale

        Task {
            defer { exportingFormat = nil }
            do {
                let url = try await Task.detached(priority: .userInitiated) {
                    try DiaryExportService.writeFile(
                        snapshot,
                        format: format,
                        strings: strings,
                        locale: locale
                    )
                }.value
                exportedFile = ExportedFile(url: url)
            } catch {
                exportFailed = true
            }
        }
    }

    private func persistAndReschedule() {
        try? modelContext.save()
        let strings = self.strings
        let privacy = ReminderPrivacy(hidesSurprisePreviews: settings.hidesSurpriseNotificationPreviews)
        Task {
            await notifications.sync(profiles: [profile], strings: strings, privacy: privacy)
        }
    }
}

/// Titled container used by the settings cards.
private struct SettingsCard<Content: View>: View {
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

/// "Ricordami N giorni prima" stepper with a big readable value.
private struct DaysStepper: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let tint: Color
    let strings: Strings

    private var formatted: String {
        String(format: value == 1 ? strings.dayBeforeFormat : strings.daysBeforeFormat, value)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
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
        .sensoryFeedback(.selection, trigger: value)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(formatted)")
    }
}

#Preview {
    ProfileSettingsView(
        profile: BirthdayProfile(name: "Giulia", birthDate: Date(), relationship: .friend)
    )
    .environment(AppSettings())
    .environment(NotificationService.shared)
    .modelContainer(KudaoModelContainer.preview())
}
