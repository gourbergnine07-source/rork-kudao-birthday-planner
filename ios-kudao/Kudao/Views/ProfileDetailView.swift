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
    @State private var exportingFormat: DiaryExportFormat?
    @State private var exportedFile: ExportedFile?
    @State private var exportFailed: Bool = false
    @State private var isSharingProfile: Bool = false
    @State private var isShowingParticipants: Bool = false
    @State private var shareBlockedAlert: Bool = false
    @Namespace private var tabNamespace

    private var activeTab: ProfileTab { selectedTab ?? initialTab }

    private var strings: Strings { settings.strings }
    private var countdown: BirthdayCountdown { profile.countdown }

    enum ProfileTab: String, CaseIterable, Identifiable {
        case diary
        case preferences
        case suggestions
        case message
        case gallery

        var id: String { rawValue }

        var symbolName: String {
            switch self {
            case .diary: "book.closed.fill"
            case .preferences: "tag.fill"
            case .suggestions: "sparkles"
            case .message: "paperplane.fill"
            case .gallery: "photo.stack.fill"
            }
        }

        func title(_ strings: Strings) -> String {
            switch self {
            case .diary: strings.diaryTab
            case .preferences: strings.preferencesTab
            case .suggestions: strings.suggestionsTab
            case .message: strings.messageTab
            case .gallery: strings.galleryTab
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
                        sendWishesButton(proxy)
                        giftActionsRow
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
            modelContext.delete(profile)
        }
        .environment(\.locale, settings.locale)
        .tint(Palette.coral)
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
                    .fill(Palette.warmGradient)
                    .frame(height: 116)
                    .overlay {
                        if countdown.isToday {
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

                AvatarView(
                    name: profile.name,
                    photoData: profile.photoData,
                    size: 116,
                    ringColor: Palette.background,
                    ringWidth: 5
                )
                .shadow(color: Palette.coral.opacity(0.3), radius: 14, y: 8)
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
                    KudaoChip(
                        title: profile.relationship.title(strings),
                        systemImage: profile.relationship.symbolName,
                        tint: profile.relationship.accent
                    )
                    KudaoChip(
                        title: profile.ageBracket.title(strings),
                        systemImage: profile.ageBracket.symbolName,
                        tint: Palette.violet
                    )
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
                }
            }
        }
    }

    // MARK: - Participants

    /// Everyone who can see the profile, tappable to open the participants screen.
    private var participantsStrip: some View {
        let people = collaboration
            .shares(for: profile, context: modelContext)
            .filter { !$0.sharedWithUserID.isEmpty }
            .sorted { lhs, rhs in
                if lhs.isOwner != rhs.isOwner { return lhs.isOwner }
                return lhs.invitedAt < rhs.invitedAt
            }
        let visible = Array(people.prefix(5))
        let extra = max(0, people.count - visible.count)

        return Button {
            isShowingParticipants = true
        } label: {
            HStack(spacing: 8) {
                HStack(spacing: -10) {
                    ForEach(visible) { share in
                        AvatarView(
                            name: share.displayName.isEmpty ? "?" : share.displayName,
                            photoData: nil,
                            size: 30,
                            ringColor: Palette.surface,
                            ringWidth: 2
                        )
                    }

                    if extra > 0 {
                        Text("+\(extra)")
                            .font(.system(.caption2, design: .rounded, weight: .heavy))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Palette.surfaceRaised))
                            .overlay(Circle().strokeBorder(Palette.surface, lineWidth: 2))
                    }
                }

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
            .overlay(Capsule().strokeBorder(Palette.hairline, lineWidth: 1))
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
            Image(systemName: countdown.isToday ? "party.popper.fill" : "hourglass")
                .font(.system(size: 15, weight: .bold))
                .symbolEffect(.bounce, options: reduceMotion ? .nonRepeating : .repeat(.periodic(delay: 2.5)))

            if countdown.isToday {
                Text(strings.todayTitle)
                    .font(.system(.headline, design: .rounded, weight: .bold))
            } else if countdown.isTomorrow {
                Text(strings.tomorrowLabel)
                    .font(.system(.headline, design: .rounded, weight: .bold))
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(countdown.daysRemaining)")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .contentTransition(.numericText())
                    Text("\(countdown.daysRemaining == 1 ? strings.dayUnit : strings.daysUnit) \(strings.daysToGo)")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                }
            }
        }
        .foregroundStyle(Palette.coral)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Capsule().fill(Palette.coral.opacity(0.13)))
        .overlay(Capsule().strokeBorder(Palette.coral.opacity(0.28), lineWidth: 1))
    }

    /// "Nascita" and "Et\u{00E0}" side by side, exactly the two facts people look for first.
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatTile(
                icon: "sunrise.fill",
                caption: strings.birthLabel,
                value: settings.dayMonthYear(profile.birthDate),
                tint: Palette.amber
            )
            StatTile(
                icon: "figure.walk",
                caption: strings.ageLabel,
                value: String(format: strings.ageYearsFormat, profile.currentAge),
                tint: Palette.berry
            )
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
                .foregroundStyle(profile.isReminderEnabled ? Palette.coral : .secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(profile.isReminderEnabled ? strings.notificationActiveLabel : strings.notificationOffLabel)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)

                if profile.isReminderEnabled {
                    HStack(spacing: 6) {
                        Text(strings.daysBeforeShortLabel)
                            .foregroundStyle(.secondary)
                        Text("\(profile.reminderDaysBefore)")
                            .foregroundStyle(Palette.coral)
                            .contentTransition(.numericText())
                    }
                    .font(.system(.footnote, design: .rounded, weight: .semibold))

                    HStack(spacing: 6) {
                        Text(strings.hourShortLabel)
                            .foregroundStyle(.secondary)
                        Text(reminderTimeLabel)
                            .foregroundStyle(Palette.coral)
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
                    .foregroundStyle(Palette.coral)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Palette.coral.opacity(0.12)))
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

    private func sendWishesButton(_ proxy: ScrollViewProxy) -> some View {
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
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 15, weight: .bold))
                Text(strings.sendWishesAction)
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Capsule().fill(Palette.warmGradient))
            .shadow(color: Palette.coral.opacity(0.35), radius: 14, y: 8)
        }
        .buttonStyle(PressableCardStyle())
    }

    /// Both actions read the gift straight from the generated plan, never from a manual field.
    private var giftActionsRow: some View {
        HStack(spacing: 12) {
            giftActionTile(
                title: strings.buyOnlineAction,
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

    private func openShopping() {
        guard let idea = giftIdea,
              let url = GiftShopping.searchURL(for: idea, language: settings.language) else {
            noGiftIdeaAlert = true
            return
        }
        openURL(url)
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
            ForEach(ProfileTab.allCases) { tab in
                let isSelected = tab == activeTab
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.symbolName)
                            .font(.system(size: 12, weight: .bold))
                        if isSelected {
                            Text(tab.title(strings))
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
                                .fill(Palette.warmGradient)
                                .matchedGeometryEffect(id: "tabHighlight", in: tabNamespace)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title(strings))
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
