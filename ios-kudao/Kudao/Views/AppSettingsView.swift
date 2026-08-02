//
//  AppSettingsView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// App-wide settings: notifications, sharing, backup, surprise-mode protections
/// and widget hint. Language lives in the globe menu on Home.
struct AppSettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(BiometricGate.self) private var gate
    @Environment(KudaoIdentity.self) private var identity
    @Environment(\.dismiss) private var dismiss

    @Environment(CloudBackupService.self) private var backup
    @Environment(SubscriptionService.self) private var subscriptions
    @Environment(AdsService.self) private var ads

    @State private var isShowingPaywall: Bool = false
    @State private var isJoining: Bool = false
    #if DEBUG
    @State private var isShowingPurchaseDebug: Bool = false
    #endif
    @State private var isManagingBackup: Bool = false
    @State private var isShowingMyProfile: Bool = false
    @State private var isEditingNotifications: Bool = false
    @State private var isShowingPrivacyInfo: Bool = false
    @State private var isShowingLegal: Bool = false
    @State private var isShowingFAQ: Bool = false

    private var strings: Strings { settings.strings }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 18) {
                        premiumCard
                        notificationsCard
                        collaborationCard
                        backupCard
                        surpriseCard
                        faqCard
                        privacyInfoCard
                        legalCard
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
            .sheet(isPresented: $isShowingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $isManagingBackup) {
                CloudBackupView()
            }
            .sheet(isPresented: $isShowingMyProfile) {
                MyProfileView()
            }
            .sheet(isPresented: $isEditingNotifications) {
                NotificationSettingsView()
            }
            .sheet(isPresented: $isShowingPrivacyInfo) {
                PrivacyInfoView()
            }
            .sheet(isPresented: $isShowingLegal) {
                LegalView()
            }
            .sheet(isPresented: $isShowingFAQ) {
                FAQView()
            }
            #if DEBUG
            .sheet(isPresented: $isShowingPurchaseDebug) {
                SubscriptionDebugView()
            }
            #endif
        }
        .tint(Palette.coral)
    }

    // MARK: - Premium

    /// Subscription status, the way into the paywall, and — only where European
    /// rules require it — the switch that reopens the ad consent choices.
    private var premiumCard: some View {
        AppSettingsCard(
            title: strings.premiumSettingsTitle,
            systemImage: subscriptions.isPremium ? "checkmark.seal.fill" : "sparkles",
            tint: Palette.berry
        ) {
            Text(subscriptions.isPremium ? strings.premiumActiveCaption : strings.premiumInactiveCaption)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                isShowingPaywall = true
            } label: {
                HStack(spacing: 8) {
                    Text(subscriptions.isPremium ? strings.premiumManageAction : strings.paywallSubscribeAction)
                        .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .heavy))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .background(Capsule().fill(Palette.vowGradient))
            }
            .buttonStyle(PressableCardStyle())

            if ads.isPrivacyOptionsRequired && !subscriptions.isPremium {
                Divider().overlay(Palette.hairline)

                Button {
                    Task { await ads.presentPrivacyOptions() }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Palette.clay)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(strings.adsPrivacyOptionsTitle)
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text(strings.adsPrivacyOptionsCaption)
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

            #if DEBUG
            Divider().overlay(Palette.hairline)

            Button {
                isShowingPurchaseDebug = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "ladybug.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.violet)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Purchase debug")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text("Developer build only")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.tertiary)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            #endif
        }
    }

    // MARK: - Notifications

    /// Lead times per category of occasion, summarised as pills.
    private var notificationsCard: some View {
        AppSettingsCard(
            title: strings.notificationSettingsMenuTitle,
            systemImage: "bell.badge.fill",
            tint: Palette.coral
        ) {
            Button {
                isEditingNotifications = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.coral)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(strings.notificationSettingsMenuTitle)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text(strings.notificationSettingsCaption)
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

            HStack(spacing: 6) {
                ForEach(OccasionKind.allCases) { occasion in
                    leadTimePill(occasion)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func leadTimePill(_ occasion: OccasionKind) -> some View {
        let days = settings.reminderDays(for: occasion)
        let label = days == 0
            ? strings.reminderOnTheDayLabel
            : String(format: days == 1 ? strings.dayBeforeFormat : strings.daysBeforeFormat, days)

        return HStack(spacing: 4) {
            Image(systemName: occasion.symbolName)
                .font(.system(size: 9, weight: .bold))
            Text(days == 0 ? "0" : "\(days)")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(occasion.accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Capsule().fill(occasion.accent.opacity(0.12)))
        .accessibilityLabel("\(occasion.title(strings)) \(label)")
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

    // MARK: - Frequently asked questions

    /// The help desk, one tap away from wherever the confusion started.
    private var faqCard: some View {
        AppSettingsCard(
            title: strings.faqTitle,
            systemImage: "questionmark.circle.fill",
            tint: Palette.amber
        ) {
            Button {
                isShowingFAQ = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "questionmark.bubble.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.amber)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(strings.faqTitle)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text(strings.faqCaption)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.tertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Text(String(format: strings.faqCountFormat, FAQCatalog.count(for: settings.language)))
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(Palette.amber)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Palette.amber.opacity(0.13)))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Privacy information

    /// Where everything written in Kudao actually ends up, in plain language.
    private var privacyInfoCard: some View {
        AppSettingsCard(
            title: strings.privacyInfoTitle,
            systemImage: "lock.shield.fill",
            tint: Palette.clay
        ) {
            Button {
                isShowingPrivacyInfo = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.clay)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(strings.privacyInfoTitle)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text(strings.privacyInfoCaption)
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

    // MARK: - Legal

    /// The published policy, terms and support pages, reachable without an account.
    private var legalCard: some View {
        AppSettingsCard(
            title: strings.legalTitle,
            systemImage: "checkmark.seal.fill",
            tint: Palette.violet
        ) {
            Button {
                isShowingLegal = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "doc.on.doc.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.violet)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(strings.legalTitle)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text(strings.legalCaption)
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
        .environment(SubscriptionService())
        .environment(AdsService())
        .modelContainer(KudaoModelContainer.preview())
}
