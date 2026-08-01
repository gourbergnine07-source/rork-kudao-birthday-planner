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

/// Which occasions a list screen is showing.
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

/// Profile a diary invitation pointed at, wrapped so a sheet can key off it.
struct QuickNoteTarget: Identifiable {
    let id: UUID
}

/// Root screen: the grid of occasion cards, plus everything the app schedules.
///
/// The grid is only the surface. This view still owns the navigation stack, the
/// reminder syncing and the routing of every notification tap; the list of
/// profiles now lives one push away, pre-filtered on the card that was tapped.
struct HomeView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(NotificationService.self) private var notifications
    @Environment(BiometricGate.self) private var gate
    @Environment(KudaoIdentity.self) private var identity
    @Environment(SubscriptionService.self) private var subscriptions
    @Query private var profiles: [BirthdayProfile]
    @Query private var shares: [ProfileShare]
    @Query private var archive: [EventRecord]
    @Environment(\.modelContext) private var modelContext

    @State private var isCreatingProfile: Bool = false
    /// Occasion pre-picked by an empty category card.
    @State private var newProfileOccasion: OccasionKind?
    @State private var path: [HomeRoute] = []
    @State private var reviewProfile: BirthdayProfile?
    /// Profile that must open straight on the suggestions tab after "Edit".
    @State private var suggestionsProfileID: UUID?
    /// Profile that must open straight on the message tab after a send reminder.
    @State private var messageProfileID: UUID?
    /// Profile that must open straight on the gallery after the party reminder.
    @State private var galleryProfileID: UUID?
    /// Profile named by a diary invitation, opened straight in the quick composer.
    @State private var quickNoteTarget: QuickNoteTarget?
    @State private var isShowingSettings: Bool = false
    @State private var isShowingMyProfile: Bool = false
    @State private var isJoiningShare: Bool = false
    @State private var unlockFailed: Bool = false
    @State private var isShowingPaywall: Bool = false

    @Environment(\.scenePhase) private var scenePhase

    private var strings: Strings { settings.strings }

    /// One summary per shared profile, computed once for the whole screen.
    private var collaborationMap: [UUID: CollaborationSummary] {
        CollaborationSummary.map(profiles: profiles, shares: shares)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                WarmBackdrop()

                if profiles.isEmpty {
                    emptyState
                } else {
                    HomeGridView(
                        profiles: profiles,
                        collaboration: collaborationMap,
                        onOpenProfile: { profile in
                            open(profile) { push(profile) }
                        },
                        onOpenList: { scope in
                            path.append(.list(scope))
                        },
                        onCreateProfile: { occasion in
                            startCreating(occasion)
                        },
                        onJoinShare: { isJoiningShare = true }
                    )
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
                        libraryButton
                        languageButton
                        settingsButton
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    if !profiles.isEmpty {
                        addButton
                            .padding(.trailing, 20)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    // The banner sits under the action button, never over it.
                    AdBannerView { isShowingPaywall = true }
                }
                .padding(.bottom, 8)
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .list(let scope):
                    ProfileListView(scope: scope, path: $path) { profile in
                        openSuggestions(for: profile)
                    }
                case .profile(let profile):
                    ProfileDetailView(profile: profile, initialTab: initialTab(for: profile))
                case .library:
                    LibraryView()
                }
            }
            .navigationDestination(for: EventRecord.self) { record in
                EventRecordDetailView(record: record)
            }
            .sheet(isPresented: $isCreatingProfile, onDismiss: { newProfileOccasion = nil }) {
                ProfileFormView(profile: nil, initialOccasion: newProfileOccasion)
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
            .sheet(isPresented: $isJoiningShare) {
                JoinShareView()
            }
            .sheet(isPresented: $isShowingPaywall) {
                PaywallView()
            }
            .sheet(item: $quickNoteTarget) { target in
                DiaryQuickNoteView(suggestedProfileID: target.id)
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
        .onChange(of: notifications.pendingDiaryProfileID) { _, pending in
            handleDiaryTap(pending)
        }
        .onChange(of: diarySignature) { _, _ in
            Task { await syncDiaryReminders() }
        }
        .onAppear {
            handleReminderTap(notifications.pendingReviewProfileID)
            handleMessageTap(notifications.pendingMessageProfileID)
            handleGalleryTap(notifications.pendingGalleryProfileID)
            handleDiaryTap(notifications.pendingDiaryProfileID)
        }
    }

    // MARK: - Reminders

    private func syncReminders() async {
        ReminderDefaults.migrateLeadTimes(profiles)
        // A date that has gone by closes its cycle before anything else is scheduled.
        EventArchivist.sync(profiles: profiles, records: archive, context: modelContext)
        await notifications.sync(
            profiles: profiles,
            strings: strings,
            privacy: ReminderPrivacy(hidesSurprisePreviews: settings.hidesSurpriseNotificationPreviews),
            diary: DiaryNudgePlan.make(settings: settings, profiles: profiles)
        )
        WidgetBridge.publish(profiles: profiles, settings: settings)
    }

    /// Reschedules only the diary invitations after a preference changes.
    private func syncDiaryReminders() async {
        await notifications.syncDiaryReminders(
            plan: DiaryNudgePlan.make(settings: settings, profiles: profiles),
            strings: strings
        )
    }

    /// Everything that changes when, or whether, a diary invitation should fire.
    private var diarySignature: String {
        [
            settings.wantsDiaryReminders ? "1" : "0",
            settings.diaryReminderCadence.rawValue,
            String(settings.diaryReminderHour),
            String(settings.diaryReminderMinute),
            String(profiles.filter(\.wantsDiaryNudges).count),
        ].joined(separator: "|")
    }

    /// Changes that must be mirrored into the scheduled notifications and the widget.
    private var privacySignature: String {
        [
            settings.hidesSurpriseNotificationPreviews ? "1" : "0",
            settings.protectsSurpriseProfiles ? "1" : "0",
            settings.language.rawValue,
        ].joined(separator: "|")
    }

    // MARK: - Notification routing

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
            path = [.profile(match)]
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
            path = [.profile(match)]
        }
    }

    /// A tapped diary invitation opens the quick composer, skipping the home grid.
    private func handleDiaryTap(_ pending: UUID?) {
        guard let pending else { return }
        notifications.consumePendingDiary()

        guard let match = profiles.first(where: { $0.id == pending }) else {
            quickNoteTarget = QuickNoteTarget(id: pending)
            return
        }

        path = []
        open(match) { quickNoteTarget = QuickNoteTarget(id: match.id) }
    }

    private func openSuggestions(for profile: BirthdayProfile) {
        messageProfileID = nil
        galleryProfileID = nil
        suggestionsProfileID = profile.id
        push(profile)
    }

    /// Pushes a profile without disturbing the screens already on the stack.
    private func push(_ profile: BirthdayProfile) {
        guard path.last != .profile(profile) else { return }
        path.append(.profile(profile))
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

    // MARK: - Chrome

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
                startCreating(nil)
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

    /// Opens the form, unless the occasion is one Premium pays for.
    ///
    /// The paywall has to come before the form: asking someone to fill in a
    /// wedding and only then telling them it is locked would be a small
    /// betrayal. A `nil` occasion means the picker inside the form decides,
    /// and that step does its own checking.
    private func startCreating(_ occasion: OccasionKind?) {
        if let occasion, subscriptions.isLocked(occasion) {
            newProfileOccasion = nil
            isShowingPaywall = true
            return
        }
        newProfileOccasion = occasion
        isCreatingProfile = true
    }

    private var addButton: some View {
        Button {
            startCreating(nil)
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

    /// Way into the archive of everything that has already happened.
    private var libraryButton: some View {
        Button {
            path.append(.library)
        } label: {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Palette.clay)
                .overlay(alignment: .topTrailing) {
                    if !archive.isEmpty {
                        Circle()
                            .fill(Palette.amber)
                            .frame(width: 6, height: 6)
                            .offset(x: 4, y: -2)
                    }
                }
        }
        .accessibilityLabel(strings.libraryTitle)
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
