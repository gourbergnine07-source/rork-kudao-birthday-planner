//
//  ProfileDetailView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Full profile screen: header with countdown, diary, preferences and suggestions.
struct ProfileDetailView: View {
    let profile: BirthdayProfile
    /// Tab opened first, used when arriving from a reminder or the home badge.
    var initialTab: ProfileTab = .diary

    @Environment(AppSettings.self) private var settings
    @Environment(NotificationService.self) private var notifications
    @Environment(KudaoIdentity.self) private var identity
    @Environment(CollaborationService.self) private var collaboration
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedTab: ProfileTab?
    @State private var isEditing: Bool = false
    @State private var isShowingSettings: Bool = false
    @State private var isConfirmingDelete: Bool = false
    @State private var pendingDeletion: Bool = false
    @State private var analyzer = DiaryAnalyzer()
    @State private var suggestionEngine = SuggestionEngine()
    @State private var composer = GreetingComposer()
    @State private var gallery = GalleryService()
    @State private var isShowingStores: Bool = false
    @State private var noGiftIdeaAlert: Bool = false
    @State private var linkPreview: GiftLinkPreview?
    @State private var exportingFormat: DiaryExportFormat?
    @State private var exportedFile: ExportedFile?
    @State private var exportFailed: Bool = false
    @State private var isSharingProfile: Bool = false
    @State private var isShowingParticipants: Bool = false
    @State private var shareBlockedAlert: Bool = false
    @Namespace private var tabNamespace

    /// The requested tab, snapped back to one this occasion actually offers.
    private var activeTab: ProfileTab {
        let requested = selectedTab ?? initialTab
        return tabs.contains(requested) ? requested : (tabs.first ?? .diary)
    }

    private var strings: Strings { settings.strings }
    private var countdown: BirthdayCountdown { profile.countdown }
    private var occasion: OccasionKind { profile.occasion }

    /// Tabs available for this occasion. A remembrance has nothing to plan, and
    /// the library only appears once a first cycle has been archived.
    private var tabs: [ProfileTab] {
        ProfileTab.tabs(for: profile.occasion, hasHistory: profile.hasHistory)
    }

    enum ProfileTab: String, CaseIterable, Identifiable {
        case diary
        case preferences
        case suggestions
        case message
        case gallery
        case library

        var id: String { rawValue }

        /// The gift engine is dropped entirely for a remembrance, and an archive
        /// tab would be an empty promise before the first cycle closes.
        static func tabs(for occasion: OccasionKind, hasHistory: Bool) -> [ProfileTab] {
            allCases.filter { tab in
                switch tab {
                case .suggestions: occasion.wantsSuggestions
                case .library: hasHistory
                default: true
                }
            }
        }

        func symbolName(for occasion: OccasionKind) -> String {
            switch self {
            case .diary: occasion.diarySymbolName
            case .preferences: "tag.fill"
            case .suggestions: "sparkles"
            case .message: occasion.messageSymbolName
            case .gallery: "photo.stack.fill"
            case .library: "books.vertical.fill"
            }
        }

        func title(_ strings: Strings, occasion: OccasionKind) -> String {
            switch self {
            case .diary: occasion.diaryTabTitle(strings)
            case .preferences: occasion == .remembrance ? strings.traitsTab : strings.preferencesTab
            case .suggestions: strings.suggestionsTab
            case .message: occasion.messageTabTitle(strings)
            case .gallery: strings.galleryTab
            case .library: strings.libraryTitle
            }
        }
    }

    var body: some View {
        ZStack {
            WarmBackdrop()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 18) {
                        header
                        statsRow
                        contactCard
                        composeButton(proxy)
                        if occasion.wantsSuggestions {
                            giftSection
                        }
                        tabSelector
                            .id(Self.tabsAnchor)
                        tabContent
                            .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(profile.fullName)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 2) {
                    if profile.isCollaborative {
                        participantsButton
                    }
                    settingsMenu
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            ProfileFormView(profile: profile)
        }
        .sheet(isPresented: $isShowingSettings) {
            ProfileSettingsView(profile: profile)
        }
        .sheet(item: $exportedFile) { file in
            ShareSheet(url: file.url)
        }
        .sheet(isPresented: $isSharingProfile) {
            ShareProfileView(profile: profile)
        }
        .sheet(isPresented: $isShowingParticipants) {
            ParticipantsView(profile: profile)
        }
        .sheet(item: $linkPreview) { preview in
            GiftLinkPreviewView(preview: preview)
        }
        .sheet(isPresented: $isShowingStores) {
            if let plan = profile.partyPlan, plan.hasGiftIdea {
                NearbyStoresView(category: plan.shopSearchTerm, giftIdea: plan.giftIdea)
            }
        }
        .alert(strings.noPlanAlertTitle, isPresented: $noGiftIdeaAlert) {
            Button(strings.suggestionsTab) {

                withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
                    selectedTab = .suggestions
                }
            }
            Button(strings.cancelAction, role: .cancel) {}
        } message: {
            Text(strings.noPlanAlertMessage)
        }
        .alert(strings.shareBlockedSurpriseTitle, isPresented: $shareBlockedAlert) {
            Button(strings.doneAction, role: .cancel) {}
        } message: {
            Text(strings.shareBlockedSurpriseMessage)
        }
        .alert(strings.exportFailedTitle, isPresented: $exportFailed) {
            Button(strings.doneAction, role: .cancel) {}
        } message: {
            Text(strings.exportFailedMessage)
        }
        .alert(strings.deleteConfirmTitle, isPresented: $isConfirmingDelete) {
            Button(strings.cancelAction, role: .cancel) {}
            Button(strings.deleteAction, role: .destructive) {
                pendingDeletion = true
                dismiss()
            }
        } message: {
            Text(String(format: strings.deleteConfirmMessageFormat, profile.name))
        }
        .task(id: profile.id) {
            guard profile.isCollaborative else { return }
            await collaboration.sync(
                profile: profile,
                identity: identity,
                strings: strings,
                context: modelContext
            )
        }
        .task(id: diarySignature) {
            await refreshGreetingFromDiary()
        }
        .onDisappear {
            guard pendingDeletion else { return }
            notifications.cancelReminders(for: profile.id)
            CloudTombstones.recordProfile(profile.id)
            modelContext.delete(profile)
        }
        .environment(\.locale, settings.locale)
        .tint(occasion.accent)
    }

    // MARK: - Greeting kept in step with the diary

    /// Fingerprint of the keywords extracted from the diary, notes and tags included.
    private var diarySignature: String {
        GreetingComposer.diarySignature(for: profile)
    }

    /// New notes rewrite the prepared greeting, unless the user edited it by hand.
    private func refreshGreetingFromDiary() async {
        let changed = await composer.refreshFromDiary(
            for: profile,
            language: settings.language,
            context: modelContext
        )
        guard changed else { return }

        // The reminder shows a preview of the greeting, so it follows the new text.
        await notifications.sync(
            profile: profile,
            strings: strings,
            privacy: ReminderPrivacy(hidesSurprisePreviews: settings.hidesSurpriseNotificationPreviews)
        )
    }

    // MARK: - Settings menu

    private var participantsButton: some View {
        Button {
            isShowingParticipants = true
        } label: {
            Image(systemName: "person.2.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Palette.violet)
                .frame(width: 34, height: 34)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(strings.participantsTitle)
    }

    private var settingsMenu: some View {
        Menu {
            if profile.isOwnedByMe {
                Button {
                    isEditing = true
                } label: {
                    Label(strings.editData, systemImage: "pencil")
                }
            }

            Button {
                isShowingSettings = true
            } label: {
                Label(strings.remindersMenuTitle, systemImage: "bell.badge")
            }

            if profile.isOwnedByMe {
                Button {
                    startSharing()
                } label: {
                    Label(strings.shareProfileAction, systemImage: "person.badge.plus")
                }
            }

            if profile.isCollaborative {
                Button {
                    isShowingParticipants = true
                } label: {
                    Label(strings.participantsMenuTitle, systemImage: "person.2")
                }
            }

            Menu {
                ForEach(DiaryExportFormat.allCases) { format in
                    Button {
                        export(format)
                    } label: {
                        Label(format.title(strings), systemImage: format.symbolName)
                    }
                }
            } label: {
                Label(strings.exportSectionTitle, systemImage: "square.and.arrow.up")
            }

            Divider()

            Button(role: .destructive) {
                isConfirmingDelete = true
            } label: {
                Label(strings.deleteProfile, systemImage: "trash")
            }
        } label: {
            if exportingFormat != nil {
                ProgressView()
                    .controlSize(.small)
                    .tint(Palette.coral)
            } else {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.coral)
            }
        }
        .accessibilityLabel(strings.profileSettings)
    }

    /// Builds the diary file off the main actor, then hands it to the share sheet.
    private func export(_ format: DiaryExportFormat) {
        guard exportingFormat == nil else { return }
        exportingFormat = format

        let snapshot = DiaryExportService.snapshot(of: profile)
        let strings = self.strings
        let locale = settings.locale

        Task {
            defer { exportingFormat = nil }
            do {
                let url = try await Task.detached(priority: .userInitiated) {
                    try DiaryExportService.writeFile(
                        snapshot,
                        format: format,
                        strings: strings,
                        locale: locale
                    )
                }.value
                exportedFile = ExportedFile(url: url)
            } catch {
                exportFailed = true
            }
        }
    }

    // MARK: - Header

    /// Anchor the "Send wishes" button scrolls to.
    private static let tabsAnchor = "kudao.profile.tabs"

    private var header: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(occasion.gradient)
                    .frame(height: 116)
                    .overlay {
                        // A remembrance never gets confetti.
                        if countdown.isToday && occasion.isFestive {
                            ConfettiView()
                                .clipShape(.rect(cornerRadius: 30, style: .continuous))
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if profile.isOwnedByMe {
                            editButton
                                .padding(14)
                        } else {
                            KudaoChip(
                                title: profile.myPermission == .view
                                    ? strings.readOnlyBadge
                                    : strings.sharedBadge,
                                systemImage: profile.myPermission.symbolName,
                                tint: .white
                            )
                            .padding(14)
                        }
                    }
                    .padding(.bottom, 60)

                headerAvatar
                    .padding(.top, 58)
            }

            VStack(spacing: 5) {
                Text(profile.fullName)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                if !profile.hasLastName {
                    Text(strings.noLastNameLabel)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    OccasionBadge(occasion: occasion, strings: strings)
                    KudaoChip(
                        title: profile.bondOrRelationshipTitle(strings),
                        systemImage: profile.bondOrRelationshipSymbol,
                        tint: occasion.usesBond ? Palette.sage : profile.relationship.accent
                    )
                    if occasion.wantsAgeBracket {
                        KudaoChip(
                            title: profile.ageBracket.title(strings),
                            systemImage: profile.ageBracket.symbolName,
                            tint: Palette.violet
                        )
                    }
                    if profile.isSurpriseMode {
                        KudaoChip(
                            title: strings.surpriseBadge,
                            systemImage: "eye.slash.fill",
                            tint: Palette.berry
                        )
                    }
                }
                .padding(.top, 3)

                countdownBanner
                    .padding(.top, 5)

                if profile.isCollaborative {
                    participantsStrip
                        .padding(.top, 6)
                } else if profile.isOwnedByMe {
                    inviteStrip
                        .padding(.top, 6)
                }
            }
        }
    }

    /// The photo stays editable for the owner at any time, straight from the header.
    @ViewBuilder
    private var headerAvatar: some View {
        let avatar = AvatarView(
            name: profile.name,
            photoData: profile.photoData,
            size: 116,
            ringColor: Palette.background,
            ringWidth: 5
        )
        .shadow(color: occasion.accent.opacity(0.3), radius: 14, y: 8)

        if profile.isOwnedByMe {
            PhotoSourcePicker(
                onPicked: { data in updatePhoto(data) },
                onRemoved: profile.photoData == nil ? nil : { updatePhoto(nil) }
            ) {
                ZStack(alignment: .bottomTrailing) {
                    avatar

                    Image(systemName: "camera.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(occasion.gradient))
                        .overlay(Circle().strokeBorder(Palette.background, lineWidth: 3))
                }
            }
            .buttonStyle(PressableCardStyle())
        } else {
            avatar
        }
    }

    /// Stores the new photo, refreshes the widget and lets the room know.
    private func updatePhoto(_ data: Data?) {
        withAnimation(.smooth(duration: 0.25)) {
            profile.photoData = data
        }
        try? modelContext.save()

        let settings = self.settings
        let strings = self.strings
        WidgetBridge.publish(profiles: [profile], settings: settings)

        guard profile.isCollaborative else { return }
        Task {
            await collaboration.sync(
                profile: profile,
                identity: identity,
                strings: strings,
                context: modelContext
            )
        }
    }

    // MARK: - Participants

    /// Everyone who can see the profile, tappable to open the participants screen.
    private var participantsStrip: some View {
        let rows = collaboration.shares(for: profile, context: modelContext)
        let people = rows
            .filter { !$0.sharedWithUserID.isEmpty }
            .sorted { lhs, rhs in
                if lhs.isOwner != rhs.isOwner { return lhs.isOwner }
                return lhs.invitedAt < rhs.invitedAt
            }
        let pending = rows.filter { $0.sharedWithUserID.isEmpty && !$0.inviteCode.isEmpty }.count

        return HStack(spacing: 8) {
            Button {
                isShowingParticipants = true
            } label: {
                HStack(spacing: 8) {
                    ParticipantStack(
                        names: people.map(\.displayName),
                        size: 30,
                        ringColor: Palette.surface,
                        maxVisible: 5
                    )

                    VStack(alignment: .leading, spacing: 1) {
                        Text(
                            profile.isOwnedByMe
                                ? String(format: strings.participantsCountFormat, max(people.count, 1))
                                : String(format: strings.sharedByFormat, profile.shareOwnerName)
                        )
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                        if collaboration.isSyncing(profile) {
                            Text(strings.syncingLabel)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.secondary)
                        } else if pending > 0 {
                            Text(String(format: strings.pendingInvitesCountFormat, pending))
                                .font(.system(.caption2, design: .rounded, weight: .semibold))
                                .foregroundStyle(Palette.violet)
                                .lineLimit(1)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.tertiary)
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(Palette.surface))
                .overlay(Capsule().strokeBorder(Palette.violet.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(PressableCardStyle())
            .accessibilityElement(children: .combine)

            // The owner can keep growing the room without opening the menu.
            if profile.isOwnedByMe {
                Button {
                    startSharing()
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Palette.violet))
                        .shadow(color: Palette.violet.opacity(0.3), radius: 8, y: 4)
                }
                .buttonStyle(PressableCardStyle())
                .accessibilityLabel(strings.inviteSomeoneAction)
            }
        }
    }

    /// Nobody has been invited yet: offer it right under the countdown.
    private var inviteStrip: some View {
        Button {
            startSharing()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "person.2.badge.plus.fill")
                    .font(.system(size: 13, weight: .bold))
                Text(strings.inviteSomeoneAction)
                    .font(.system(.caption, design: .rounded, weight: .bold))
            }
            .foregroundStyle(Palette.violet)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Capsule().fill(Palette.violet.opacity(0.12)))
            .overlay(Capsule().strokeBorder(Palette.violet.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(PressableCardStyle())
    }

    /// Surprise profiles under biometric protection never reach another device.
    private func startSharing() {
        guard SharingPolicy.canShareWithCollaborators(
            isSurprise: profile.isSurpriseMode,
            protectsSurprises: settings.protectsSurpriseProfiles
        ) else {
            shareBlockedAlert = true
            return
        }
        isSharingProfile = true
    }

    private var editButton: some View {
        Button {
            isEditing = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "pencil")
                    .font(.system(size: 11, weight: .heavy))
                Text(strings.editAction)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background(Capsule().fill(.white.opacity(0.24)))
            .overlay(Capsule().strokeBorder(.white.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(PressableCardStyle())
    }

    private var countdownBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: countdownSymbol)
                .font(.system(size: 15, weight: .bold))
                .symbolEffect(
                    .bounce,
                    options: reduceMotion || !occasion.isFestive
                        ? .nonRepeating
                        : .repeat(.periodic(delay: 2.5))
                )

            if countdown.isToday {
                Text(occasion.todayTitle(strings))
                    .font(.system(.headline, design: .rounded, weight: .bold))
            } else if countdown.isTomorrow {
                Text(strings.tomorrowLabel)
                    .font(.system(.headline, design: .rounded, weight: .bold))
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(countdown.daysRemaining)")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .contentTransition(.numericText())
                    Text("\(countdown.daysRemaining == 1 ? strings.dayUnit : strings.daysUnit) \(occasion.countdownSuffix(strings))")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                }
            }
        }
        .foregroundStyle(occasion.accent)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Capsule().fill(occasion.accent.opacity(0.13)))
        .overlay(Capsule().strokeBorder(occasion.accent.opacity(0.28), lineWidth: 1))
    }

    private var countdownSymbol: String {
        if occasion == .remembrance { return countdown.isToday ? "leaf.fill" : "hourglass" }
        return countdown.isToday ? "party.popper.fill" : "hourglass"
    }

    /// The reference date and how long ago it was: the two facts people look for first.
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatTile(
                icon: statDateSymbol,
                caption: occasion.dateStatLabel(strings),
                value: settings.dayMonthYear(profile.birthDate),
                tint: occasion == .remembrance ? Palette.dusk : Palette.amber
            )
            StatTile(
                icon: statElapsedSymbol,
                caption: occasion.elapsedStatLabel(strings),
                value: String(format: strings.ageYearsFormat, profile.currentAge),
                tint: occasion == .remembrance ? Palette.sage : Palette.berry
            )
        }
    }

    private var statDateSymbol: String {
        switch occasion {
        case .birthday: "sunrise.fill"
        case .wedding: "infinity"
        case .remembrance: "leaf.fill"
        case .other: "calendar"
        }
    }

    private var statElapsedSymbol: String {
        switch occasion {
        case .birthday: "figure.walk"
        case .wedding: "heart.fill"
        case .remembrance: "hourglass"
        case .other: "clock.fill"
        }
    }

    // MARK: - Contacts & reminder summary

    /// Address, phone and email appear only when filled in; the reminder recap always shows.
    private var contactCard: some View {
        VStack(spacing: 0) {
            if !trimmed(profile.address).isEmpty {
                contactRow(icon: "house.fill", tint: Palette.violet, text: trimmed(profile.address))
            }

            if !trimmed(profile.contactPhone).isEmpty {
                contactDivider(after: !trimmed(profile.address).isEmpty)
                contactRow(
                    icon: "phone.fill",
                    tint: Palette.teal,
                    text: trimmed(profile.contactPhone),
                    link: URL(string: "tel:\(trimmed(profile.contactPhone).filter { $0.isNumber || $0 == "+" })")
                )
            }

            if !trimmed(profile.contactEmail).isEmpty {
                contactDivider(after: profile.hasContactDetails)
                contactRow(
                    icon: "envelope.fill",
                    tint: Palette.amber,
                    text: trimmed(profile.contactEmail),
                    link: URL(string: "mailto:\(trimmed(profile.contactEmail))")
                )
            }

            contactDivider(after: profile.hasContactDetails)
            reminderSummary
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
    }

    @ViewBuilder
    private func contactDivider(after shouldShow: Bool) -> some View {
        if shouldShow {
            Divider()
                .overlay(Palette.hairline)
                .padding(.leading, 52)
        }
    }

    @ViewBuilder
    private func contactRow(icon: String, tint: Color, text: String, link: URL? = nil) -> some View {
        let row = HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 24)

            Text(text)
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            if link != nil {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())

        if let link {
            Button {
                openURL(link)
            } label: { row }
            .buttonStyle(PressableCardStyle())
        } else {
            row
        }
    }

    /// Recap of the reminder set in the profile settings: days before and fire time.
    private var reminderSummary: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: profile.isReminderEnabled ? "bell.fill" : "bell.slash.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(profile.isReminderEnabled ? occasion.accent : .secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(profile.isReminderEnabled ? strings.notificationActiveLabel : strings.notificationOffLabel)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)

                if profile.isReminderEnabled {
                    if profile.reminderDaysBefore <= 0 {
                        Text(strings.reminderOnTheDayLabel)
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                    } else {
                        HStack(spacing: 6) {
                            Text(strings.daysBeforeShortLabel)
                                .foregroundStyle(.secondary)
                            Text("\(profile.reminderDaysBefore)")
                                .foregroundStyle(occasion.accent)
                                .contentTransition(.numericText())
                        }
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                    }

                    HStack(spacing: 6) {
                        Text(strings.hourShortLabel)
                            .foregroundStyle(.secondary)
                        Text(reminderTimeLabel)
                            .foregroundStyle(occasion.accent)
                    }
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                }
            }

            Spacer(minLength: 0)

            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(occasion.accent)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(occasion.accent.opacity(0.12)))
            }
            .buttonStyle(PressableCardStyle())
            .accessibilityLabel(strings.remindersMenuTitle)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    /// Reminders always fire at the same local hour, shown in the user's format.
    private var reminderTimeLabel: String {
        var components = DateComponents()
        components.hour = BirthdayProfile.reminderHour
        components.minute = 0
        let date = Calendar.current.date(from: components) ?? Date()
        return date.formatted(
            Date.FormatStyle(locale: settings.locale)
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.twoDigits)
        )
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Wishes & gift actions

    private func composeButton(_ proxy: ScrollViewProxy) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : .smooth(duration: 0.35)) {
                selectedTab = .message
            }
            composer.generateIfNeeded(
                for: profile,
                language: settings.language,
                context: modelContext
            )
            withAnimation(reduceMotion ? nil : .smooth(duration: 0.45)) {
                proxy.scrollTo(Self.tabsAnchor, anchor: .top)
            }
        } label: {
            HStack(spacing: 9) {
                Image(systemName: occasion.messageSymbolName)
                    .font(.system(size: 15, weight: .bold))
                Text(occasion.composeAction(strings))
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Capsule().fill(occasion.gradient))
            .shadow(color: occasion.accent.opacity(0.35), radius: 14, y: 8)
        }
        .buttonStyle(PressableCardStyle())
    }

    /// The two gift actions plus, when the link earns a commission, the Amazon disclosure.
    private var giftSection: some View {
        VStack(spacing: 10) {
            giftActionsRow

            if shoppingPreview != nil {
                previewBadge
            }

            if isAffiliateLink {
                Label(strings.affiliateDisclosure, systemImage: "info.circle")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
    }

    /// True when the shopping button carries an Associates tag for the active storefront.
    private var isAffiliateLink: Bool {
        settings.earnsAmazonCommission
    }

    /// Chip that reveals the exact URL the shopping button is about to open.
    ///
    /// Affiliate links are opaque, so the destination stays one tap away from
    /// being inspected instead of being taken on trust.
    private var previewBadge: some View {
        Button {
            linkPreview = shoppingPreview
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 11, weight: .bold))
                Text(shoppingHost)
                    .font(.system(.caption2, design: .monospaced))
                    .lineLimit(1)
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(Palette.clay)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(Palette.surfaceRaised))
            .overlay(Capsule().strokeBorder(Palette.hairline, lineWidth: 1))
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel(strings.linkPreviewBadgeLabel)
    }

    /// Host of the pending shopping link, shown on the badge as a spoiler.
    private var shoppingHost: String {
        shoppingPreview?.amazon.url.host()?.replacingOccurrences(of: "www.", with: "") ?? ""
    }

    /// Everything the preview sheet needs, or nil while there is no gift idea yet.
    private var shoppingPreview: GiftLinkPreview? {
        guard let idea = giftIdea,
              let amazon = GiftShopping.destination(
                  for: idea,
                  language: settings.language,
                  affiliateTags: settings.amazonTags
              ) else { return nil }

        return GiftLinkPreview(
            query: idea,
            amazon: amazon,
            web: GiftShopping.webDestination(for: idea, language: settings.language)
        )
    }

    /// Both actions read the gift straight from the generated plan, never from a manual field.
    private var giftActionsRow: some View {
        HStack(spacing: 12) {
            giftActionTile(
                title: isAffiliateLink ? strings.buyOnAmazonAction : strings.buyOnlineAction,
                systemImage: "cart.fill",
                tint: Palette.berry
            ) {
                openShopping()
            }

            giftActionTile(
                title: strings.findStoreAction,
                systemImage: "map.fill",
                tint: Palette.violet
            ) {
                openNearbyStores()
            }
        }
    }

    private func giftActionTile(
        title: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                if let idea = giftIdea {
                    Text(idea)
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(strings.suggestionsTab)
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(giftIdea == nil ? Palette.hairline : tint.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
        }
        .buttonStyle(PressableCardStyle())
    }

    /// The single source of truth for both gift actions: the AI-generated plan.
    private var giftIdea: String? {
        guard let plan = profile.partyPlan, plan.hasGiftIdea else { return nil }
        return plan.giftIdea
    }

    /// Opens the Amazon search for the gift idea in the system browser.
    ///
    /// The query is always the AI-generated `giftIdea`, and the link always leaves
    /// the app — an in-app web view would break the Associates attribution. A
    /// missing tag only drops the commission, it never changes the destination.
    private func openShopping() {
        guard let preview = shoppingPreview else {
            noGiftIdeaAlert = true
            return
        }
        ExternalLink.open(preview.amazon.url)
    }

    private func openNearbyStores() {
        guard giftIdea != nil else {
            noGiftIdeaAlert = true
            return
        }
        isShowingStores = true
    }

    // MARK: - Tabs

    private var tabSelector: some View {
        HStack(spacing: 4) {
            ForEach(tabs) { tab in
                let isSelected = tab == activeTab
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.symbolName(for: occasion))
                            .font(.system(size: 12, weight: .bold))
                        if isSelected {
                            Text(tab.title(strings, occasion: occasion))
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                    }
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .frame(maxWidth: isSelected ? .infinity : nil)
                    .padding(.horizontal, isSelected ? 12 : 16)
                    .padding(.vertical, 11)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(occasion.gradient)
                                .matchedGeometryEffect(id: "tabHighlight", in: tabNamespace)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title(strings, occasion: occasion))
            }
        }
        .padding(5)
        .background(Capsule().fill(Palette.surface))
        .overlay(Capsule().strokeBorder(Palette.hairline, lineWidth: 1))
        .sensoryFeedback(.selection, trigger: activeTab)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case .diary:
            DiaryTabView(profile: profile, analyzer: analyzer)
                .transition(.opacity.combined(with: .offset(y: 8)))
        case .preferences:
            PreferencesTabView(profile: profile)
                .transition(.opacity.combined(with: .offset(y: 8)))
        case .suggestions:
            SuggestionsTabView(profile: profile, engine: suggestionEngine)
                .transition(.opacity.combined(with: .offset(y: 8)))
        case .message:
            MessageTabView(profile: profile, composer: composer)
                .transition(.opacity.combined(with: .offset(y: 8)))
        case .gallery:
            GalleryTabView(profile: profile, gallery: gallery)
                .transition(.opacity.combined(with: .offset(y: 8)))
        case .library:
            ProfileLibraryTabView(profile: profile)
                .transition(.opacity.combined(with: .offset(y: 8)))
        }
    }
}

/// Small metric card shown under the profile header.
private struct StatTile: View {
    let icon: String
    let caption: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(caption)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }
}
