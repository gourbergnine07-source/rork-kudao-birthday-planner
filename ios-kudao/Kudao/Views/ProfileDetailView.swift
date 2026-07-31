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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedTab: ProfileTab?
    @State private var isEditing: Bool = false
    @State private var isShowingSettings: Bool = false
    @State private var isConfirmingDelete: Bool = false
    @State private var pendingDeletion: Bool = false
    @State private var analyzer = DiaryAnalyzer()
    @State private var suggestionEngine = SuggestionEngine()
    @State private var exportingFormat: DiaryExportFormat?
    @State private var exportedFile: ExportedFile?
    @State private var exportFailed: Bool = false
    @Namespace private var tabNamespace

    private var activeTab: ProfileTab { selectedTab ?? initialTab }

    private var strings: Strings { settings.strings }
    private var countdown: BirthdayCountdown { profile.countdown }

    enum ProfileTab: String, CaseIterable, Identifiable {
        case diary
        case preferences
        case suggestions

        var id: String { rawValue }

        var symbolName: String {
            switch self {
            case .diary: "book.closed.fill"
            case .preferences: "tag.fill"
            case .suggestions: "sparkles"
            }
        }

        func title(_ strings: Strings) -> String {
            switch self {
            case .diary: strings.diaryTab
            case .preferences: strings.preferencesTab
            case .suggestions: strings.suggestionsTab
            }
        }
    }

    var body: some View {
        ZStack {
            WarmBackdrop()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    statsRow
                    tabSelector
                    tabContent
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(profile.name)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
            }
            ToolbarItem(placement: .topBarTrailing) {
                settingsMenu
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
        .onDisappear {
            guard pendingDeletion else { return }
            notifications.cancelReminders(for: profile.id)
            modelContext.delete(profile)
        }
        .environment(\.locale, settings.locale)
        .tint(Palette.coral)
    }

    // MARK: - Settings menu

    private var settingsMenu: some View {
        Menu {
            Button {
                isEditing = true
            } label: {
                Label(strings.editData, systemImage: "pencil")
            }

            Button {
                isShowingSettings = true
            } label: {
                Label(strings.remindersMenuTitle, systemImage: "bell.badge")
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

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Palette.warmGradient)

            if let photoData = profile.photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .allowsHitTesting(false)
                    .clipShape(.rect(cornerRadius: 30, style: .continuous))
                    .overlay {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.25), .black.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(.rect(cornerRadius: 30, style: .continuous))
                    }
            }

            if countdown.isToday {
                ConfettiView()
                    .clipShape(.rect(cornerRadius: 30, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 12) {
                Spacer(minLength: 0)

                if profile.photoData == nil {
                    AvatarView(
                        name: profile.name,
                        photoData: nil,
                        size: 66,
                        ringColor: .white.opacity(0.5),
                        ringWidth: 2
                    )
                }

                Text(profile.name)
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    KudaoChip(
                        title: profile.relationship.title(strings),
                        systemImage: profile.relationship.symbolName,
                        onDark: true
                    )
                    if profile.isSurpriseMode {
                        KudaoChip(title: strings.surpriseBadge, systemImage: "eye.slash.fill", onDark: true)
                    }
                }

                countdownBanner
            }
            .padding(20)
        }
        .frame(height: 300)
        .clipShape(.rect(cornerRadius: 30, style: .continuous))
        .shadow(color: Palette.coral.opacity(0.28), radius: 20, y: 12)
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
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Capsule().fill(.ultraThinMaterial.opacity(0.85)))
        .overlay(Capsule().strokeBorder(.white.opacity(0.3), lineWidth: 1))
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatTile(
                icon: "calendar",
                caption: strings.nextBirthdayLabel,
                value: settings.dayMonth(countdown.nextDate),
                tint: Palette.coral
            )
            StatTile(
                icon: "birthday.cake.fill",
                caption: settings.dayMonthYear(profile.birthDate),
                value: String(format: strings.ageNowFormat, countdown.turningAge),
                tint: Palette.berry
            )
        }
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
