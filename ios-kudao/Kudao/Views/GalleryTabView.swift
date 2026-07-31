//
//  GalleryTabView.swift
//  Kudao
//

import PhotosUI
import SwiftData
import SwiftUI

/// Shared party gallery: everyone with access to the profile drops in their photos and clips.
///
/// The tab unlocks on the day of the party, mirrors the room's thumbnails into
/// SwiftData so the grid works offline, and downloads an original only when
/// somebody opens it full screen.
struct GalleryTabView: View {
    let profile: BirthdayProfile
    let gallery: GalleryService

    @Environment(AppSettings.self) private var settings
    @Environment(KudaoIdentity.self) private var identity
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var picked: [PhotosPickerItem] = []
    @State private var isPickingMedia: Bool = false
    @State private var isCapturing: Bool = false
    @State private var isPreparingDrafts: Bool = false
    @State private var draft: UploadDraft?
    @State private var captionTarget: GalleryItem?
    @State private var deniedSource: MediaSource?
    @State private var viewerTarget: ViewerTarget?
    @State private var pendingDeletion: GalleryItem?

    private static let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
    ]

    private var strings: Strings { settings.strings }

    private var items: [GalleryItem] {
        // `revision` keeps this recomputed after every merge or upload.
        _ = gallery.revision
        return GalleryTimeline.ordered(gallery.items(for: profile, context: modelContext))
    }

    /// The same memories split into days, most recent day first.
    private var sections: [GalleryDaySection] {
        GalleryTimeline.sections(items)
    }

    /// Memories already collected keep the gallery reachable long after the party.
    private var isUnlocked: Bool {
        profile.isGalleryUnlocked || !items.isEmpty
    }

    var body: some View {
        VStack(spacing: 14) {
            if isUnlocked {
                unlockedContent
            } else {
                lockedPanel
            }
        }
        .task(id: unlockSignature) {
            guard isUnlocked else { return }
            await gallery.sync(
                profile: profile,
                identity: identity,
                strings: strings,
                context: modelContext
            )
        }
        .onChange(of: picked) { _, selection in
            guard !selection.isEmpty else { return }
            load(selection)
        }
        .photosPicker(
            isPresented: $isPickingMedia,
            selection: $picked,
            maxSelectionCount: 10,
            matching: .any(of: [.images, .videos])
        )
        .fullScreenCover(isPresented: $isCapturing) {
            CameraCaptureView { media in
                prepareDrafts([PickedMediaEntry(media: media, capturedAt: Date())])
            }
            .ignoresSafeArea()
        }
        .sheet(item: $draft) { pending in
            GalleryCaptionSheet(uploads: pending.uploads) { ready in
                upload(ready)
            }
        }
        .sheet(item: $captionTarget) { item in
            GalleryCaptionEditorView(item: item) { caption in
                saveCaption(caption, for: item)
            }
        }
        .alert(
            deniedSource?.deniedTitle(strings) ?? "",
            isPresented: Binding(
                get: { deniedSource != nil },
                set: { if !$0 { deniedSource = nil } }
            ),
            presenting: deniedSource
        ) { _ in
            Button(strings.openSettingsAction) { MediaPermissions.openSettings() }
            Button(strings.cancelAction, role: .cancel) {}
        } message: { source in
            Text(source.deniedMessage(strings))
        }
        .fullScreenCover(item: $viewerTarget) { target in
            GalleryViewerView(profile: profile, items: items, gallery: gallery, initialID: target.value)
        }
        .alert(
            strings.galleryDeleteConfirmTitle,
            isPresented: Binding(
                get: { pendingDeletion != nil },
                set: { if !$0 { pendingDeletion = nil } }
            )
        ) {
            Button(strings.cancelAction, role: .cancel) { pendingDeletion = nil }
            Button(strings.deleteAction, role: .destructive) {
                if let item = pendingDeletion { delete(item) }
                pendingDeletion = nil
            }
        } message: {
            Text(strings.galleryDeleteConfirmMessage)
        }
    }

    /// Re-syncs when the gallery opens or the profile changes.
    private var unlockSignature: String {
        "\(profile.id.uuidString)|\(isUnlocked ? 1 : 0)"
    }

    // MARK: - Unlocked

    @ViewBuilder
    private var unlockedContent: some View {
        headerRow

        if let error = gallery.errorMessage {
            errorBanner(error)
        }

        if gallery.isUploading || isPreparingDrafts {
            uploadBanner
        }

        if items.isEmpty {
            PlaceholderPanel(
                icon: "photo.stack",
                title: strings.galleryEmptyTitle,
                message: strings.galleryEmptyMessage,
                tint: Palette.violet
            )

            addButton
        } else {
            LazyVGrid(columns: Self.columns, spacing: 3, pinnedViews: [.sectionHeaders]) {
                ForEach(sections) { section in
                    Section {
                        ForEach(section.items) { item in
                            cell(item)
                        }
                    } header: {
                        dayHeader(section)
                    }
                }
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.32), value: items.count)

            HStack(spacing: 5) {
                Image(systemName: "arrow.down.to.line")
                    .font(.system(size: 9, weight: .black))
                Text(strings.galleryAutoOrderNote)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .foregroundStyle(.tertiary)

            HStack(spacing: 7) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 10, weight: .bold))
                Text(strings.galleryPrivacyNote)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .foregroundStyle(.tertiary)
        }
    }

    private var headerRow: some View {
        HStack(spacing: 8) {
            Text(strings.gallerySectionTitle.uppercased())
                .font(.system(.caption, design: .rounded, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(.secondary)

            if gallery.isSyncing(profile) {
                ProgressView().controlSize(.mini).tint(Palette.violet)
            }

            Spacer(minLength: 0)

            if !items.isEmpty {
                Text(String(format: strings.galleryCountFormat, items.count))
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)

                addMenu {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Palette.warmGradient))
                        .shadow(color: Palette.coral.opacity(0.3), radius: 8, y: 4)
                }
            }
        }
    }

    /// Sticky date divider: "Oggi · 4 ricordi".
    private func dayHeader(_ section: GalleryDaySection) -> some View {
        HStack(spacing: 7) {
            Text(dayTitle(section.id))
                .font(.system(.caption, design: .rounded, weight: .heavy))
                .foregroundStyle(.primary)

            Text(String(format: strings.galleryCountFormat, section.count))
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Capsule().fill(.ultraThinMaterial)
        )
        .padding(.top, 8)
        .padding(.bottom, 4)
        .gridCellColumns(Self.columns.count)
        .accessibilityAddTraits(.isHeader)
    }

    /// "Oggi", "Ieri", then the full weekday and date.
    private func dayTitle(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return strings.todayLabel }
        if calendar.isDateInYesterday(date) { return strings.yesterdayLabel }
        let full = settings.weekdayDayMonth(date)
        return full.prefix(1).uppercased() + full.dropFirst()
    }

    private var addButton: some View {
        addMenu {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .heavy))
                Text(strings.galleryAddAction)
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Capsule().fill(Palette.warmGradient))
            .shadow(color: Palette.coral.opacity(0.3), radius: 12, y: 6)
        }
    }

    /// Library or camera, the two ways a memory gets in.
    private func addMenu<Content: View>(@ViewBuilder label: () -> Content) -> some View {
        Menu {
            Button {
                startLibrary()
            } label: {
                Label(strings.galleryFromLibraryAction, systemImage: "photo.on.rectangle.angled")
            }

            if CameraCaptureView.isAvailable {
                Button {
                    startCamera()
                } label: {
                    Label(strings.galleryCaptureAction, systemImage: "camera.fill")
                }
            }
        } label: {
            label()
        }
        .accessibilityLabel(strings.galleryAddAction)
    }

    private var uploadBanner: some View {
        HStack(spacing: 11) {
            ProgressView()
                .controlSize(.small)
                .tint(Palette.coral)

            VStack(alignment: .leading, spacing: 2) {
                Text(isPreparingDrafts ? strings.galleryPreparingTitle : strings.galleryUploadingTitle)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                if !isPreparingDrafts {
                    Text(String(format: strings.galleryUploadingCountFormat, gallery.pendingUploads))
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Palette.coral.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.coral.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Cell

    private func cell(_ item: GalleryItem) -> some View {
        Button {
            guard item.uploadState != .failed else {
                retry(item)
                return
            }
            viewerTarget = ViewerTarget(value: item.remoteID)
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
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .clipShape(.rect(cornerRadius: 10, style: .continuous))
                .overlay(alignment: .topTrailing) { badge(item) }
                .overlay(alignment: .bottom) { footer(item) }
                .overlay {
                    if item.uploadState != .uploaded {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.black.opacity(0.35))
                            .overlay { uploadState(item) }
                            .allowsHitTesting(false)
                    }
                }
        }
        .buttonStyle(PressableCardStyle())
        .contextMenu {
            if item.isMine(identity.userID), item.uploadState == .uploaded {
                Button {
                    captionTarget = item
                } label: {
                    Label(
                        item.hasCaption ? strings.galleryCaptionEditAction : strings.galleryCaptionAddAction,
                        systemImage: "text.bubble"
                    )
                }
            }

            if canDelete(item) {
                Button(role: .destructive) {
                    pendingDeletion = item
                } label: {
                    Label(strings.galleryDeleteAction, systemImage: "trash")
                }
            }
        }
    }

    @ViewBuilder
    private func badge(_ item: GalleryItem) -> some View {
        if item.hasCaption, !item.isVideo {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(.white)
                .padding(4)
                .background(Circle().fill(.black.opacity(0.5)))
                .padding(5)
        } else if item.isVideo {
            HStack(spacing: 3) {
                Image(systemName: "play.fill")
                    .font(.system(size: 7, weight: .black))
                if !item.durationLabel.isEmpty {
                    Text(item.durationLabel)
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .background(Capsule().fill(.black.opacity(0.55)))
            .padding(5)
        }
    }

    /// Who brought this memory, when, and the first words of its caption.
    private func footer(_ item: GalleryItem) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            if item.hasCaption {
                Text(item.caption)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            HStack(spacing: 4) {
                AvatarView(
                    name: item.uploaderName.isEmpty ? "?" : item.uploaderName,
                    photoData: nil,
                    size: 15
                )
                Text(shortDate(item.createdAt))
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 5)
        .padding(.bottom, 4)
        .padding(.top, 12)
        .background(
            LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        )
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func uploadState(_ item: GalleryItem) -> some View {
        if item.uploadState == .uploading {
            ProgressView().controlSize(.small).tint(.white)
        } else {
            VStack(spacing: 3) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .heavy))
                Text(strings.retryAction)
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(.white)
        }
    }

    /// "3 giu" style label, compact enough for a third of the screen.
    private func shortDate(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(locale: settings.locale)
                .day(.defaultDigits)
                .month(.abbreviated)
        )
    }

    private func canDelete(_ item: GalleryItem) -> Bool {
        profile.isOwnedByMe || item.isMine(identity.userID)
    }

    // MARK: - Locked

    private var lockedPanel: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Palette.violet.opacity(0.14))
                    .frame(width: 92, height: 92)
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(Palette.violet)
                    .symbolEffect(
                        .pulse,
                        options: reduceMotion ? .nonRepeating : .repeat(.periodic(delay: 2.4))
                    )
            }

            VStack(spacing: 7) {
                Text(strings.galleryLockedTitle)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Text(String(format: strings.galleryLockedMessageFormat, settings.dayMonth(profile.galleryUnlockDate)))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            KudaoChip(
                title: profile.countdown.imminentLabel(strings),
                systemImage: "hourglass",
                tint: Palette.coral
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
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
                gallery.clearError()
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

    // MARK: - Actions

    /// Camera and library both need a green light before they open.
    private func startLibrary() {
        Task {
            guard await MediaPermissions.requestPhotoLibrary() else {
                deniedSource = .photoLibrary
                return
            }
            isPickingMedia = true
        }
    }

    private func startCamera() {
        Task {
            guard await MediaPermissions.requestCamera() else {
                deniedSource = .camera
                return
            }
            isCapturing = true
        }
    }

    /// Loads what the picker returned, then asks for captions.
    ///
    /// The library also tells us when each asset was shot, which is what the
    /// timeline is built on — an import of last month's photos slots into last
    /// month instead of jumping to the top.
    private func load(_ selection: [PhotosPickerItem]) {
        picked = []
        isPreparingDrafts = true

        Task {
            let identifiers = selection.compactMap(\.itemIdentifier)
            let captureDates = await Task.detached(priority: .userInitiated) {
                PhotoLibraryDates.captureDates(for: identifiers)
            }.value

            var media: [PickedMediaEntry] = []
            for entry in selection {
                let capturedAt = entry.itemIdentifier.flatMap { captureDates[$0] }
                if entry.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                    if let movie = try? await entry.loadTransferable(type: PickedMovie.self) {
                        media.append(PickedMediaEntry(media: .video(movie.url), capturedAt: capturedAt))
                    }
                } else if let data = try? await entry.loadTransferable(type: Data.self) {
                    media.append(PickedMediaEntry(media: .photo(data), capturedAt: capturedAt))
                }
            }
            prepareDrafts(media)
        }
    }

    /// Builds the caption sheet: every memory with a small preview beside its field.
    private func prepareDrafts(_ media: [PickedMediaEntry]) {
        guard !media.isEmpty else {
            isPreparingDrafts = false
            return
        }

        isPreparingDrafts = true
        Task {
            var uploads: [PendingUpload] = []
            for entry in media {
                let preview = await GalleryMediaPreparer.previewThumbnail(for: entry.media)
                uploads.append(
                    PendingUpload(
                        media: entry.media,
                        previewData: preview,
                        capturedAt: entry.capturedAt
                    )
                )
            }
            isPreparingDrafts = false
            draft = UploadDraft(uploads: uploads)
        }
    }

    private func upload(_ uploads: [PendingUpload]) {
        guard !uploads.isEmpty else { return }
        Task {
            await gallery.upload(
                sources: uploads,
                profile: profile,
                identity: identity,
                strings: strings,
                context: modelContext
            )
        }
    }

    private func saveCaption(_ caption: String, for item: GalleryItem) {
        Task {
            await gallery.updateCaption(
                caption,
                for: item,
                profile: profile,
                identity: identity,
                strings: strings,
                context: modelContext
            )
        }
    }

    private func retry(_ item: GalleryItem) {
        Task {
            await gallery.retry(
                item: item,
                profile: profile,
                identity: identity,
                strings: strings,
                context: modelContext
            )
        }
    }

    private func delete(_ item: GalleryItem) {
        Task {
            await gallery.delete(
                item: item,
                profile: profile,
                identity: identity,
                strings: strings,
                context: modelContext
            )
        }
    }
}

/// Identifiable wrapper so the viewer can be presented from an optional id.
private struct ViewerTarget: Identifiable {
    let value: String
    var id: String { value }
}

/// Batch of memories waiting in the caption sheet.
private struct UploadDraft: Identifiable {
    let id: UUID = UUID()
    let uploads: [PendingUpload]
}
