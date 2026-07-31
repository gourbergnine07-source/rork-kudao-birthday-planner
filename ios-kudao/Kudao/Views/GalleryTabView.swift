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
        return gallery.items(for: profile, context: modelContext)
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
                upload([media])
            }
            .ignoresSafeArea()
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

        if gallery.isUploading {
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
            LazyVGrid(columns: Self.columns, spacing: 3) {
                ForEach(items) { item in
                    cell(item)
                }
            }

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
                isPickingMedia = true
            } label: {
                Label(strings.galleryFromLibraryAction, systemImage: "photo.on.rectangle.angled")
            }

            if CameraCaptureView.isAvailable {
                Button {
                    isCapturing = true
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
                Text(strings.galleryUploadingTitle)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                Text(String(format: strings.galleryUploadingCountFormat, gallery.pendingUploads))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
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
        if item.isVideo {
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

    /// Who brought this memory, and when.
    private func footer(_ item: GalleryItem) -> some View {
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

    /// Loads what the picker returned, then hands it to the upload pipeline.
    private func load(_ selection: [PhotosPickerItem]) {
        picked = []

        Task {
            var media: [PickedMedia] = []
            for entry in selection {
                if entry.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                    if let movie = try? await entry.loadTransferable(type: PickedMovie.self) {
                        media.append(.video(movie.url))
                    }
                } else if let data = try? await entry.loadTransferable(type: Data.self) {
                    media.append(.photo(data))
                }
            }
            upload(media)
        }
    }

    private func upload(_ media: [PickedMedia]) {
        guard !media.isEmpty else { return }
        Task {
            await gallery.upload(
                sources: media,
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
