//
//  MessageTabView.swift
//  Kudao
//

import SwiftUI
import UIKit

/// Ready-to-send birthday message, written from the diary keywords.
struct MessageTabView: View {
    let profile: BirthdayProfile
    @Bindable var composer: GreetingComposer

    @Environment(AppSettings.self) private var settings
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var didCopy: Bool = false
    @State private var sharedText: SharedGreeting?

    private var strings: Strings { settings.strings }

    private var phone: String {
        profile.contactPhone.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var email: String {
        profile.contactEmail.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 16) {
            toneRow

            if let error = composer.errorMessage {
                errorBanner(error)
            }

            if composer.isGenerating && composer.message == nil {
                generatingPanel
            } else if let message = composer.message {
                messageCard(message)
                sendRow(message)
            } else {
                emptyPanel
            }
        }
        .task(id: taskKey) {
            composer.generateIfNeeded(for: profile, language: settings.language)
        }
        .sheet(item: $sharedText) { shared in
            ShareSheet(text: shared.text)
        }
    }

    /// Regenerates whenever the profile or the tone changes.
    private var taskKey: String {
        "\(profile.id.uuidString)-\(composer.tone.rawValue)"
    }

    // MARK: - Tone

    private var toneRow: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(strings.messageToneLabel.uppercased())
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .tracking(1)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(GreetingTone.allCases) { tone in
                    let isSelected = tone == composer.tone
                    Button {
                        withAnimation(reduceMotion ? nil : .smooth(duration: 0.25)) {
                            composer.tone = tone
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: tone.symbolName)
                                .font(.system(size: 10, weight: .bold))
                            Text(tone.title(strings))
                                .font(.system(.footnote, design: .rounded, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(isSelected ? .white : Color.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            Capsule().fill(
                                isSelected
                                    ? AnyShapeStyle(Palette.warmGradient)
                                    : AnyShapeStyle(Palette.surface)
                            )
                        )
                        .overlay(
                            Capsule().strokeBorder(
                                isSelected ? .clear : Palette.hairline,
                                lineWidth: 1
                            )
                        )
                    }
                    .buttonStyle(PressableCardStyle())
                }
            }
        }
    }

    // MARK: - Message

    private func messageCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Palette.coral)
                Text(strings.messageSectionTitle)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                if composer.isGenerating {
                    ProgressView().controlSize(.mini).tint(Palette.coral)
                }
            }

            Text(message)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.opacity)

            HStack(spacing: 7) {
                Image(systemName: "sparkles")
                    .font(.system(size: 9, weight: .bold))
                Text(strings.messageBasedOnNote)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                Spacer(minLength: 0)

                Button {
                    composer.generate(for: profile, language: settings.language)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 10, weight: .heavy))
                        Text(strings.messageRegenerateAction)
                            .font(.system(.caption, design: .rounded, weight: .bold))
                    }
                    .foregroundStyle(Palette.coral)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Palette.coral.opacity(0.13)))
                }
                .buttonStyle(PressableCardStyle())
                .disabled(composer.isGenerating)
            }
            .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 12, y: 6)
    }

    // MARK: - Sending

    private func sendRow(_ message: String) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                actionButton(
                    title: didCopy ? strings.messageCopiedLabel : strings.messageCopyAction,
                    systemImage: didCopy ? "checkmark" : "doc.on.doc.fill",
                    tint: Palette.violet
                ) {
                    UIPasteboard.general.string = message
                    withAnimation(.smooth(duration: 0.2)) { didCopy = true }
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation(.smooth(duration: 0.2)) { didCopy = false }
                    }
                }

                actionButton(
                    title: strings.messageShareAction,
                    systemImage: "square.and.arrow.up",
                    tint: Palette.teal
                ) {
                    sharedText = SharedGreeting(text: message)
                }
            }

            if !phone.isEmpty || !email.isEmpty {
                HStack(spacing: 10) {
                    if !phone.isEmpty {
                        actionButton(
                            title: strings.messageSMSAction,
                            systemImage: "message.fill",
                            tint: Palette.coral
                        ) {
                            openSMS(message)
                        }
                    }
                    if !email.isEmpty {
                        actionButton(
                            title: strings.messageEmailAction,
                            systemImage: "envelope.fill",
                            tint: Palette.amber
                        ) {
                            openMail(message)
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.success, trigger: didCopy)
    }

    private func actionButton(
        title: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .bold))
                    .contentTransition(.symbolEffect(.replace))
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(tint.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(tint.opacity(0.28), lineWidth: 1)
            )
        }
        .buttonStyle(PressableCardStyle())
    }

    /// Opens Messages with the greeting prefilled for the saved number.
    private func openSMS(_ message: String) {
        let digits = phone.filter { $0.isNumber || $0 == "+" }
        var components = URLComponents()
        components.scheme = "sms"
        components.path = digits
        components.queryItems = [URLQueryItem(name: "body", value: message)]
        guard let url = components.url else { return }
        openURL(url)
    }

    /// Opens Mail with subject and greeting prefilled for the saved address.
    private func openMail(_ message: String) {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = email
        components.queryItems = [
            URLQueryItem(name: "subject", value: String(format: strings.messageEmailSubjectFormat, profile.name)),
            URLQueryItem(name: "body", value: message)
        ]
        guard let url = components.url else { return }
        openURL(url)
    }

    // MARK: - States

    private var generatingPanel: some View {
        VStack(spacing: 14) {
            ProgressView().tint(Palette.coral)
            Text(strings.messageGeneratingTitle)
                .font(.system(.headline, design: .rounded, weight: .bold))
            Text(strings.messageGeneratingMessage)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }

    private var emptyPanel: some View {
        VStack(spacing: 14) {
            PlaceholderPanel(
                icon: "paperplane",
                title: strings.messageEmptyTitle,
                message: strings.messageEmptyMessage
            )

            Button {
                composer.generate(for: profile, language: settings.language)
            } label: {
                Label(strings.generateAction, systemImage: "sparkles")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Capsule().fill(Palette.warmGradient))
                    .shadow(color: Palette.coral.opacity(0.3), radius: 12, y: 6)
            }
            .buttonStyle(PressableCardStyle())
        }
    }

    private func errorBanner(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Palette.amber)
            Text(text)
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button {
                composer.clearError()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Palette.amber.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.amber.opacity(0.3), lineWidth: 1)
        )
    }
}

/// Wrapper so the share sheet can be driven by an optional item.
struct SharedGreeting: Identifiable {
    let id: UUID = UUID()
    let text: String
}
