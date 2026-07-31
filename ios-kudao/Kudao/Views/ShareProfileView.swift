//
//  ShareProfileView.swift
//  Kudao
//

import SwiftUI
import SwiftData
import UIKit

/// Creates an invite code for one profile, choosing the permission first.
struct ShareProfileView: View {
    let profile: BirthdayProfile

    @Environment(AppSettings.self) private var settings
    @Environment(KudaoIdentity.self) private var identity
    @Environment(CollaborationService.self) private var collaboration
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var permission: SharePermission = .edit
    @State private var name: String = ""
    @State private var code: String?
    @State private var isWorking: Bool = false
    @State private var didCopy: Bool = false
    @State private var isSharingInvite: Bool = false

    private var strings: Strings { settings.strings }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 18) {
                        headerCard

                        if let code {
                            inviteCard(code)
                        } else {
                            nameCard
                            permissionCard
                            generateButton
                        }

                        if let message = collaboration.errorMessage {
                            errorBanner(message)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(strings.shareProfileTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(strings.doneAction) { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
            .sheet(isPresented: $isSharingInvite) {
                if let code {
                    ShareSheet(text: inviteMessage(code))
                }
            }
        }
        .tint(Palette.coral)
        .environment(\.locale, settings.locale)
        .onAppear {
            name = identity.displayName
            collaboration.clearError()
        }
    }

    // MARK: - Cards

    private var headerCard: some View {
        VStack(spacing: 12) {
            AvatarView(name: profile.name, photoData: profile.photoData, size: 74)

            VStack(spacing: 4) {
                Text(profile.fullName)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text(String(format: strings.shareProfileSubtitleFormat, profile.name))
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }

    private var nameCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(strings.yourNameLabel.uppercased())
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .tracking(1)
                .foregroundStyle(.secondary)

            TextField(strings.yourNamePlaceholder, text: $name)
                .font(.system(.body, design: .rounded, weight: .medium))
                .textInputAutocapitalization(.words)
                .textContentType(.givenName)
                .submitLabel(.done)

            Text(strings.yourNameCaption)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Palette.surface))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))
    }

    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(strings.permissionSectionTitle.uppercased())
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .tracking(1)
                .foregroundStyle(.secondary)

            ForEach(SharePermission.allCases) { option in
                permissionRow(option)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Palette.surface))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))
    }

    private func permissionRow(_ option: SharePermission) -> some View {
        let isSelected = option == permission

        return Button {
            permission = option
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(option.accent.opacity(isSelected ? 0.18 : 0.1))
                        .frame(width: 38, height: 38)
                    Image(systemName: option.symbolName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(option.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title(strings))
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(option.caption(strings))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(isSelected ? option.accent : Color.secondary.opacity(0.4))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? option.accent.opacity(0.08) : Palette.surfaceRaised.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(isSelected ? option.accent.opacity(0.45) : Palette.hairline, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    private var generateButton: some View {
        Button {
            generate()
        } label: {
            HStack(spacing: 9) {
                if isWorking {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 15, weight: .bold))
                }
                Text(strings.generateInviteAction)
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Capsule().fill(Palette.warmGradient))
            .shadow(color: Palette.coral.opacity(0.32), radius: 14, y: 8)
        }
        .buttonStyle(PressableCardStyle())
        .disabled(isWorking || trimmedName.isEmpty)
        .opacity(isWorking || trimmedName.isEmpty ? 0.6 : 1)
    }

    private func inviteCard(_ code: String) -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Palette.teal)
                Text(strings.inviteReadyTitle)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Text(permission.caption(strings))
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                Text(strings.inviteCodeLabel.uppercased())
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                Text(code)
                    .font(.system(size: 34, weight: .heavy, design: .monospaced))
                    .tracking(6)
                    .foregroundStyle(Palette.coral)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Palette.coral.opacity(0.1)))

            Text(strings.inviteHint)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button {
                    UIPasteboard.general.string = code
                    didCopy = true
                } label: {
                    Label(
                        didCopy ? strings.copiedLabel : strings.copyCodeAction,
                        systemImage: didCopy ? "checkmark" : "doc.on.doc"
                    )
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Palette.coral)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Capsule().fill(Palette.coral.opacity(0.12)))
                }
                .buttonStyle(PressableCardStyle())

                Button {
                    isSharingInvite = true
                } label: {
                    Label(strings.shareInviteAction, systemImage: "square.and.arrow.up")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(Palette.warmGradient))
                }
                .buttonStyle(PressableCardStyle())
            }

            Button {
                self.code = nil
                didCopy = false
            } label: {
                Text(strings.newInviteAction)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Palette.surface))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 6)
        .sensoryFeedback(.success, trigger: code)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.berry)
            Text(message)
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.berry.opacity(0.1)))
    }

    // MARK: - Actions

    private func inviteMessage(_ code: String) -> String {
        String(format: strings.inviteMessageFormat, profile.name, code)
    }

    private func generate() {
        guard !isWorking else { return }
        identity.displayName = trimmedName
        isWorking = true

        Task {
            let generated = await collaboration.createInvite(
                for: profile,
                permission: permission,
                identity: identity,
                strings: strings,
                context: modelContext
            )
            isWorking = false
            didCopy = false
            code = generated
        }
    }
}
