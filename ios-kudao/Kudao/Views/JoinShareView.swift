//
//  JoinShareView.swift
//  Kudao
//

import SwiftUI
import SwiftData
import UIKit

/// Joins a profile somebody else shared, using the 6-character invite code.
struct JoinShareView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(KudaoIdentity.self) private var identity
    @Environment(CollaborationService.self) private var collaboration
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var code: String = ""
    @State private var name: String = ""
    @State private var isWorking: Bool = false
    @State private var joinedName: String?
    @FocusState private var isCodeFocused: Bool

    private static let codeLength = 6

    private var strings: Strings { settings.strings }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canJoin: Bool {
        code.count == Self.codeLength && !trimmedName.isEmpty && !isWorking
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 18) {
                        header

                        if let joinedName {
                            successCard(joinedName)
                        } else {
                            codeCard
                            nameCard
                            joinButton

                            if let message = collaboration.errorMessage {
                                errorBanner(message)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(strings.joinShareTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(joinedName == nil ? strings.cancelAction : strings.doneAction) { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
        }
        .tint(Palette.coral)
        .environment(\.locale, settings.locale)
        .onAppear {
            name = identity.displayName
            collaboration.clearError()
            prefillFromClipboard()
            isCodeFocused = true
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Palette.violet.opacity(0.14))
                    .frame(width: 74, height: 74)
                Image(systemName: "person.2.badge.key.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Palette.violet)
            }
            Text(strings.joinShareSubtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 14)
    }

    private var codeCard: some View {
        VStack(spacing: 12) {
            TextField(strings.joinCodePlaceholder, text: $code)
                .font(.system(size: 30, weight: .heavy, design: .monospaced))
                .tracking(6)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
                .focused($isCodeFocused)
                .submitLabel(.go)
                .onSubmit { join() }
                .onChange(of: code) { _, newValue in
                    let filtered = newValue
                        .uppercased()
                        .filter { $0.isLetter || $0.isNumber }
                    code = String(filtered.prefix(Self.codeLength))
                }

            Button {
                prefillFromClipboard(force: true)
            } label: {
                Label(strings.pasteCodeAction, systemImage: "doc.on.clipboard")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Palette.coral)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Palette.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(isCodeFocused ? Palette.coral.opacity(0.5) : Palette.hairline, lineWidth: 1)
        )
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

            Text(strings.yourNameCaption)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Palette.surface))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))
    }

    private var joinButton: some View {
        Button {
            join()
        } label: {
            HStack(spacing: 9) {
                if isWorking {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                }
                Text(strings.joinAction)
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Capsule().fill(Palette.warmGradient))
            .shadow(color: Palette.coral.opacity(0.3), radius: 14, y: 8)
        }
        .buttonStyle(PressableCardStyle())
        .disabled(!canJoin)
        .opacity(canJoin ? 1 : 0.6)
    }

    private func successCard(_ profileName: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Palette.teal)
            Text(String(format: strings.joinSuccessFormat, profileName))
                .font(.system(.headline, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
            Text(strings.joinSuccessCaption)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text(strings.doneAction)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Palette.warmGradient))
            }
            .buttonStyle(PressableCardStyle())
            .padding(.top, 4)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Palette.surface))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))
        .sensoryFeedback(.success, trigger: joinedName)
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

    /// Invite codes usually arrive through a message, so the clipboard is a good guess.
    private func prefillFromClipboard(force: Bool = false) {
        guard code.isEmpty || force else { return }
        guard let pasted = UIPasteboard.general.string else { return }

        let candidate = pasted
            .uppercased()
            .filter { $0.isLetter || $0.isNumber }

        guard candidate.count >= Self.codeLength else { return }
        code = String(candidate.prefix(Self.codeLength))
    }

    private func join() {
        guard canJoin else { return }
        identity.displayName = trimmedName
        isWorking = true

        Task {
            let profile = await collaboration.join(
                code: code,
                identity: identity,
                strings: strings,
                context: modelContext
            )
            isWorking = false
            if let profile {
                joinedName = profile.name
                isCodeFocused = false
            }
        }
    }
}
