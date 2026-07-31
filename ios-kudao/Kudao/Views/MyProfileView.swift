//
//  MyProfileView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// The personal space of whoever uses Kudao — not a celebration profile.
///
/// It holds the avatar and name other participants see in shared rooms, the
/// reminder preferences new profiles inherit, the surprise-mode privacy
/// switches, the account state and the app information.
struct MyProfileView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(KudaoIdentity.self) private var identity
    @Environment(BiometricGate.self) private var gate
    @Environment(CloudBackupService.self) private var backup
    @Environment(AuthService.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var isManagingBackup: Bool = false
    @State private var isManagingAccount: Bool = false
    @State private var isEditingNotifications: Bool = false
    @State private var isConfirmingSignOut: Bool = false

    private var strings: Strings { settings.strings }

    /// "1.0 (3)" — what a support message needs to be useful.
    private var versionLabel: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 18) {
                        heroCard
                        remindersCard
                        privacyCard
                        accountCard
                        aboutCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 36)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle(strings.myProfileTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(strings.doneAction) { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
            .environment(\.locale, settings.locale)
            .sheet(isPresented: $isManagingBackup) {
                CloudBackupView()
            }
            .sheet(isPresented: $isManagingAccount) {
                AccountView()
            }
            .sheet(isPresented: $isEditingNotifications) {
                NotificationSettingsView()
            }
            .alert(strings.accountSignOutTitle, isPresented: $isConfirmingSignOut) {
                Button(strings.cancelAction, role: .cancel) {}
                Button(strings.accountSignOutAction, role: .destructive) {
                    signOut()
                }
            } message: {
                Text(strings.accountSignOutMessage)
            }
        }
        .tint(Palette.coral)
    }

    // MARK: - Identity

    private var heroCard: some View {
        @Bindable var bindableIdentity = identity

        return VStack(spacing: 14) {
            PhotoSourcePicker(
                onPicked: { data in
                    withAnimation(.smooth(duration: 0.25)) { identity.photoData = data }
                },
                onRemoved: identity.photoData == nil ? nil : { identity.photoData = nil }
            ) {
                ZStack(alignment: .bottomTrailing) {
                    AvatarView(
                        name: identity.hasName ? identity.trimmedName : "?",
                        photoData: identity.photoData,
                        size: 104,
                        ringColor: Palette.surface,
                        ringWidth: 4
                    )

                    Image(systemName: "camera.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Palette.warmGradient))
                        .overlay(Circle().strokeBorder(Palette.surface, lineWidth: 3))
                }
            }
            .buttonStyle(PressableCardStyle())

            VStack(spacing: 8) {
                TextField(strings.yourNamePlaceholder, text: $bindableIdentity.displayName)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.words)
                    .textContentType(.givenName)
                    .submitLabel(.done)

                Text(strings.myProfileSubtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .shadow(color: Palette.coral.opacity(0.1), radius: 14, y: 7)
    }

    // MARK: - Reminder defaults

    private var remindersCard: some View {
        @Bindable var bindable = settings

        return MyProfileCard(
            title: strings.notificationDefaultsTitle,
            systemImage: "bell.badge.fill",
            tint: Palette.coral
        ) {
            Text(strings.notificationDefaultsCaption)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider().overlay(Palette.hairline)

            Button {
                isEditingNotifications = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Palette.coral)
                        .frame(width: 22)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(strings.notificationSettingsMenuTitle)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)

                        HStack(spacing: 5) {
                            ForEach(OccasionKind.allCases) { occasion in
                                leadTimeChip(occasion)
                            }
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider().overlay(Palette.hairline)

            HStack(spacing: 10) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Palette.coral)
                    .frame(width: 22)

                Text(strings.defaultReminderTimeLabel)
                    .font(.system(.body, design: .rounded, weight: .semibold))

                Spacer(minLength: 0)

                DatePicker(
                    strings.defaultReminderTimeLabel,
                    selection: $bindable.reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .tint(Palette.coral)
            }

            Label(strings.defaultsAppliedNote, systemImage: "info.circle.fill")
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Compact "🎂 7" pill summarising a category's lead time.
    private func leadTimeChip(_ occasion: OccasionKind) -> some View {
        let days = settings.reminderDays(for: occasion)

        return HStack(spacing: 3) {
            Image(systemName: occasion.symbolName)
                .font(.system(size: 9, weight: .bold))
            Text(days == 0 ? "0" : "\(days)")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .contentTransition(.numericText())
        }
        .foregroundStyle(occasion.accent)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(Capsule().fill(occasion.accent.opacity(0.12)))
        .accessibilityLabel("\(occasion.title(strings)) \(daysLabel(days))")
    }

    private func defaultStepper(
        title: String,
        icon: String,
        value: Binding<Int>,
        range: ClosedRange<Int>
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Palette.coral)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text(daysLabel(value.wrappedValue))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            Spacer(minLength: 0)

            Stepper(title, value: value, in: range)
                .labelsHidden()
                .tint(Palette.coral)
        }
        .animation(.smooth(duration: 0.2), value: value.wrappedValue)
    }

    private func daysLabel(_ value: Int) -> String {
        guard value > 0 else { return strings.reminderOnTheDayLabel }
        return String(format: value == 1 ? strings.dayBeforeFormat : strings.daysBeforeFormat, value)
    }

    // MARK: - Privacy

    private var privacyCard: some View {
        @Bindable var bindable = settings
        let kind = gate.biometryKind

        return MyProfileCard(
            title: strings.privacySectionTitle,
            systemImage: "lock.shield.fill",
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

            Text(strings.settingsSurpriseFooter)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Account

    private var accountCard: some View {
        MyProfileCard(
            title: strings.accountSectionTitle,
            systemImage: "person.badge.key.fill",
            tint: Palette.teal
        ) {
            Button {
                isManagingAccount = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: auth.isSignedIn
                        ? "checkmark.seal.fill"
                        : "envelope.badge.shield.half.filled")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.teal)
                        .frame(width: 22)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(auth.isSignedIn ? auth.email : strings.accountSignInTitle)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text(auth.isSignedIn ? strings.accountSignedInCaption : strings.accountSignInCaption)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
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

            Divider().overlay(Palette.hairline)

            Button {
                isManagingBackup = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: backup.isEnabled ? "checkmark.icloud.fill" : "icloud.slash.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(backup.isEnabled ? Palette.teal : Color.secondary)
                        .frame(width: 22)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(backup.isEnabled ? strings.cloudOnLabel : strings.cloudOffLabel)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text(backup.isEnabled ? strings.accountVaultCaption : strings.cloudOffCaption)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
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

            if backup.isEnabled {
                Divider().overlay(Palette.hairline)

                Button(role: .destructive) {
                    isConfirmingSignOut = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(width: 22)
                        Text(strings.accountSignOutAction)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(Palette.berry)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func signOut() {
        let strings = self.strings
        Task {
            await backup.disable(deleteRemoteCopy: false, strings: strings)
        }
    }

    // MARK: - About

    private var aboutCard: some View {
        MyProfileCard(
            title: strings.appInfoTitle,
            systemImage: "info.circle.fill",
            tint: Palette.violet
        ) {
            HStack(spacing: 10) {
                Image(systemName: "app.badge.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.violet)
                    .frame(width: 22)
                Text(strings.appVersionLabel)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Spacer(minLength: 0)
                Text(versionLabel)
                    .font(.system(.footnote, design: .rounded, weight: .semibold).monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Divider().overlay(Palette.hairline)

            Button {
                openSupportMail()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "lifepreserver.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Palette.violet)
                        .frame(width: 22)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(strings.appSupportAction)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text(Self.supportAddress)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text(strings.appSupportCaption)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Address support messages are sent to.
    private static let supportAddress = "supporto@kudao.app"

    private func openSupportMail() {
        let subject = "Kudao \(versionLabel)"
        let encoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Kudao"
        guard let url = URL(string: "mailto:\(Self.supportAddress)?subject=\(encoded)") else { return }
        openURL(url)
    }
}

/// Titled container matching the rest of the settings surfaces.
private struct MyProfileCard<Content: View>: View {
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
    MyProfileView()
        .environment(AppSettings())
        .environment(KudaoIdentity.shared)
        .environment(BiometricGate.shared)
        .environment(CloudBackupService())
        .environment(AuthService())
        .modelContainer(KudaoModelContainer.preview())
}
