//
//  ProfileListView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Which slice of the library a pushed list screen is showing.
///
/// The grid is the front door; every card opens this same list with a different
/// slice, so search, sorting and the hero card behave identically everywhere.
enum ProfileListScope: Hashable {
    case occasion(OccasionFilter)
    case pendingPlans
    case shared

    func title(_ strings: Strings) -> String {
        switch self {
        case .occasion(let filter): filter.title(strings)
        case .pendingPlans: strings.reviewBannerTitle
        case .shared: strings.sharedListTitle
        }
    }

    var symbolName: String {
        switch self {
        case .occasion(let filter): filter.symbolName
        case .pendingPlans: "checkmark.seal.fill"
        case .shared: "person.2.fill"
        }
    }

    @MainActor
    var accent: Color {
        switch self {
        case .occasion(let filter): filter.accent
        case .pendingPlans: Palette.amber
        case .shared: Palette.violet
        }
    }

    /// The occasion this scope is pinned to, when it is pinned to one.
    var occasionKind: OccasionKind? {
        if case .occasion(.kind(let kind)) = self { return kind }
        return nil
    }

    func matches(_ profile: BirthdayProfile) -> Bool {
        switch self {
        case .occasion(let filter): filter.matches(profile)
        case .pendingPlans: profile.needsPlanConfirmation
        case .shared: profile.isCollaborative
        }
    }

    func emptyMessage(_ strings: Strings) -> String {
        switch self {
        case .occasion(let filter): String(format: strings.filterEmptyMessageFormat, filter.title(strings))
        case .pendingPlans: strings.pendingScopeEmptyMessage
        case .shared: strings.sharedScopeEmptyMessage
        }
    }
}

/// Quick time windows layered on top of a list scope.
///
/// These read the *next* occurrence rather than the original date, so a
/// birthday in March counts as "this month" during any March — which is what
/// somebody scanning the list is actually asking about.
enum OccasionWindow: String, CaseIterable, Identifiable {
    case all
    case thisMonth
    case nextWeek

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .all: "square.stack.3d.up.fill"
        case .thisMonth: "calendar"
        case .nextWeek: "clock.badge.fill"
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .all: strings.timeFilterAll
        case .thisMonth: strings.timeFilterThisMonth
        case .nextWeek: strings.timeFilterNextWeek
        }
    }

    func matches(
        _ profile: BirthdayProfile,
        reference: Date = Date(),
        calendar: Calendar = .current
    ) -> Bool {
        switch self {
        case .all:
            return true
        case .thisMonth:
            // Year and month together, so next January never passes for this one.
            return calendar.isDate(profile.countdown.nextDate, equalTo: reference, toGranularity: .month)
        case .nextWeek:
            return profile.countdown.isThisWeek
        }
    }
}

/// Everything the home navigation stack can push.
enum HomeRoute: Hashable {
    case list(ProfileListScope)
    case profile(BirthdayProfile)
    /// The archive of every cycle that has already been closed.
    case library
}

/// The classic Kudao list: search, the hero "up next" card and everything after it.
///
/// It used to be the root screen. It now lives one level below the grid, always
/// pre-filtered on the card the user tapped.
struct ProfileListView: View {
    let scope: ProfileListScope
    @Binding var path: [HomeRoute]
    /// Called when a plan review ends on "help me decide".
    let onReviewSuggestions: (BirthdayProfile) -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(BiometricGate.self) private var gate
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Query private var allProfiles: [BirthdayProfile]
    @Query private var shares: [ProfileShare]

    @State private var searchText: String = ""
    @State private var sortOrder: ProfileSortOrder = .nearestBirthday
    @State private var window: OccasionWindow = .all
    @State private var reviewProfile: BirthdayProfile?
    @State private var appeared: Bool = false
    @State private var unlockFailed: Bool = false

    private var strings: Strings { settings.strings }

    private var query: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool { !query.isEmpty }

    /// Everything this screen is allowed to show, before window, search and sorting.
    private var scopedProfiles: [BirthdayProfile] {
        allProfiles.filter { scope.matches($0) }
    }

    /// The scope narrowed to the selected time window.
    private var windowed: [BirthdayProfile] {
        guard window != .all else { return scopedProfiles }
        return scopedProfiles.filter { window.matches($0) }
    }

    private var ordered: [BirthdayProfile] {
        sortOrder.sorted(windowed)
    }

    /// Search deliberately ignores the time window: hiding a name somebody just
    /// typed, because of a filter they forgot about, would read as a bug.
    private var results: [BirthdayProfile] {
        guard isSearching else { return ordered }
        return sortOrder.sorted(scopedProfiles).filter { $0.name.localizedStandardContains(query) }
    }

    /// The closest date always leads, whatever the list order is.
    private var nextUp: BirthdayProfile? {
        ProfileSortOrder.nearestBirthday.sorted(windowed).first
    }

    /// Profiles in this scope whose party plan still needs a yes.
    private var pendingReviews: [BirthdayProfile] {
        guard scope != .pendingPlans else { return [] }
        return ProfileSortOrder.nearestBirthday.sorted(scopedProfiles).filter(\.needsPlanConfirmation)
    }

    private var collaborationMap: [UUID: CollaborationSummary] {
        CollaborationSummary.map(profiles: scopedProfiles, shares: shares)
    }

    var body: some View {
        ZStack {
            WarmBackdrop()

            if scopedProfiles.isEmpty {
                emptyScope
            } else {
                content
            }
        }
        .navigationTitle(scope.title(strings))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $reviewProfile) { profile in
            PlanConfirmationView(profile: profile) {
                onReviewSuggestions(profile)
            }
        }
        .alert(strings.unlockFailedTitle, isPresented: $unlockFailed) {
            Button(strings.doneAction, role: .cancel) {}
        } message: {
            Text(strings.unlockFailedMessage)
        }
    }

    // MARK: - Sections

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                scopeHeader

                HStack(spacing: 10) {
                    SearchField(
                        placeholder: strings.searchPlaceholder,
                        clearLabel: strings.searchClear,
                        text: $searchText
                    )
                    sortMenu
                }

                if isSearching {
                    searchResults
                } else {
                    windowFilter
                    reviewBanner
                    upcomingSections
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .onAppear { appeared = true }
    }

    /// Coloured strip naming the slice, so the screen never feels detached from its card.
    private var scopeHeader: some View {
        HStack(spacing: 11) {
            ZStack {
                Circle()
                    .fill(scope.accent.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: scope.symbolName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(scope.accent)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(scope.title(strings))
                    .font(.system(.title3, design: .rounded, weight: .heavy))
                Text(countCaption)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }

    private var countCaption: String {
        scopedProfiles.count == 1
            ? strings.gridProfileCountOne
            : String(format: strings.gridProfileCountFormat, scopedProfiles.count)
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
                    profileLink(profile) {
                        ProfileRowCard(
                            profile: profile,
                            settings: settings,
                            isLocked: isLocked(profile),
                            collaboration: summary(for: profile)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Time window

    /// Three chips: everything, this calendar month, the next seven days. Each
    /// carries its own count, so "who is coming up?" is already answered before
    /// anything is tapped.
    private var windowFilter: some View {
        HStack(spacing: 8) {
            ForEach(OccasionWindow.allCases) { option in
                windowChip(option)
            }
            Spacer(minLength: 0)
        }
        .animation(reduceMotion ? nil : .smooth(duration: 0.25), value: window)
        .sensoryFeedback(.selection, trigger: window)
    }

    private func windowChip(_ option: OccasionWindow) -> some View {
        let isSelected = window == option
        let total = count(for: option)
        let isEmpty = total == 0 && option != .all

        return Button {
            // Tapping the active chip goes back to the full list.
            window = isSelected ? .all : option
        } label: {
            HStack(spacing: 6) {
                Image(systemName: option.symbolName)
                    .font(.system(size: 10, weight: .black))

                Text(option.title(strings))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .lineLimit(1)

                if option != .all {
                    Text(total.formatted())
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(isSelected ? Color.white : scope.accent)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            Capsule().fill(
                                isSelected ? Color.white.opacity(0.24) : scope.accent.opacity(0.14)
                            )
                        )
                }
            }
            .foregroundStyle(isSelected ? Color.white : (isEmpty ? Color.secondary : Color.primary))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Capsule().fill(isSelected ? scope.accent : Palette.surface))
            .overlay(
                Capsule().strokeBorder(isSelected ? Color.clear : Palette.hairline, lineWidth: 1)
            )
            .shadow(color: scope.accent.opacity(isSelected ? 0.28 : 0), radius: 8, y: 4)
            .opacity(isEmpty && !isSelected ? 0.55 : 1)
        }
        .buttonStyle(PressableCardStyle())
        .disabled(isEmpty && !isSelected)
        .accessibilityLabel(option == .all ? option.title(strings) : "\(option.title(strings)), \(total)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private func count(for option: OccasionWindow) -> Int {
        guard option != .all else { return scopedProfiles.count }
        return scopedProfiles.reduce(into: 0) { total, profile in
            if option.matches(profile) { total += 1 }
        }
    }

    // MARK: - Results

    @ViewBuilder
    private var upcomingSections: some View {
        if window == .all {
            heroAndRest
        } else {
            filteredResults
        }
    }

    /// A narrowed window is a question with a short answer, so it drops the hero
    /// card and simply lists what falls inside.
    @ViewBuilder
    private var filteredResults: some View {
        if ordered.isEmpty {
            PlaceholderPanel(
                icon: window.symbolName,
                title: strings.timeFilterEmptyTitle,
                message: String(
                    format: strings.timeFilterEmptyMessageFormat,
                    window.title(strings).lowercased()
                )
            )
            .padding(.top, 4)
        } else {
            HStack(spacing: 6) {
                Text(window.title(strings).uppercased())
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .tracking(1.1)
                Text("·")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                Text(
                    ordered.count == 1
                        ? strings.gridProfileCountOne
                        : String(format: strings.gridProfileCountFormat, ordered.count)
                )
                .font(.system(.caption, design: .rounded, weight: .medium))
            }
            .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(ordered) { profile in
                    profileLink(profile) {
                        ProfileRowCard(
                            profile: profile,
                            settings: settings,
                            isLocked: isLocked(profile),
                            collaboration: summary(for: profile)
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var heroAndRest: some View {
        if let hero = nextUp {
            Text(strings.upNext.uppercased())
                .font(.system(.caption, design: .rounded, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(.secondary)

            profileLink(hero) {
                HeroProfileCard(
                    profile: hero,
                    settings: settings,
                    isLocked: isLocked(hero),
                    collaboration: summary(for: hero)
                )
            }
        }

        let rest = ordered.filter { $0.id != nextUp?.id }

        if !rest.isEmpty {
            HStack(spacing: 6) {
                Text(strings.othersSection.uppercased())
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .tracking(1.1)
                Text("·")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                Text(sortOrder.title(strings))
                    .font(.system(.caption, design: .rounded, weight: .medium))
            }
            .foregroundStyle(.secondary)
            .padding(.top, 6)

            VStack(spacing: 12) {
                ForEach(Array(rest.enumerated()), id: \.element.id) { index, profile in
                    profileLink(profile) {
                        ProfileRowCard(
                            profile: profile,
                            settings: settings,
                            isLocked: isLocked(profile),
                            collaboration: summary(for: profile)
                        )
                    }
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

    @ViewBuilder
    private var reviewBanner: some View {
        let pending = pendingReviews

        if !pending.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 9) {
                    ZStack {
                        Circle()
                            .fill(Palette.coral.opacity(0.16))
                            .frame(width: 30, height: 30)
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Palette.coral)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(strings.reviewBannerTitle)
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                        Text(String(format: strings.reviewBannerSubtitleFormat, pending.count))
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }

                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(pending) { profile in
                            Button {
                                open(profile) { reviewProfile = profile }
                            } label: {
                                HStack(spacing: 8) {
                                    AvatarView(name: profile.name, photoData: profile.photoData, size: 26)
                                    Text(profile.name)
                                        .font(.system(.footnote, design: .rounded, weight: .bold))
                                        .lineLimit(1)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundStyle(.tertiary)
                                }
                                .foregroundStyle(.primary)
                                .padding(.leading, 6)
                                .padding(.trailing, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Palette.surfaceRaised))
                                .overlay(Capsule().strokeBorder(Palette.coral.opacity(0.28), lineWidth: 1))
                            }
                            .buttonStyle(PressableCardStyle())
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Palette.coral.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var emptyScope: some View {
        PlaceholderPanel(
            icon: scope.symbolName,
            title: strings.filterEmptyTitle,
            message: scope.emptyMessage(strings)
        )
        .padding(.horizontal, 24)
    }

    private var sortMenu: some View {
        Menu {
            Picker(strings.sortLabel, selection: $sortOrder) {
                ForEach(ProfileSortOrder.allCases) { order in
                    Label(order.title(strings), systemImage: order.symbolName).tag(order)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(sortOrder == .nearestBirthday ? Color.secondary : Palette.coral)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Palette.surface))
                .overlay(
                    Circle().strokeBorder(
                        sortOrder == .nearestBirthday ? Palette.hairline : Palette.coral.opacity(0.5),
                        lineWidth: 1
                    )
                )
        }
        .accessibilityLabel("\(strings.sortLabel): \(sortOrder.title(strings))")
        .sensoryFeedback(.selection, trigger: sortOrder)
    }

    // MARK: - Navigation and locking

    private func summary(for profile: BirthdayProfile) -> CollaborationSummary {
        collaborationMap[profile.id] ?? .none
    }

    private func isLocked(_ profile: BirthdayProfile) -> Bool {
        settings.requiresUnlock(profile) && !gate.isUnlocked(profile.id)
    }

    /// Runs `action` immediately, or behind Face ID / Touch ID for protected surprises.
    private func open(_ profile: BirthdayProfile, action: @escaping () -> Void) {
        guard isLocked(profile) else {
            action()
            return
        }

        let reason = String(format: strings.unlockReasonFormat, profile.name)
        let profileID = profile.id
        Task {
            if await gate.unlock(profileID: profileID, reason: reason) {
                action()
            } else {
                unlockFailed = true
            }
        }
    }

    @ViewBuilder
    private func profileLink<Content: View>(
        _ profile: BirthdayProfile,
        @ViewBuilder label: () -> Content
    ) -> some View {
        if isLocked(profile) {
            Button {
                open(profile) { path.append(.profile(profile)) }
            } label: {
                label()
            }
            .buttonStyle(PressableCardStyle())
            .accessibilityHint(strings.lockedBadgeLabel)
        } else {
            NavigationLink(value: HomeRoute.profile(profile)) {
                label()
            }
            .buttonStyle(PressableCardStyle())
        }
    }
}
