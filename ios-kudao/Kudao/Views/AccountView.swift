//
//  AccountView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Email sign-in for Kudao.
///
/// The account is deliberately optional: everything in the app works without
/// it. What it buys is a second way back to your notes — sign in on a new phone
/// and the backup comes down, even if the recovery code is long gone.
struct AccountView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(AuthService.self) private var auth
    @Environment(CloudBackupService.self) private var backup
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var step: AuthStep = .signIn
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var didSucceed: Bool = false
    @State private var restoredCount: Int?

    @FocusState private var focus: Field?

    private enum Field: Hashable {
        case email
        case password
    }

    private var strings: Strings { settings.strings }

    private var canSubmit: Bool {
        AuthService.isValidEmail(email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
            && password.count >= (step == .signUp ? AuthService.minimumPasswordLength : 1)
            && !auth.isWorking
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 20) {
                        if auth.isSignedIn {
                            signedInContent
                        } else {
                            signedOutContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(strings.accountSectionTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(strings.doneAction) { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
            .environment(\.locale, settings.locale)
            .sensoryFeedback(.success, trigger: didSucceed)
            .animation(.smooth(duration: 0.3), value: auth.isSignedIn)
            .animation(.smooth(duration: 0.25), value: step)
        }
        .tint(Palette.coral)
        .onDisappear { auth.clearError() }
    }

    // MARK: - Signed out

    private var signedOutContent: some View {
        VStack(spacing: 20) {
            hero

            if let email = auth.pendingConfirmationEmail {
                confirmationPanel(email)
            }

            AccountCard {
                Picker(strings.accountSectionTitle, selection: $step) {
                    Text(strings.authSignInTab).tag(AuthStep.signIn)
                    Text(strings.authSignUpTab).tag(AuthStep.signUp)
                }
                .pickerStyle(.segmented)
                .onChange(of: step) { _, _ in
                    auth.clearError()
                    auth.clearNotices()
                }

                field(
                    icon: "envelope.fill",
                    placeholder: strings.authEmailPlaceholder,
                    text: $email,
                    isSecure: false,
                    field: .email
                )

                Divider().overlay(Palette.hairline)

                field(
                    icon: "lock.fill",
                    placeholder: strings.authPasswordPlaceholder,
                    text: $password,
                    isSecure: !isPasswordVisible,
                    field: .password
                )

                if step == .signUp {
                    Text(String(format: strings.authPasswordHintFormat, AuthService.minimumPasswordLength))
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }

            if let error = auth.errorMessage {
                errorBanner(error)
            }

            if auth.didSendPasswordReset {
                noticeBanner(strings.authResetSentMessage, icon: "paperplane.fill", tint: Palette.teal)
            }

            submitButton

            if step == .signIn {
                Button {
                    Task { await auth.sendPasswordReset(email: email, strings: strings) }
                } label: {
                    Text(strings.authForgotPasswordAction)
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                        .foregroundStyle(Palette.coral)
                }
                .disabled(auth.isWorking)
            }

            optionalNote
        }
    }

    private var hero: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Palette.warmGradient)
                    .frame(width: 78, height: 78)
                    .shadow(color: Palette.coral.opacity(0.32), radius: 16, y: 8)
                Image(systemName: "envelope.badge.shield.half.filled")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
            }

            Text(step == .signUp ? strings.authSignUpTitle : strings.authSignInTitle)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)

            Text(step == .signUp ? strings.authSignUpSubtitle : strings.authSignInSubtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    private func field(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool,
        field target: Field
    ) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.coral)
                .frame(width: 22)

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else if target == .password {
                    TextField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }
            }
            .font(.system(.body, design: .rounded, weight: .medium))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focus, equals: target)
            .submitLabel(target == .email ? .next : .go)
            .onSubmit {
                if target == .email {
                    focus = .password
                } else {
                    submit()
                }
            }

            if target == .password {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(strings.authPasswordPlaceholder)
            }
        }
    }

    private var submitButton: some View {
        Button {
            submit()
        } label: {
            HStack(spacing: 9) {
                if auth.isWorking {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Image(systemName: step == .signUp ? "person.badge.plus" : "arrow.right.to.line")
                        .font(.system(size: 15, weight: .bold))
                }
                Text(step == .signUp ? strings.authSignUpAction : strings.authSignInAction)
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Capsule().fill(
                    canSubmit ? AnyShapeStyle(Palette.warmGradient) : AnyShapeStyle(Color.gray.opacity(0.35))
                )
            )
            .shadow(color: canSubmit ? Palette.coral.opacity(0.32) : .clear, radius: 14, y: 8)
        }
        .buttonStyle(PressableCardStyle())
        .disabled(!canSubmit)
    }

    private var optionalNote: some View {
        Label(strings.authOptionalNote, systemImage: "info.circle.fill")
            .font(.system(.caption, design: .rounded))
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 4)
    }

    // MARK: - Signed in

    private var signedInContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Palette.teal.opacity(0.16))
                        .frame(width: 78, height: 78)
                    Text(auth.initial)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Palette.teal)
                }

                Text(auth.email)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)

                KudaoChip(
                    title: strings.authSignedInBadge,
                    systemImage: "checkmark.seal.fill",
                    tint: Palette.teal
                )
            }
            .padding(.top, 8)

            AccountCard {
                HStack(spacing: 10) {
                    Image(systemName: backup.isEnabled ? "checkmark.icloud.fill" : "icloud.slash.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(backup.isEnabled ? Palette.teal : Color.secondary)
                        .frame(width: 22)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(backup.isEnabled ? strings.authVaultLinkedTitle : strings.authVaultMissingTitle)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                        Text(backup.isEnabled ? strings.authVaultLinkedCaption : strings.authVaultMissingCaption)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                if let restoredCount, restoredCount > 0 {
                    Divider().overlay(Palette.hairline)
                    Label(
                        String(format: strings.authRestoredFormat, restoredCount),
                        systemImage: "arrow.down.circle.fill"
                    )
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                    .foregroundStyle(Palette.teal)
                }
            }

            if let error = auth.errorMessage {
                errorBanner(error)
            }

            Button(role: .destructive) {
                Task {
                    await auth.signOut(strings: strings)
                    backup.forgetAccountLink()
                    restoredCount = nil
                }
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 15, weight: .bold))
                    Text(strings.authSignOutAction)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(Palette.berry)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Capsule().fill(Palette.berry.opacity(0.12)))
                .overlay(Capsule().strokeBorder(Palette.berry.opacity(0.32), lineWidth: 1))
            }
            .buttonStyle(PressableCardStyle())
            .disabled(auth.isWorking)

            Label(strings.authSignOutNote, systemImage: "info.circle.fill")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
        }
    }

    // MARK: - Banners

    private func confirmationPanel(_ address: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(strings.authConfirmTitle, systemImage: "envelope.open.fill")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(Palette.amber)

            Text(String(format: strings.authConfirmMessageFormat, address))
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task { await auth.resendConfirmation(strings: strings) }
            } label: {
                Text(strings.authResendAction)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(Palette.amber)
            }
            .disabled(auth.isWorking)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Palette.amber.opacity(0.12)))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.amber.opacity(0.35), lineWidth: 1)
        )
    }

    private func errorBanner(_ text: String) -> some View {
        noticeBanner(text, icon: "exclamationmark.triangle.fill", tint: Palette.berry)
    }

    private func noticeBanner(_ text: String, icon: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(tint)
            Text(text)
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(tint.opacity(0.12)))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(tint.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Actions

    private func submit() {
        guard canSubmit else { return }
        focus = nil
        let strings = self.strings

        Task {
            switch step {
            case .signIn:
                guard await auth.signIn(email: email, password: password, strings: strings) else { return }
            case .signUp:
                guard let outcome = await auth.signUp(email: email, password: password, strings: strings) else {
                    return
                }
                guard outcome == .signedIn else { return }
            }

            didSucceed = true
            password = ""
            await adoptVault()
        }
    }

    /// A fresh session immediately looks for the vault this account owns.
    private func adoptVault() async {
        let before = backup.lastRestoredCount
        let found = await backup.adoptAccountVault(strings: strings, context: modelContext)
        guard found else { return }
        let restored = backup.lastRestoredCount
        restoredCount = restored > 0 ? restored : (before > 0 ? nil : nil)
    }
}

/// Titled container matching the rest of the account surfaces.
private struct AccountCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Palette.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
    }
}

#Preview {
    AccountView()
        .environment(AppSettings())
        .environment(AuthService())
        .environment(CloudBackupService())
        .modelContainer(KudaoModelContainer.preview())
}
