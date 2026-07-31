//
//  HomeView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Root screen: every celebration profile ordered by how close the birthday is.
struct HomeView: View {
    @Environment(AppSettings.self) private var settings
    @Query private var profiles: [BirthdayProfile]

    @State private var isCreatingProfile: Bool = false
    @State private var path: [BirthdayProfile] = []
    @State private var appeared: Bool = false
    @State private var searchText: String = ""

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var strings: Strings { settings.strings }

    private var query: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool { !query.isEmpty }

    /// Profiles matching the search field, keeping the birthday-proximity order.
    private var results: [BirthdayProfile] {
        guard isSearching else { return ordered }
        return ordered.filter { $0.name.localizedStandardContains(query) }
    }

    private var ordered: [BirthdayProfile] {
        profiles.sorted { lhs, rhs in
            let left = lhs.countdown
            let right = rhs.countdown
            if left.daysRemaining == right.daysRemaining {
                return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            }
            return left.daysRemaining < right.daysRemaining
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                WarmBackdrop()

                if profiles.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Kudao")
                        .font(.system(.title3, design: .rounded, weight: .heavy))
                        .foregroundStyle(Palette.coral)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    languageMenu
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !profiles.isEmpty {
                    addButton
                        .padding(.trailing, 20)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .navigationDestination(for: BirthdayProfile.self) { profile in
                ProfileDetailView(profile: profile)
            }
            .sheet(isPresented: $isCreatingProfile) {
                ProfileFormView(profile: nil)
            }
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.coral)
    }

    // MARK: - Sections

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                SearchField(
                    placeholder: strings.searchPlaceholder,
                    clearLabel: strings.searchClear,
                    text: $searchText
                )

                if isSearching {
                    searchResults
                } else {
                    upcomingSections
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 90)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .onAppear { appeared = true }
    }

    @ViewBuilder
    private var searchResults: some View {
        if results.isEmpty {
            PlaceholderPanel(
                icon: "magnifyingglass",
                title: strings.noResultsTitle,
                message: String(format: strings.noResultsMessageFormat, query)
            )
            .padding(.top, 4)
        } else {
            Text(strings.resultsSection.uppercased())
                .font(.system(.caption, design: .rounded, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(results) { profile in
                    NavigationLink(value: profile) {
                        ProfileRowCard(profile: profile, settings: settings)
                    }
                    .buttonStyle(PressableCardStyle())
                }
            }
        }
    }

    @ViewBuilder
    private var upcomingSections: some View {
        if let hero = ordered.first {
            Text(strings.upNext.uppercased())
                .font(.system(.caption, design: .rounded, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(.secondary)

            NavigationLink(value: hero) {
                HeroProfileCard(profile: hero, settings: settings)
            }
            .buttonStyle(PressableCardStyle())
        }

        if ordered.count > 1 {
            Text(strings.othersSection.uppercased())
                .font(.system(.caption, design: .rounded, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(.secondary)
                .padding(.top, 6)

            VStack(spacing: 12) {
                ForEach(Array(ordered.dropFirst().enumerated()), id: \.element.id) { index, profile in
                    NavigationLink(value: profile) {
                        ProfileRowCard(profile: profile, settings: settings)
                    }
                    .buttonStyle(PressableCardStyle())
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 18)
                    .animation(
                        reduceMotion ? nil : .smooth(duration: 0.45).delay(Double(index) * 0.05),
                        value: appeared
                    )
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(strings.homeTitle)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(.primary)
            Text(strings.homeSubtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Palette.warmGradient)
                    .frame(width: 108, height: 108)
                    .shadow(color: Palette.coral.opacity(0.35), radius: 20, y: 10)
                Image(systemName: "birthday.cake.fill")
                    .font(.system(size: 46, weight: .medium))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 8) {
                Text(strings.emptyTitle)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Text(strings.emptyMessage)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                isCreatingProfile = true
            } label: {
                Label(strings.emptyAction, systemImage: "plus")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Palette.warmGradient))
                    .shadow(color: Palette.coral.opacity(0.35), radius: 14, y: 8)
            }
            .buttonStyle(PressableCardStyle())
        }
        .padding(.horizontal, 36)
    }

    private var addButton: some View {
        Button {
            isCreatingProfile = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Circle().fill(Palette.warmGradient))
                .shadow(color: Palette.coral.opacity(0.42), radius: 16, y: 8)
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel(strings.newProfileTitle)
    }

    private var languageMenu: some View {
        @Bindable var bindableSettings = settings
        return Menu {
            Picker(strings.languageLabel, selection: $bindableSettings.language) {
                ForEach(AppLanguage.allCases) { language in
                    Text("\(language.flag)  \(language.displayName)").tag(language)
                }
            }
        } label: {
            Image(systemName: "globe")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Palette.coral)
        }
        .accessibilityLabel(strings.languageLabel)
    }
}

/// Card-friendly button style: scales and dims slightly on press.
struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
            .sensoryFeedback(.selection, trigger: configuration.isPressed)
    }
}

#Preview {
    HomeView()
        .environment(AppSettings())
        .modelContainer(for: [BirthdayProfile.self, DiaryEntry.self, DiaryTag.self], inMemory: true)
}
