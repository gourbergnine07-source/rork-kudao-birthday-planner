//
//  GalleryViewerView.swift
//  Kudao
//

import AVKit
import SwiftUI

/// Full-screen viewer for the party gallery, swiping between memories.
struct GalleryViewerView: View {
    let profile: BirthdayProfile
    let items: [GalleryItem]
    let gallery: GalleryService

    @Environment(AppSettings.self) private var settings
    @Environment(KudaoIdentity.self) private var identity
    @Environment(\.dismiss) private var dismiss

    @State private var selection: String
    @State private var isShowingChrome: Bool = true

    init(profile: BirthdayProfile, items: [GalleryItem], gallery: GalleryService, initialID: String) {
        self.profile = profile
        self.items = items
        self.gallery = gallery
        _selection = State(initialValue: initialID)
    }

    private var strings: Strings { settings.strings }

    private var current: GalleryItem? {
        items.first { $0.remoteID == selection }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $selection) {
                ForEach(items) { item in
                    GalleryMediaPage(
                        item: item,
                        profile: profile,
                        gallery: gallery,
                        identity: identity,
                        strings: strings
                    )
                    .tag(item.remoteID)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation(.smooth(duration: 0.22)) { isShowingChrome.toggle() }
            }
        }
        .overlay(alignment: .top) {
            if isShowingChrome { topBar }
        }
        .overlay(alignment: .bottom) {
            if isShowingChrome, let current { credits(current) }
        }
        .statusBarHidden(!isShowingChrome)
        .environment(\.locale, settings.locale)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(.black.opacity(0.42)))
            }
            .accessibilityLabel(strings.doneAction)

            Spacer(minLength: 0)

            if let index = items.firstIndex(where: { $0.remoteID == selection }) {
                Text("\(index + 1) / \(items.count)")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(.black.opacity(0.42)))
            }
        }
        .padding(.horizontal, 16)
        .transition(.opacity)
    }

    private func credits(_ item: GalleryItem) -> some View {
        HStack(spacing: 10) {
            AvatarView(
                name: item.uploaderName.isEmpty ? "?" : item.uploaderName,
                photoData: nil,
                size: 32
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(
                    item.isMine(identity.userID)
                        ? strings.participantYou
                        : (item.uploaderName.isEmpty ? strings.participantUnknown : item.uploaderName)
                )
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

                Text(settings.noteTimestamp(item.createdAt))
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
        .transition(.opacity)
    }
}

/// One page of the viewer: a zoomable photo or a playable clip.
private struct GalleryMediaPage: View {
    let item: GalleryItem
    let profile: BirthdayProfile
    let gallery: GalleryService
    let identity: KudaoIdentity
    let strings: Strings

    @State private var image: UIImage?
    @State private var player: AVPlayer?
    @State private var isLoading: Bool = true
    @State private var zoom: CGFloat = 1

    var body: some View {
        ZStack {
            if item.isVideo {
                videoContent
            } else {
                photoContent
            }

            if isLoading {
                VStack(spacing: 12) {
                    ProgressView().tint(.white)
                    Text(strings.galleryLoadingLabel)
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .task(id: item.remoteID) {
            await load()
        }
        .onDisappear {
            player?.pause()
        }
    }

    @ViewBuilder
    private var photoContent: some View {
        if let image {
            // Direct Image so pinch-to-zoom keeps working inside the pager.
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(zoom)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            zoom = min(4, max(1, value.magnification))
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { zoom = 1 }
                        }
                )
        } else if !isLoading {
            unavailable
        }
    }

    @ViewBuilder
    private var videoContent: some View {
        if let player {
            VideoPlayer(player: player)
                .onAppear { player.play() }
        } else if !isLoading {
            unavailable
        } else if let thumbnail = item.thumbnailData, let image = UIImage(data: thumbnail) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.5)
        }
    }

    private var unavailable: some View {
        VStack(spacing: 10) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 26, weight: .semibold))
            Text(strings.galleryMediaUnavailable)
                .font(.system(.footnote, design: .rounded, weight: .semibold))
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.white.opacity(0.8))
        .padding(30)
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        let url = await gallery.mediaURL(
            for: item,
            profile: profile,
            identity: identity,
            strings: strings
        )
        guard let url else { return }

        if item.isVideo {
            player = AVPlayer(url: url)
            return
        }

        // Decoding off the main actor keeps the pager smooth on large photos.
        image = await Task.detached(priority: .userInitiated) {
            guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }
            return UIImage(data: data)
        }.value
    }
}
