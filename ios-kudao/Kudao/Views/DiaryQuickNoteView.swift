//
//  DiaryQuickNoteView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// The screen a diary invitation opens: pick a person, write, done.
///
/// Tapping the notification must not drop the user on the home screen with the
/// work still to do, so this sheet keeps the profile picker and the composer
/// side by side and puts the keyboard up straight away.
struct DiaryQuickNoteView: View {
    /// Profile the notification named, preselected when it is still around.
    let suggestedProfileID: UUID?

    @Environment(AppSettings.self) private var settings
    @Environment(KudaoIdentity.self) private var identity
    @Environment(BiometricGate.self) private var gate
    @Environment(CollaborationService.self) private var collaboration
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var profiles: [BirthdayProfile]

    @State private var analyzer = DiaryAnalyzer()
    @State private var selectedID: UUID?
    @State private var draft: String = ""
    @State private var savedCount: Int = 0
    @FocusState private var isComposerFocused: Bool

    private static let characterLimit = 400

    private var strings: Strings { settings.strings }

    /// Profiles that can be written about right now: no remembrances, no
    /// excluded ones, and no surprise still behind its lock.
    private var candidates: [BirthdayProfile] {
        profiles
            .filter(\.wantsDiaryNudges)
            .filter { !settings.requiresUnlock($0) || gate.isUnlocked($0.id) }
            .sorted { $0.countdown.daysRemaining < $1.countdown.daysRemaining }
    }

    private var selected: BirthdayProfile? {
        candidates.first { $0.id == selectedID } ?? candidates.first
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                if candidates.isEmpty {
                    PlaceholderPanel(
                        icon: "book.closed.fill",
                        title: strings.quickNoteTitle,
                        message: strings.quickNoteEmptyMessage,
                        tint: Palette.coral
                    )
                    .padding(.horizontal, 20)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            intro
                            peoplePicker
                            composer
                            recentNotes
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .navigationTitle(strings.quickNoteTitle)
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
        .pausesInterstitials()
        .onAppear {
            selectedID = suggestedProfileID ?? candidates.first?.id
            guard !candidates.isEmpty else { return }
            isComposerFocused = true
        }
        .sensoryFeedback(.success, trigger: savedCount)
    }

    // MARK: - Sections

    private var intro: some View {
        Text(strings.quickNoteCaption)
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Horizontal row of avatars: one tap changes who the note is about.
    private var peoplePicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(candidates) { profile in
                    personChip(profile)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, 0, for: .scrollContent)
    }

    private func personChip(_ profile: BirthdayProfile) -> some View {
        let isActive = selected?.id == profile.id

        return Button {
            withAnimation(.smooth(duration: 0.22)) {
                selectedID = profile.id
            }
            isComposerFocused = true
        } label: {
            HStack(spacing: 8) {
                AvatarView(name: profile.name, photoData: profile.photoData, size: 28)

                Text(profile.name)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(isActive ? .white : .primary)
                    .lineLimit(1)
            }
            .padding(.leading, 6)
            .padding(.trailing, 14)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(
                    isActive
                        ? AnyShapeStyle(profile.occasion.gradient)
                        : AnyShapeStyle(Palette.surface)
                )
            )
            .overlay(
                Capsule().strokeBorder(
                    isActive ? Color.clear : Palette.hairline,
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField(
                String(format: strings.diaryComposerPlaceholderFormat, selected?.name ?? ""),
                text: $draft,
                axis: .vertical
            )
            .font(.system(.body, design: .rounded))
            .lineLimit(3...8)
            .focused($isComposerFocused)
            .onChange(of: draft) { _, newValue in
                if newValue.count > Self.characterLimit {
                    draft = String(newValue.prefix(Self.characterLimit))
                }
            }

            HStack(spacing: 12) {
                if !trimmedDraft.isEmpty {
                    Text("\(draft.count)/\(Self.characterLimit)")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                } else {
                    Label("AI", systemImage: "sparkles")
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .foregroundStyle(Palette.amber)
                }

                Spacer(minLength: 0)

                Button {
                    save()
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 13, weight: .heavy))
                        Text(strings.quickNoteSaveAction)
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(
                        Capsule().fill(
                            trimmedDraft.isEmpty
                                ? AnyShapeStyle(Color.gray.opacity(0.35))
                                : AnyShapeStyle(Palette.warmGradient)
                        )
                    )
                }
                .buttonStyle(PressableCardStyle())
                .disabled(trimmedDraft.isEmpty)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(isComposerFocused ? Palette.coral.opacity(0.5) : Palette.hairline, lineWidth: 1)
        )
        .animation(.smooth(duration: 0.22), value: isComposerFocused)
    }

    /// The last couple of notes, so the user does not repeat themselves.
    @ViewBuilder
    private var recentNotes: some View {
        if let profile = selected {
            let recent = profile.diaryEntries
                .sorted { $0.createdAt > $1.createdAt }
                .prefix(3)

            if !recent.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text(strings.diaryNotesSection.uppercased())
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .tracking(1.1)
                        .foregroundStyle(.secondary)

                    ForEach(recent) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.textContent)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            Text(settings.noteTimestamp(note.createdAt))
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Palette.surfaceRaised)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func save() {
        let text = trimmedDraft
        guard !text.isEmpty, let profile = selected else { return }

        let note = DiaryEntry(
            textContent: text,
            profile: profile,
            authorUserID: identity.userID,
            authorName: identity.outgoingName(strings)
        )
        modelContext.insert(note)
        try? modelContext.save()

        draft = ""
        savedCount += 1

        if profile.isCollaborative && !profile.isOwnedByMe {
            Task {
                await collaboration.publish(
                    note: note,
                    profile: profile,
                    identity: identity,
                    strings: strings
                )
            }
        }

        analyzer.analyze(
            entry: note,
            profile: profile,
            language: settings.language,
            context: modelContext
        )

        dismiss()
    }
}

#Preview {
    DiaryQuickNoteView(suggestedProfileID: nil)
        .environment(AppSettings())
        .environment(KudaoIdentity.shared)
        .environment(BiometricGate.shared)
        .environment(CollaborationService())
        .modelContainer(KudaoModelContainer.preview())
}
