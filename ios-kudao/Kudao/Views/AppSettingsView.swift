//
//  AppSettingsView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// App-wide settings: language, sharing, surprise-mode protections and widget hint.
struct AppSettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(BiometricGate.self) private var gate
    @Environment(KudaoIdentity.self) private var identity
    @Environment(\.dismiss) private var dismiss

    @Environment(CloudBackupService.self) private var backup

    @State private var isJoining: Bool = false
    @State private var isManagingBackup: Bool = false
    @State private var isShowingMyProfile: Bool = false

    private var strings: Strings { settings.strings }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 18) {
                        collaborationCard
                        backupCard
                        surpriseCard
                        languageCard
                        widgetCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 36)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(strings.settingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(strings.doneAction) { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
            .environment(\.locale, settings.locale)
            .sheet(isPresented: $isJoining) {
                JoinShareView()
            }
            .sheet(isPresented: $isManagingBackup) {
                CloudBackupView()
            }
            .sheet(isPresented: $isShowingMyProfile) {
                MyProfileView()
            }
        }
        .tint(Palette.coral)
    }

    // MARK: - Sharing

    private var collaborationCard: some View {
        @Bindable var bindableIdentity = identity

        return AppSettingsCard(
            title: strings.collaborationSectionTitle,
            systemImage: "person.2.fill",
            tint: Palette.violet
        ) {
            Button {
                isJoining = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "person.2.badge.key.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.violet)
                    Text(strings.joinShareMenuTitle)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider().overlay(Palette.hairline)

            VStack(alignment: .leading, spacing: 6) {
                Text(strings.yourNameLabel)
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)

                TextField(strings.yourNamePlaceholder, text: $bindableIdentity.displayName)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .textInputAutocapitalization(.words)
                    .textContentType(.givenName)

                Text(strings.yourNameCaption)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Cloud backup

    private var backupCard: some View {
        AppSettingsCard(
            title: strings.cloudSectionTitle,
            systemImage: "icloud.fill",
            tint: Palette.teal
        ) {
            Button {
                isManagingBackup = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: backup.isEnabled ? "checkmark.icloud.fill" : "icloud.slash.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(backup.isEnabled ? Palette.teal : Color.secondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(backup.isEnabled ? strings.cloudOnLabel : strings.cloudOffLabel)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text(strings.cloudSectionCaption)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.tertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Surprise mode

    /// The switches themselves live in "My profile"; this is the shortcut to them.
    private var surpriseCard: some View {
        AppSettingsCard(
            title: strings.settingsSurpriseSection,
            systemImage: "eye.slash.fill",
            tint: Palette.berry
        ) {
            Button {
                isShowingMyProfile = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: gate.biometryKind.symbolName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.berry)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(strings.privacySectionTitle)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text(strings.privacyMovedCaption)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.tertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                statusChip(
                    title: strings.faceIDToggleTitle,
                    isOn: settings.protectsSurpriseProfiles
                )
                statusChip(
                    title: strings.hidePreviewsToggleTitle,
                    isOn: settings.hidesSurpriseNotificationPreviews
                )
                Spacer(minLength: 0)
            }

            if settings.hidesSurpriseNotificationPreviews {
                previewSample
            }

            Divider().overlay(Palette.hairline)

            Label(strings.settingsSharingNote, systemImage: "hand.raised.fill")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Compact on/off pill mirroring a privacy switch.
    private func statusChip(title: String, isOn: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 9, weight: .black))
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .lineLimit(1)
        }
        .foregroundStyle(isOn ? Palette.berry : Color.secondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(isOn ? Palette.berry.opacity(0.12) : Palette.surfaceRaised)
        )
    }

    /// Live preview of the discreet notification so the effect is obvious.
    private var previewSample: some View {
        HStack(spacing: 11) {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Palette.warmGradient)
                .frame(width: 34, height: 34)
                .overlay {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(strings.notificationGenericTitle)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                Text(strings.notificationGenericBody)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(11)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Palette.surfaceRaised)
        )
    }

    // MARK: - Language

    private var languageCard: some View {
        @Bindable var bindable = settings

        return AppSettingsCard(
            title: strings.settingsLanguageSection,
            systemImage: "globe",
            tint: Palette.coral
        ) {
            Picker(strings.languageLabel, selection: $bindable.language) {
                ForEach(AppLanguage.allCases) { language in
                    Text("\(language.flag)  \(language.displayName)").tag(language)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }

    // MARK: - Widget

    private var widgetCard: some View {
        AppSettingsCard(
            title: strings.settingsWidgetSection,
            systemImage: "square.grid.2x2.fill",
            tint: Palette.teal
        ) {
            Text(strings.settingsWidgetHint)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Titled container matching the per-profile settings cards.
private struct AppSettingsCard<Content: View>: View {
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
    AppSettingsView()
        .environment(AppSettings())
        .environment(BiometricGate.shared)
        .environment(KudaoIdentity.shared)
        .environment(CollaborationService())
        .environment(CloudBackupService())
        .environment(NotificationService.shared)
        .modelContainer(KudaoModelContainer.preview())
}
