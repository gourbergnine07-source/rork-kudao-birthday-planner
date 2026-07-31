//
//  CloudBackupView.swift
//  Kudao
//

import SwiftUI
import SwiftData
import UIKit

/// Turns the cloud copy on, shows the recovery code and restores it elsewhere.
struct CloudBackupView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(CloudBackupService.self) private var backup
    @Environment(NotificationService.self) private var notifications
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \BirthdayProfile.createdAt) private var profiles: [BirthdayProfile]

    @State private var typedCode: String = ""
    @State private var isRestoring: Bool = false
    @State private var isConfirmingDisable: Bool = false
    @State private var didCopy: Bool = false
    @State private var banner: String?

    private var strings: Strings { settings.strings }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 18) {
                        statusCard

                        if backup.isEnabled {
                            codeCard
                            actionsCard
                        } else {
                            enableCard
                            restoreCard
                        }

                        privacyNote
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(strings.cloudManageTitle)
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
        .confirmationDialog(
            strings.cloudDisableTitle,
            isPresented: $isConfirmingDisable,
            titleVisibility: .visible
        ) {
            Button(strings.cloudDisableAction) { disable(deleteRemote: false) }
            Button(strings.cloudDeleteRemoteAction, role: .destructive) { disable(deleteRemote: true) }
            Button(strings.cancelAction, role: .cancel) {}
        } message: {
            Text(strings.cloudDisableMessage)
        }
    }

    // MARK: - Status

    private var statusCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(backup.isEnabled ? Palette.teal.opacity(0.16) : Palette.hairline.opacity(0.6))
                    .frame(width: 76, height: 76)

                Image(systemName: backup.isEnabled ? "checkmark.icloud.fill" : "icloud.slash.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(backup.isEnabled ? Palette.teal : Color.secondary)
                    .symbolEffect(.bounce, value: backup.isEnabled)
            }

            Text(backup.isEnabled ? strings.cloudOnLabel : strings.cloudOffLabel)
                .font(.system(.title3, design: .rounded, weight: .bold))

            Text(syncSummary)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let banner {
                Label(banner, systemImage: "sparkles")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Palette.teal)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if let error = backup.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Palette.berry)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .animation(.smooth(duration: 0.3), value: banner)
    }

    private var syncSummary: String {
        guard backup.isEnabled else { return strings.cloudOffCaption }
        guard let last = backup.lastSyncedAt else { return strings.cloudNeverSynced }
        return String(format: strings.cloudLastSyncFormat, settings.noteTimestamp(last))
    }

    // MARK: - Recovery code

    private var codeCard: some View {
        BackupCard(title: strings.cloudCodeLabel, systemImage: "key.fill", tint: Palette.amber) {
            Text(backup.formattedCode)
                .font(.system(.title2, design: .monospaced, weight: .bold))
                .kerning(2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Palette.surfaceRaised)
                )
                .textSelection(.enabled)

            Button {
                UIPasteboard.general.string = backup.formattedCode
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                withAnimation(.smooth(duration: 0.25)) { didCopy = true }
            } label: {
                Label(
                    didCopy ? strings.cloudCopiedLabel : strings.cloudCopyAction,
                    systemImage: didCopy ? "checkmark.circle.fill" : "doc.on.doc.fill"
                )
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Palette.amber.opacity(0.16))
                )
                .foregroundStyle(Palette.amber)
            }
            .buttonStyle(PressableCardStyle())

            Text(strings.cloudCodeCaption)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Actions

    private var actionsCard: some View {
        BackupCard(title: strings.cloudActionsTitle, systemImage: "arrow.triangle.2.circlepath", tint: Palette.teal) {
            Button {
                Task { await runSync() }
            } label: {
                HStack(spacing: 9) {
                    if backup.isWorking {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .bold))
                    }
                    Text(strings.cloudSyncNowAction)
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(Palette.warmGradient)
                )
            }
            .buttonStyle(PressableCardStyle())
            .disabled(backup.isWorking)

            Button(role: .destructive) {
                isConfirmingDisable = true
            } label: {
                Text(strings.cloudDisableAction)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .disabled(backup.isWorking)
        }
    }

    // MARK: - Off state

    private var enableCard: some View {
        BackupCard(title: strings.cloudEnableTitle, systemImage: "icloud.and.arrow.up.fill", tint: Palette.coral) {
            Text(strings.cloudEnableCaption)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task { await enable() }
            } label: {
                HStack(spacing: 9) {
                    if backup.isWorking && !isRestoring {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .bold))
                    }
                    Text(strings.cloudEnableAction)
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(Palette.warmGradient)
                )
            }
            .buttonStyle(PressableCardStyle())
            .disabled(backup.isWorking || !backup.isAvailable)
        }
    }

    private var restoreCard: some View {
        BackupCard(title: strings.cloudRestoreTitle, systemImage: "arrow.down.circle.fill", tint: Palette.violet) {
            Text(strings.cloudRestoreHint)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            TextField(strings.cloudRestorePlaceholder, text: $typedCode)
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Palette.surfaceRaised)
                )

            Button {
                Task { await restore() }
            } label: {
                HStack(spacing: 9) {
                    if backup.isWorking && isRestoring {
                        ProgressView().tint(Palette.violet)
                    }
                    Text(strings.cloudRestoreAction)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Palette.violet.opacity(0.16))
                )
                .foregroundStyle(Palette.violet)
            }
            .buttonStyle(PressableCardStyle())
            .disabled(backup.isWorking || !CloudVaultCode.isValid(typedCode))
        }
    }

    private var privacyNote: some View {
        Label(strings.cloudPrivacyNote, systemImage: "lock.shield.fill")
            .font(.system(.caption, design: .rounded))
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    // MARK: - Operations

    private func enable() async {
        didCopy = false
        await backup.enable(strings: strings, context: modelContext)
        guard backup.isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        show(strings.cloudBackedUpBanner)
        await refreshDerivedState()
    }

    private func restore() async {
        isRestoring = true
        let done = await backup.restore(rawCode: typedCode, strings: strings, context: modelContext)
        isRestoring = false

        guard done else { return }
        typedCode = ""
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        show(restoreSummary)
        await refreshDerivedState()
    }

    private func runSync() async {
        await backup.sync(strings: strings, context: modelContext)
        guard backup.errorMessage == nil else { return }
        show(restoreSummary)
        await refreshDerivedState()
    }

    private func disable(deleteRemote: Bool) {
        Task {
            await backup.disable(deleteRemoteCopy: deleteRemote, strings: strings)
            didCopy = false
        }
    }

    private var restoreSummary: String {
        backup.lastRestoredCount > 0
            ? String(format: strings.cloudRestoredFormat, backup.lastRestoredCount)
            : strings.cloudBackedUpBanner
    }

    /// Restored profiles need their reminders and the widget rebuilt.
    private func refreshDerivedState() async {
        let privacy = ReminderPrivacy(hidesSurprisePreviews: settings.hidesSurpriseNotificationPreviews)
        let diary = DiaryNudgePlan.make(settings: settings, profiles: profiles)
        await notifications.sync(profiles: profiles, strings: strings, privacy: privacy, diary: diary)
        WidgetBridge.publish(profiles: profiles, settings: settings)
    }

    private func show(_ text: String) {
        banner = text
        Task {
            try? await Task.sleep(for: .seconds(4))
            if banner == text { banner = nil }
        }
    }
}

/// Titled container matching the other settings cards.
private struct BackupCard<Content: View>: View {
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
    CloudBackupView()
        .environment(AppSettings())
        .environment(CloudBackupService())
        .environment(NotificationService.shared)
        .modelContainer(KudaoModelContainer.preview())
}
