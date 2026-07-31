//
//  DiaryTabView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Diary tab: composer on top, newest notes below.
struct DiaryTabView: View {
    let profile: BirthdayProfile
    let analyzer: DiaryAnalyzer

    @Environment(AppSettings.self) private var settings
    @Environment(KudaoIdentity.self) private var identity
    @Environment(CollaborationService.self) private var collaboration
    @Environment(\.modelContext) private var modelContext

    @State private var draft: String = ""
    @State private var savedCount: Int = 0
    @FocusState private var isComposerFocused: Bool

    private static let characterLimit = 400

    private var strings: Strings { settings.strings }

    private var notes: [DiaryEntry] {
        profile.diaryEntries.sorted { $0.createdAt > $1.createdAt }
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Guests with view-only access read the diary but never write into it.
    private var canWrite: Bool {
        !profile.isCollaborative || profile.canContribute
    }

    var body: some View {
        VStack(spacing: 18) {
            if canWrite {
                composer
            } else {
                readOnlyBanner
            }

            if notes.isEmpty {
                PlaceholderPanel(
                    icon: "book.closed.fill",
                    title: strings.diaryEmptyTitle,
                    message: strings.diaryEmptyMessage,
                    tint: Palette.coral
                )
            } else {
                HStack {
                    Text(strings.diaryNotesSection.uppercased())
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .tracking(1.1)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: strings.diaryNotesCountFormat, notes.count))
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                LazyVStack(spacing: 12) {
                    ForEach(notes) { note in
                        DiaryNoteCard(
                            note: note,
                            settings: settings,
                            isAnalyzing: analyzer.isRunning(note),
                            canDelete: canDelete(note),
                            onRetry: { retry(note) },
                            onDelete: { delete(note) }
                        )
                    }
                }
            }
        }
        .task(id: pendingRemoteSignature) {
            analyzePendingRemoteNotes()
        }
    }

    private var readOnlyBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "eye.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.teal)
            Text(strings.readOnlyDiaryMessage)
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Palette.teal.opacity(0.12)))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.teal.opacity(0.28), lineWidth: 1)
        )
    }

    /// Notes written by collaborators still feed the AI suggestions of the owner.
    private var pendingRemoteSignature: String {
        guard profile.isOwnedByMe else { return "" }
        return notes
            .filter { $0.isRemote && $0.extraction == nil && $0.extractionStatus == .pending }
            .map(\.id.uuidString)
            .joined()
    }

    private func analyzePendingRemoteNotes() {
        guard profile.isOwnedByMe else { return }
        for note in notes where note.isRemote
            && note.extraction == nil
            && note.extractionStatus == .pending
            && !analyzer.isRunning(note) {
            analyzer.analyze(
                entry: note,
                profile: profile,
                language: settings.language,
                context: modelContext
            )
        }
    }

    /// Owners delete anything; collaborators only their own notes.
    private func canDelete(_ note: DiaryEntry) -> Bool {
        profile.isOwnedByMe || note.isMine(identity.userID)
    }

    // MARK: - Composer

    private var composer: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField(
                String(format: strings.diaryComposerPlaceholderFormat, profile.name),
                text: $draft,
                axis: .vertical
            )
            .font(.system(.body, design: .rounded))
            .lineLimit(1...5)
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
                        .transition(.opacity)
                } else {
                    Label(strings.analyzingLabel.isEmpty ? "" : "AI", systemImage: "sparkles")
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .foregroundStyle(Palette.amber)
                        .labelStyle(.titleAndIcon)
                }

                Spacer()

                Button {
                    save()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle().fill(
                                trimmedDraft.isEmpty
                                    ? AnyShapeStyle(Color.gray.opacity(0.35))
                                    : AnyShapeStyle(Palette.warmGradient)
                            )
                        )
                }
                .buttonStyle(PressableCardStyle())
                .disabled(trimmedDraft.isEmpty)
                .accessibilityLabel(strings.diarySendNote)
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
        .sensoryFeedback(.success, trigger: savedCount)
    }

    // MARK: - Actions

    private func save() {
        let text = trimmedDraft
        guard !text.isEmpty else { return }

        let note = DiaryEntry(
            textContent: text,
            profile: profile,
            authorUserID: identity.userID,
            authorName: identity.outgoingName(strings)
        )
        modelContext.insert(note)
        try? modelContext.save()

        draft = ""
        isComposerFocused = false
        savedCount += 1

        // Guests push straight away; owners publish with the next snapshot sync.
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
    }

    private func retry(_ note: DiaryEntry) {
        analyzer.analyze(
            entry: note,
            profile: profile,
            language: settings.language,
            context: modelContext
        )
    }

    private func delete(_ note: DiaryEntry) {
        let noteID = note.id
        let wasShared = profile.isCollaborative
        CloudTombstones.recordEntry(noteID, profileID: profile.id)
        modelContext.delete(note)
        try? modelContext.save()

        guard wasShared else { return }
        Task {
            await collaboration.retract(
                noteID: noteID,
                profile: profile,
                identity: identity,
                strings: strings
            )
        }
    }
}

/// One diary note with its extracted keywords and status.
private struct DiaryNoteCard: View {
    let note: DiaryEntry
    let settings: AppSettings
    let isAnalyzing: Bool
    let canDelete: Bool
    let onRetry: () -> Void
    let onDelete: () -> Void

    @State private var isConfirmingDelete: Bool = false

    private var strings: Strings { settings.strings }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text(note.textContent)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if canDelete {
                    Button {
                        isConfirmingDelete = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(strings.deleteNoteAction)
                }
            }

            HStack(spacing: 8) {
                if note.isRemote, !note.authorName.isEmpty {
                    HStack(spacing: 5) {
                        AvatarView(name: note.authorName, photoData: nil, size: 18)
                        Text(note.authorName)
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    .padding(.leading, 3)
                    .padding(.trailing, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Palette.violet.opacity(0.14)))
                }

                Text(settings.noteTimestamp(note.createdAt))
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)

                if let tag = note.extraction {
                    KudaoChip(
                        title: tag.category.title(strings),
                        systemImage: tag.category.symbolName,
                        tint: tag.category.accent
                    )
                    if tag.isGiftRelevant {
                        KudaoChip(title: strings.giftIdeaBadge, systemImage: "gift.fill", tint: Palette.berry)
                    }
                }

                Spacer(minLength: 0)
            }

            statusRow
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .contextMenu {
            if canDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label(strings.deleteNoteAction, systemImage: "trash")
                }
            }
        }
        .alert(strings.deleteNoteAction, isPresented: $isConfirmingDelete) {
            Button(strings.cancelAction, role: .cancel) {}
            Button(strings.deleteAction, role: .destructive) { onDelete() }
        }
    }

    @ViewBuilder
    private var statusRow: some View {
        if isAnalyzing || (note.extractionStatus == .pending && note.extraction == nil) {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.mini)
                    .tint(Palette.amber)
                Text(strings.analyzingLabel)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        } else if note.extractionStatus == .failed {
            HStack(spacing: 10) {
                Label(strings.analysisFailedLabel, systemImage: "exclamationmark.triangle.fill")
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                Button(strings.retryAction) { onRetry() }
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .buttonStyle(.plain)
                    .foregroundStyle(Palette.coral)
            }
        } else if let tag = note.extraction, !tag.keywords.isEmpty {
            FlowLayout(spacing: 6, lineSpacing: 6) {
                ForEach(tag.keywords, id: \.self) { keyword in
                    Text(keyword)
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Palette.surfaceRaised))
                }
            }
        }
    }
}
