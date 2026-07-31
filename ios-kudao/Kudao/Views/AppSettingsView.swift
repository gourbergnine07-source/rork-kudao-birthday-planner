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

    @State private var isJoining: Bool = false

    private var strings: Strings { settings.strings }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 18) {
                        collaborationCard
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

    // MARK: - Surprise mode

    private var surpriseCard: some View {
        @Bindable var bindable = settings
        let kind = gate.biometryKind

        return AppSettingsCard(
            title: strings.settingsSurpriseSection,
            systemImage: "eye.slash.fill",
            tint: Palette.berry
        ) {
            Toggle(isOn: $bindable.protectsSurpriseProfiles) {
                HStack(spacing: 8) {
                    Image(systemName: kind.symbolName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.berry)
                    Text(strings.faceIDToggleTitle)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .tint(Palette.berry)

            Text(strings.faceIDToggleDescription)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if settings.protectsSurpriseProfiles && !kind.isBiometric {
                Label(strings.biometryUnavailableNote, systemImage: "info.circle.fill")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(Palette.amber)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider().overlay(Palette.hairline)

            Toggle(isOn: $bindable.hidesSurpriseNotificationPreviews) {
                HStack(spacing: 8) {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.berry)
                    Text(strings.hidePreviewsToggleTitle)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .tint(Palette.berry)

            Text(strings.hidePreviewsToggleDescription)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if settings.hidesSurpriseNotificationPreviews {
                previewSample
            }

            Divider().overlay(Palette.hairline)

            Label(strings.settingsSharingNote, systemImage: "hand.raised.fill")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(strings.settingsSurpriseFooter)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
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
        .modelContainer(KudaoModelContainer.preview())
}
