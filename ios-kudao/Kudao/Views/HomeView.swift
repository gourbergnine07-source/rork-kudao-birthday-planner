//
//  HomeView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Ways the birthday list can be ordered. Closest birthday is the default.
enum ProfileSortOrder: String, CaseIterable, Identifiable {
    case nearestBirthday
    case name
    case recentlyAdded

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .nearestBirthday: "calendar.badge.clock"
        case .name: "textformat.abc"
        case .recentlyAdded: "clock.arrow.circlepath"
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .nearestBirthday: strings.sortNearest
        case .name: strings.sortAlphabetical
        case .recentlyAdded: strings.sortRecentlyAdded
        }
    }

    /// Sorts the profiles, always falling back to the name for a stable order.
    func sorted(_ profiles: [BirthdayProfile]) -> [BirthdayProfile] {
        switch self {
        case .nearestBirthday:
            return profiles.sorted { lhs, rhs in
                let left = lhs.countdown.daysRemaining
                let right = rhs.countdown.daysRemaining
                if left == right {
                    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
                }
                return left < right
            }
        case .name:
            return profiles.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .recentlyAdded:
            return profiles.sorted { lhs, rhs in
                if lhs.createdAt == rhs.createdAt {
                    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
                }
                return lhs.createdAt > rhs.createdAt
            }
        }
    }
}

/// Which occasions the home list is showing.
enum OccasionFilter: Hashable, Identifiable {
    case all
    case kind(OccasionKind)

    var id: String {
        switch self {
        case .all: "all"
        case .kind(let kind): kind.rawValue
        }
    }

    static let allCases: [OccasionFilter] = [.all] + OccasionKind.allCases.map { .kind($0) }

    func title(_ strings: Strings) -> String {
        switch self {
        case .all: strings.filterAllOccasions
        case .kind(let kind): kind.pluralTitle(strings)
        }
    }

    var symbolName: String {
        switch self {
        case .all: "square.stack.3d.up.fill"
        case .kind(let kind): kind.symbolName
        }
    }

    @MainActor
    var accent: Color {
        switch self {
        case .all: Palette.coral
        case .kind(let kind): kind.accent
        }
    }

    func matches(_ profile: BirthdayProfile) -> Bool {
        switch self {
        case .all: true
        case .kind(let kind): profile.occasion == kind
        }
    }
}

/// Root screen: the countdown list of saved celebrations.
struct HomeView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(NotificationService.self) private var notifications
    @Environment(BiometricGate.self) private var gate
    @Environment(KudaoIdentity.self) private var identity
    @Query private var profiles: [BirthdayProfile]

    @State private var isCreatingProfile: Bool = false
    @State private var path: [BirthdayProfile] = []
    @State private var appeared: Bool = false
    @State private var searchText: String = ""
    @State private var sortOrder: ProfileSortOrder = .nearestBirthday
    @State private var occasionFilter: OccasionFilter = .all
    @State private var reviewProfile: BirthdayProfile?
    /// Profile that must open straight on the suggestions tab after "Edit".
    @State private var suggestionsProfileID: UUID?
    /// Profile that must open straight on the message tab after a send reminder.
    @State private var messageProfileID: UUID?
    /// Profile that must open straight on the gallery after the party reminder.
    @State private var galleryProfileID: UUID?
    @State private var isShowingSettings: Bool = false
    @State private var isShowingMyProfile: Bool = false
    @State private var unlockFailed: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    private var strings: Strings { settings.strings }

    private var query: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool { !query.isEmpty }

    /// Profiles matching the search field, keeping the date-proximity order.
    private var results: [BirthdayProfile] {
        guard isSearching else { return ordered }
        return ordered.filter { $0.name.localizedStandardContains(query) }
    }

    /// Everything the active occasion filter lets through.
    private var visibleProfiles: [BirthdayProfile] {
        profiles.filter { occasionFilter.matches($0) }
    }

    private var ordered: [BirthdayProfile] {
        sortOrder.sorted(visibleProfiles)
    }

    /// The closest date always leads the hero card, whatever the list order is.
    private var nextUp: BirthdayProfile? {
        ProfileSortOrder.nearestBirthday.sorted(visibleProfiles).first
    }

    /// Profiles inside their reminder window whose party plan is still unconfirmed.
    private var pendingReviews: [BirthdayProfile] {
        ProfileSortOrder.nearestBirthday.sorted(profiles).filter(\.needsPlanConfirmation)
    }

    /// Occasions actually present in the list; a lone-birthday library hides the filter.
    private var presentOccasions: [OccasionKind] {
        OccasionKind.allCases.filter { kind in profiles.contains { $0.occasion == kind } }
    }

    private var showsOccasionFilter: Bool { presentOccasions.count > 1 }

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
                    myProfileButton
                }
                ToolbarItem(placement: .principal) {
                    Text("Kudao")
                        .font(.system(.title3, design: .rounded, weight: .heavy))
                        .foregroundStyle(Palette.coral)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 14) {
                        languageButton
                        settingsButton
                    }
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
                ProfileDetailView(profile: profile, initialTab: initialTab(for: profile))
            }
            .sheet(isPresented: $isCreatingProfile) {
                ProfileFormView(profile: nil)
            }
            .sheet(item: $reviewProfile) { profile in
                PlanConfirmationView(profile: profile) {
                    openSuggestions(for: profile)
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                AppSettingsView()
            }
            .sheet(isPresented: $isShowingMyProfile) {
                MyProfileView()
            }
            .alert(strings.unlockFailedTitle, isPresented: $unlockFailed) {
                Button(strings.doneAction, role: .cancel) {}
            } message: {
                Text(strings.unlockFailedMessage)
            }
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.coral)
        .task(id: profiles.count) {
            await syncReminders()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                Task { await syncReminders() }
            case .background:
                // Surprise profiles re-lock as soon as the app leaves the screen.
                gate.lockAll()
            default:
                break
            }
        }
        .onChange(of: privacySignature) { _, _ in
            Task { await syncReminders() }
        }
        .onChange(of: notifications.pendingReviewProfileID) { _, pending in
            handleReminderTap(pending)
        }
        .onChange(of: notifications.pendingMessageProfileID) { _, pending in
            handleMessageTap(pending)
        }
        .onChange(of: notifications.pendingGalleryProfileID) { _, pending in
            handleGalleryTap(pending)
        }
        .onAppear {
            handleReminderTap(notifications.pendingReviewProfileID)
            handleMessageTap(notifications.pendingMessageProfileID)
            handleGalleryTap(notifications.pendingGalleryProfileID)
        }
    }

    // MARK: - Reminders

    private func syncReminders() async {
        await notifications.sync(
            profiles: profiles,
            strings: strings,
            privacy: ReminderPrivacy(hidesSurprisePreviews: settings.hidesSurpriseNotificationPreviews)
        )
        WidgetBridge.publish(profiles: profiles, settings: settings)
    }

    /// Changes that must be mirrored into the scheduled notifications and the widget.
    private var privacySignature: String {
        [
            settings.hidesSurpriseNotificationPreviews ? "1" : "0",
            settings.protectsSurpriseProfiles ? "1" : "0",
            settings.language.rawValue,
        ].joined(separator: "|")
    }

    /// A tapped reminder opens the confirmation sheet for that profile.
    private func handleReminderTap(_ pending: UUID?) {
        guard let pending, let match = profiles.first(where: { $0.id == pending }) else { return }
        notifications.consumePendingReview()
        path = []
        open(match) { reviewProfile = match }
    }

    /// A tapped send reminder opens the profile straight on its ready-to-send message.
    private func handleMessageTap(_ pending: UUID?) {
        guard let pending, let match = profiles.first(where: { $0.id == pending }) else { return }
        notifications.consumePendingMessage()
        path = []
        open(match) {
            suggestionsProfileID = nil
            messageProfileID = match.id
            path = [match]
        }
    }

    /// A tapped memories reminder opens the profile straight on its party gallery.
    private func handleGalleryTap(_ pending: UUID?) {
        guard let pending, let match = profiles.first(where: { $0.id == pending }) else { return }
        notifications.consumePendingGallery()
        path = []
        open(match) {
            suggestionsProfileID = nil
            messageProfileID = nil
            galleryProfileID = match.id
            path = [match]
        }
    }

    private func openSuggestions(for profile: BirthdayProfile) {
        messageProfileID = nil
        galleryProfileID = nil
        suggestionsProfileID = profile.id
        path = [profile]
    }

    /// Reminder taps and the plan review decide which tab the detail screen opens on.
    private func initialTab(for profile: BirthdayProfile) -> ProfileDetailView.ProfileTab {
        if galleryProfileID == profile.id { return .gallery }
        if messageProfileID == profile.id { return .message }
        if suggestionsProfileID == profile.id { return .suggestions }
        return .diary
    }

    // MARK: - Surprise lock

    private func isLocked(_ profile: BirthdayProfile) -> Bool {
        settings.requiresUnlock(profile) && !gate.isUnlocked(profile.id)
    }

    /// Runs `action` immediately, or behind Face ID / Touch ID / passcode for protected surprises.
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

    /// Regular rows push straight away; protected surprises authenticate first.
    @ViewBuilder
    private func profileLink<Content: View>(
        _ profile: BirthdayProfile,
        @ViewBuilder label: () -> Content
    ) -> some View {
        if isLocked(profile) {
            Button {
                open(profile) { path.append(profile) }
            } label: {
                label()
            }
            .buttonStyle(PressableCardStyle())
            .accessibilityHint(strings.lockedBadgeLabel)
        } else {
            NavigationLink(value: profile) {
                label()
            }
            .buttonStyle(PressableCardStyle())
        }
    }

    // MARK: - Sections

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                HStack(spacing: 10) {
                    SearchField(
                        placeholder: strings.searchPlaceholder,
                        clearLabel: strings.searchClear,
                        text: $searchText
                    )
                    sortMenu
                }

                if showsOccasionFilter {
                    occasionFilterStrip
                }

                if isSearching {
                    searchResults
                } else if visibleProfiles.isEmpty {
                    filteredEmptyState
                } else {
                    reviewBanner
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

    /// Horizontal chips: Tutti, Compleanni, Matrimoni, Commemorazioni, Altro.
    private var occasionFilterStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(availableFilters) { filter in
                    occasionChip(filter)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .sensoryFeedback(.selection, trigger: occasionFilter)
    }

    /// Only offer a chip for an occasion the user actually has.
    private var availableFilters: [OccasionFilter] {
        [.all] + presentOccasions.map { OccasionFilter.kind($0) }
    }

    private func occasionChip(_ filter: OccasionFilter) -> some View {
        let isActive = occasionFilter == filter
        let count = filter == .all ? profiles.count : profiles.filter { filter.matches($0) }.count

        return Button {
            withAnimation(reduceMotion ? nil : .smooth(duration: 0.28)) {
                occasionFilter = filter
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: filter.symbolName)
                    .font(.system(size: 11, weight: .bold))
                Text(filter.title(strings))
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .lineLimit(1)
                Text("\(count)")
                    .font(.system(.caption2, design: .rounded, weight: .heavy).monospacedDigit())
                    .opacity(0.7)
            }
            .foregroundStyle(isActive ? Color.white : filter.accent)
            .padding(.horizontal, 13)
            .padding(.vertical, 9)
            .background(
                Capsule().fill(
                    isActive
                        ? AnyShapeStyle(filter.accent)
                        : AnyShapeStyle(filter.accent.opacity(0.12))
                )
            )
            .overlay(
                Capsule().strokeBorder(
                    isActive ? Color.clear : filter.accent.opacity(0.28),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }

    /// The library is not empty, this corner of it is.
    private var filteredEmptyState: some View {
        PlaceholderPanel(
            icon: occasionFilter.symbolName,
            title: strings.filterEmptyTitle,
            message: String(format: strings.filterEmptyMessageFormat, occasionFilter.title(strings))
        )
        .padding(.top, 4)
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
                        ProfileRowCard(profile: profile, settings: settings, isLocked: isLocked(profile))
                    }
                }
            }
        }
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
                            .symbolEffect(
                                .bounce,
                                options: reduceMotion ? .nonRepeating : .repeat(.periodic(delay: 3))
                            )
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
            .shadow(color: Palette.coral.opacity(0.12), radius: 12, y: 6)
        }
    }

    @ViewBuilder
    private var upcomingSections: some View {
        if let hero = nextUp {
            Text(strings.upNext.uppercased())
                .font(.system(.caption, design: .rounded, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(.secondary)

            profileLink(hero) {
                HeroProfileCard(profile: hero, settings: settings, isLocked: isLocked(hero))
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
                        ProfileRowCard(profile: profile, settings: settings, isLocked: isLocked(profile))
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
                Image(systemName: "sparkles")
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

    /// The user's own corner of the app: avatar, defaults, privacy, account.
    private var myProfileButton: some View {
        Button {
            isShowingMyProfile = true
        } label: {
            AvatarView(
                name: identity.hasName ? identity.trimmedName : "?",
                photoData: identity.photoData,
                size: 32,
                ringColor: Palette.coral.opacity(0.35),
                ringWidth: 1.5
            )
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel(strings.myProfileTitle)
    }

    /// Quick language switch, kept separate from everything else.
    private var languageButton: some View {
        @Bindable var bindable = settings

        return Menu {
            Picker(strings.languageLabel, selection: $bindable.language) {
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
        .sensoryFeedback(.selection, trigger: settings.language)
    }

    private var settingsButton: some View {
        Button {
            isShowingSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Palette.coral)
                .overlay(alignment: .topTrailing) {
                    if settings.protectsSurpriseProfiles {
                        Circle()
                            .fill(Palette.berry)
                            .frame(width: 6, height: 6)
                            .offset(x: 3, y: -2)
                    }
                }
        }
        .accessibilityLabel(strings.appSettingsMenu)
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
        .environment(NotificationService.shared)
        .environment(BiometricGate.shared)
        .environment(KudaoIdentity.shared)
        .environment(CloudBackupService())
        .environment(AuthService())
        .modelContainer(KudaoModelContainer.preview())
}
