//
//  NearbyStoresView.swift
//  Kudao
//

import MapKit
import SwiftUI

/// Mini map plus shop list for the AI-suggested gift category.
struct NearbyStoresView: View {
    /// Gift category coming from the generated party plan.
    let category: String
    /// Gift idea shown as the reason behind the search.
    let giftIdea: String

    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var finder = StoreFinder()
    @State private var camera: MapCameraPosition = .automatic
    @State private var selected: NearbyStore?

    private var strings: Strings { settings.strings }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 16) {
                        searchHeader
                        mapCard
                        resultsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 36)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(strings.storesTitle)
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
        .task {
            finder.search(category: category, language: settings.language)
        }
        .onDisappear { finder.cancel() }
        .onChange(of: finder.stores) { _, stores in
            guard let first = stores.first else { return }
            withAnimation(.smooth(duration: 0.4)) {
                camera = .region(
                    MKCoordinateRegion(
                        center: finder.userCoordinate ?? first.coordinate,
                        latitudinalMeters: 6_000,
                        longitudinalMeters: 6_000
                    )
                )
            }
        }
    }

    // MARK: - Header

    private var searchHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 9) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette.berry)
                Text(String(format: strings.giftFromPlanFormat, giftIdea))
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .lineLimit(2)
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                KudaoChip(
                    title: String(format: strings.storesSearchingCategoryFormat, category),
                    systemImage: "magnifyingglass",
                    tint: Palette.teal
                )
                KudaoChip(title: strings.storesRadiusNote, systemImage: "location.fill", tint: Palette.violet)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }

    // MARK: - Map

    private var mapCard: some View {
        Map(position: $camera, selection: $selected) {
            UserAnnotation()

            ForEach(finder.stores) { store in
                Marker(store.name, systemImage: "bag.fill", coordinate: store.coordinate)
                    .tint(Palette.coral)
                    .tag(store)
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .frame(height: 230)
        .clipShape(.rect(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .overlay {
            if finder.isBusy {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                    VStack(spacing: 10) {
                        ProgressView().tint(Palette.coral)
                        Text(strings.storesSearchingLabel)
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
    }

    // MARK: - Results

    @ViewBuilder
    private var resultsSection: some View {
        switch finder.phase {
        case .denied:
            PlaceholderPanel(
                icon: "location.slash.fill",
                title: strings.storesDeniedTitle,
                message: strings.storesDeniedMessage,
                tint: Palette.amber
            )
            .overlay(alignment: .bottom) {
                Button {
                    finder.openSystemSettings()
                } label: {
                    Text(strings.openSettingsAction)
                        .font(.system(.footnote, design: .rounded, weight: .bold))
                        .foregroundStyle(Palette.amber)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Palette.amber.opacity(0.16)))
                }
                .buttonStyle(PressableCardStyle())
                .padding(.bottom, 18)
            }

        case .failed:
            PlaceholderPanel(
                icon: "exclamationmark.triangle.fill",
                title: strings.storesFailedTitle,
                message: strings.storesFailedMessage,
                tint: Palette.amber
            )

        case .empty:
            PlaceholderPanel(
                icon: "bag",
                title: strings.storesEmptyTitle,
                message: strings.storesEmptyMessage,
                tint: Palette.teal
            )

        case .idle, .locating, .searching:
            EmptyView()

        case .results:
            VStack(spacing: 10) {
                ForEach(finder.stores) { store in
                    storeRow(store)
                }
            }
        }
    }

    private func storeRow(_ store: NearbyStore) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Palette.coral.opacity(0.14))
                    .frame(width: 40, height: 40)
                Image(systemName: "bag.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Palette.coral)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(store.name)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(store.distanceLabel(strings))
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(Palette.teal)
                    if let street = store.street, !street.isEmpty {
                        Text("·")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.tertiary)
                        Text(street)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 4)

            Button {
                store.mapItem.openInMaps()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 10, weight: .heavy))
                    Text(strings.openInMapsAction)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(Capsule().fill(Palette.warmGradient))
            }
            .buttonStyle(PressableCardStyle())
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(selected == store ? Palette.surfaceRaised : Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    selected == store ? Palette.coral.opacity(0.45) : Palette.hairline,
                    lineWidth: selected == store ? 1.5 : 1
                )
        )
    }
}
