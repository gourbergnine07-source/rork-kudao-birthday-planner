//
//  EventRecordDetailView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// One archived year, opened: what was planned, what was written, what was lived.
struct EventRecordDetailView: View {
    let record: EventRecord

    @Environment(AppSettings.self) private var settings
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var gallery = GalleryService()
    @State private var viewerID: String?
    @State private var isConfirmingRecordDeletion: Bool = false
    /// Position of the memory awaiting confirmation, kept as an index because
    /// the highlights are plain strings and two years can read alike.
    @State private var pendingMemoryIndex: Int?

    private var strings: Strings { settings.strings }
    private var occasion: OccasionKind { record.occasion }
    private var accent: Color { occasion.accent }

    /// Gallery items of that cycle that still exist on this device.
    private var media: [GalleryItem] {
        guard let profile = record.profile else { return [] }
        let ids = Set(record.galleryItemIDs)
        return profile.galleryItems
            .filter { ids.contains($0.id) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private var sections: [PlanSection] {
        PlanSection.sections(for: occasion)
    }

    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 3)

    var body: some View {
        ZStack {
            WarmBackdrop()

            ScrollView {
                VStack(spacing: 18) {
                    hero

                    if let plan = record.plan, plan.hasContent {
                        planCard(plan)
                    } else if occasion.wantsSuggestions {
                        noPlanCard
                    }

                    if record.hasMessage {
                        messageCard
                    }

                    if !record.memoryHighlights.isEmpty {
                        memoriesCard
                    }

                    if !media.isEmpty {
                        mediaCard
                    }

                    if !record.keywords.isEmpty {
                        keywordsCard
                    }

                    footer
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(String(record.year))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        isConfirmingRecordDeletion = true
                    } label: {
                        Label(strings.libraryDeleteEventAction, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            strings.libraryDeleteEventTitle,
            isPresented: $isConfirmingRecordDeletion,
            titleVisibility: .visible
        ) {
            Button(strings.libraryDeleteEventAction, role: .destructive) {
                // Leave the screen first: the record it renders is about to go.
                dismiss()
                EventArchivist.delete(record, context: context)
            }
            Button(strings.cancelAction, role: .cancel) {}
        } message: {
            Text(
                String(
                    format: strings.libraryDeleteEventMessageFormat,
                    String(record.year),
                    record.profileName
                )
            )
        }
        .confirmationDialog(
            strings.libraryDeleteMemoryTitle,
            isPresented: Binding(
                get: { pendingMemoryIndex != nil },
                set: { if !$0 { pendingMemoryIndex = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(strings.libraryDeleteMemoryAction, role: .destructive) {
                if let index = pendingMemoryIndex {
                    EventArchivist.removeMemory(at: index, from: record, context: context)
                }
                pendingMemoryIndex = nil
            }
            Button(strings.cancelAction, role: .cancel) { pendingMemoryIndex = nil }
        } message: {
            Text(strings.libraryDeleteMemoryMessage)
        }
        .fullScreenCover(item: Binding(
            get: { viewerID.map(ViewerSelection.init) },
            set: { viewerID = $0?.id }
        )) { selection in
            if let profile = record.profile {
                GalleryViewerView(
                    profile: profile,
                    items: media,
                    gallery: gallery,
                    initialID: selection.id
                )
            }
        }
        .environment(\.locale, settings.locale)
        .tint(accent)
    }

    /// Wrapper so the full-screen viewer can key off a plain remote id.
    private struct ViewerSelection: Identifiable {
        let id: String
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: 190)
                .overlay {
                    if let data = record.coverData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    } else {
                        occasion.gradient
                            .overlay {
                                Image(systemName: occasion.symbolName)
                                    .font(.system(size: 44, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                    }
                }
                .clipShape(.rect(cornerRadius: 26, style: .continuous))
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.profileName)
                            .font(.system(.title3, design: .rounded, weight: .heavy))
                        Text(record.eventDate.formatted(date: .long, time: .omitted))
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .opacity(0.9)
                    }
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 8, y: 2)
                    .padding(18)
                }
                .overlay(alignment: .topTrailing) {
                    Label(occasion.title(strings), systemImage: occasion.symbolName)
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.black.opacity(0.4)))
                        .padding(12)
                }
        }
    }

    // MARK: - Cards

    private func planCard(_ plan: ArchivedPlan) -> some View {
        card(title: strings.libraryPlanSection, symbol: "sparkles", tint: Palette.violet) {
            VStack(spacing: 12) {
                ForEach(sections) { section in
                    let headline = plan.headline(for: section)
                    if !headline.isEmpty {
                        planRow(section: section, headline: headline, reason: plan.reason(for: section))
                    }
                }

                if plan.wasConfirmed {
                    Label(
                        String(
                            format: strings.confirmedAtFormat,
                            settings.noteTimestamp(plan.confirmedAt ?? record.eventDate)
                        ),
                        systemImage: "checkmark.seal.fill"
                    )
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(Palette.teal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func planRow(section: PlanSection, headline: String, reason: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: section.symbolName(for: occasion))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(section.accent)
                .frame(width: 26, height: 26)
                .background(Circle().fill(section.accent.opacity(0.12)))

            VStack(alignment: .leading, spacing: 3) {
                Text(section.title(strings, occasion: occasion))
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(.secondary)
                Text(headline)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
                if !reason.isEmpty {
                    Text(reason)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var noPlanCard: some View {
        card(title: strings.libraryPlanSection, symbol: "sparkles", tint: Palette.violet) {
            Text(strings.libraryNoPlanLabel)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var messageCard: some View {
        card(
            title: occasion.messageTabTitle(strings),
            symbol: occasion.messageSymbolName,
            tint: Palette.coral
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Text(record.messageText)
                    .font(.system(.subheadline, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Label(
                    record.wasMessageSent ? strings.librarySentBadge : strings.libraryNotSentBadge,
                    systemImage: record.wasMessageSent ? "checkmark.circle.fill" : "tray"
                )
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(record.wasMessageSent ? Palette.teal : .secondary)
            }
        }
    }

    private var memoriesCard: some View {
        card(
            title: occasion == .remembrance ? strings.memoriesTab : strings.libraryMemoriesSection,
            symbol: occasion.diarySymbolName,
            tint: Palette.sage
        ) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(record.memoryHighlights.enumerated()), id: \.offset) { index, memory in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Palette.sage)
                            .frame(width: 5, height: 5)
                            .padding(.top, 7)
                        Text(memory)
                            .font(.system(.footnote, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button(role: .destructive) {
                            pendingMemoryIndex = index
                        } label: {
                            Label(strings.libraryDeleteMemoryAction, systemImage: "trash")
                        }
                    }
                }

                if record.noteCount > record.memoryHighlights.count {
                    Text(String(format: strings.libraryNotesCountFormat, record.noteCount))
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var mediaCard: some View {
        card(title: strings.libraryMediaSection, symbol: "photo.stack.fill", tint: Palette.berry) {
            VStack(alignment: .leading, spacing: 10) {
                LazyVGrid(columns: Self.columns, spacing: 3) {
                    ForEach(media) { item in
                        Button {
                            viewerID = item.remoteID
                        } label: {
                            Palette.surfaceRaised
                                .aspectRatio(1, contentMode: .fit)
                                .overlay {
                                    if let data = item.thumbnailData, let image = UIImage(data: data) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .allowsHitTesting(false)
                                    } else {
                                        Image(systemName: item.mediaType.symbolName)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .clipShape(.rect(cornerRadius: 10, style: .continuous))
                                .overlay(alignment: .bottomTrailing) {
                                    if item.isVideo {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 8, weight: .black))
                                            .foregroundStyle(.white)
                                            .padding(4)
                                            .background(Circle().fill(.black.opacity(0.5)))
                                            .padding(5)
                                    }
                                }
                        }
                        .buttonStyle(PressableCardStyle())
                    }
                }

                Text(String(format: strings.libraryMediaCountFormat, record.mediaCount))
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var keywordsCard: some View {
        card(title: strings.libraryKeywordsSection, symbol: "tag.fill", tint: Palette.amber) {
            FlowLayout(spacing: 8) {
                ForEach(record.keywords, id: \.self) { keyword in
                    Text(keyword)
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(Palette.clay)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Palette.surfaceRaised))
                }
            }
        }
    }

    private var footer: some View {
        Text(String(format: strings.libraryArchivedOnFormat, record.archivedAt.formatted(date: .abbreviated, time: .omitted)))
            .font(.system(.caption2, design: .rounded))
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }

    // MARK: - Chrome

    private func card(
        title: String,
        symbol: String,
        tint: Color,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: symbol)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(tint)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }
}
