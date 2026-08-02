//
//  ContactsImportView.swift
//  Kudao
//

import SwiftData
import SwiftUI

/// Picks people out of the address book and turns them into profiles.
///
/// Contacts without a birthday are listed too, in their own section: picking
/// them opens a second step that asks for the missing date, which is the only
/// way to import from the many address books where dates were never filled in.
///
/// Everything already in Kudao is shown too, greyed out and unselectable, so
/// importing twice is impossible and the list still matches what the user sees
/// in the Contacts app.
struct ContactsImportView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(NotificationService.self) private var notifications
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var profiles: [BirthdayProfile]

    @State private var contacts = ContactsImportService()
    @State private var selection: Set<String> = []
    @State private var searchText: String = ""
    @State private var importedCount: Int = 0
    @State private var didImport: Bool = false
    @State private var isCompleting: Bool = false
    @State private var showsAllDateless: Bool = false

    /// How many dateless contacts are shown before asking to see the rest.
    ///
    /// A whole address book under the birthdays would bury the section that
    /// matters, so the tail stays behind one tap unless the user is searching.
    private static let datelessPreviewLimit: Int = 20

    private var strings: Strings { settings.strings }

    /// Match keys of every birthday profile already stored.
    private var existingKeys: Set<String> {
        Set(
            profiles
                .filter { $0.occasion == .birthday }
                .map { ContactCandidate.matchKey(name: $0.name, lastName: $0.lastName, date: $0.birthDate) }
        )
    }

    /// Names already stored, the only way to spot a dateless contact twice.
    private var existingNameKeys: Set<String> {
        Set(
            profiles
                .filter { $0.occasion == .birthday }
                .map { ContactCandidate.nameKey(name: $0.name, lastName: $0.lastName) }
        )
    }

    private var query: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var allCandidates: [ContactCandidate] {
        guard case .loaded(let found) = contacts.state else { return [] }
        return found
    }

    private var filtered: [ContactCandidate] {
        guard !query.isEmpty else { return allCandidates }
        let needle = query
        return allCandidates.filter { matches($0, query: needle) }
    }

    /// A contact matches on their name or on any way of writing their date.
    ///
    /// People look for a birthday in whichever form they hold it in their head —
    /// "Marco", "giugno", "12/06", "1990" — so all of them are accepted rather
    /// than forcing one canonical format.
    private func matches(_ candidate: ContactCandidate, query: String) -> Bool {
        if candidate.fullName.localizedStandardContains(query) { return true }
        return dateTokens(for: candidate).contains { $0.localizedStandardContains(query) }
    }

    /// Every written form of a contact's date that a search could plausibly use.
    private func dateTokens(for candidate: ContactCandidate) -> [String] {
        guard candidate.hasDate else { return [] }
        let date = candidate.resolvedDate()
        var tokens: [String] = [settings.dayMonth(date)]

        let parts = Calendar.current.dateComponents([.day, .month, .year], from: date)
        if let day = parts.day, let month = parts.month {
            tokens.append("\(day)/\(month)")
            tokens.append(String(format: "%02d/%02d", day, month))
            tokens.append(String(format: "%02d-%02d", day, month))
            tokens.append(String(format: "%02d.%02d", day, month))
        }

        if candidate.hasYear {
            tokens.append(settings.dayMonthYear(date))
            if let year = parts.year { tokens.append("\(year)") }
        }

        return tokens
    }

    /// True when Kudao already holds this person.
    ///
    /// A contact with a date is matched on name plus day and month; without a
    /// date the name is all there is to go on.
    private func isAlreadyStored(_ candidate: ContactCandidate) -> Bool {
        candidate.hasDate
            ? existingKeys.contains(candidate.matchKey)
            : existingNameKeys.contains(candidate.nameKey)
    }

    /// Contacts that would create something new, split by whether a date exists.
    private var importable: [ContactCandidate] {
        filtered.filter { $0.hasDate && !isAlreadyStored($0) }
    }

    /// New contacts whose date has to be asked for in the following step.
    private var needsDate: [ContactCandidate] {
        filtered.filter { !$0.hasDate && !isAlreadyStored($0) }
    }

    /// The slice of dateless contacts currently on screen.
    private var visibleNeedsDate: [ContactCandidate] {
        guard query.isEmpty, !showsAllDateless else { return needsDate }
        return Array(needsDate.prefix(Self.datelessPreviewLimit))
    }

    private var alreadyThere: [ContactCandidate] {
        filtered.filter { isAlreadyStored($0) }
    }

    private var selectedCount: Int { selection.count }

    private var selectedCandidates: [ContactCandidate] {
        allCandidates.filter { selection.contains($0.id) }
    }

    private var selectedDated: [ContactCandidate] {
        selectedCandidates.filter(\.hasDate)
    }

    private var selectedDateless: [ContactCandidate] {
        selectedCandidates.filter { !$0.hasDate }
    }

    private var areAllSelected: Bool {
        !importable.isEmpty && importable.allSatisfy { selection.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()
                content
            }
            .navigationTitle(strings.contactsImportTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(strings.cancelAction) { dismiss() }
                        .font(.system(.body, design: .rounded))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !importable.isEmpty {
                        Button(areAllSelected ? strings.contactsImportClearSelection : strings.contactsImportSelectAll) {
                            toggleSelectAll()
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if selectedCount > 0 {
                    importBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.smooth(duration: 0.28), value: selectedCount)
            .sensoryFeedback(.success, trigger: didImport)
            .sheet(isPresented: $isCompleting) {
                ContactsCompletionView(
                    candidates: selectedDateless,
                    readyCount: selectedDated.count
                ) { completions in
                    isCompleting = false
                    performImport(completions: completions)
                }
            }
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.coral)
        .pausesInterstitials()
        .task {
            guard case .idle = contacts.state else { return }
            await contacts.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch contacts.state {
        case .idle, .loading:
            loadingState
        case .denied:
            deniedState
        case .failed:
            failedState
        case .loaded(let found):
            if found.isEmpty {
                PlaceholderPanel(
                    icon: "person.crop.circle.badge.questionmark",
                    title: strings.contactsImportEmptyTitle,
                    message: strings.contactsImportEmptyMessage
                )
                .padding(.horizontal, 24)
            } else {
                list
            }
        }
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(Palette.coral)
            Text(strings.contactsImportLoading)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var deniedState: some View {
        VStack(spacing: 18) {
            PlaceholderPanel(
                icon: "lock.circle.fill",
                title: strings.contactsImportDeniedTitle,
                message: strings.contactsImportDeniedMessage
            )

            Button {
                MediaPermissions.openSettings()
            } label: {
                Label(strings.openSettingsAction, systemImage: "gear")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Palette.warmGradient))
            }
            .buttonStyle(PressableCardStyle())
        }
        .padding(.horizontal, 24)
    }

    private var failedState: some View {
        VStack(spacing: 18) {
            PlaceholderPanel(
                icon: "exclamationmark.triangle.fill",
                title: strings.contactsImportFailedTitle,
                message: strings.contactsImportFailedMessage
            )

            Button {
                Task { await contacts.load() }
            } label: {
                Label(strings.retryAction, systemImage: "arrow.clockwise")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Palette.warmGradient))
            }
            .buttonStyle(PressableCardStyle())
        }
        .padding(.horizontal, 24)
    }

    // MARK: - List

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                header

                SearchField(
                    placeholder: strings.contactsSearchPlaceholder,
                    clearLabel: strings.searchClear,
                    text: $searchText
                )

                if importable.isEmpty && needsDate.isEmpty && alreadyThere.isEmpty {
                    PlaceholderPanel(
                        icon: "magnifyingglass",
                        title: strings.noResultsTitle,
                        message: String(format: strings.noResultsMessageFormat, query)
                    )
                    .padding(.top, 4)
                }

                if !importable.isEmpty {
                    sectionTitle(String(format: strings.contactsImportNewSectionFormat, importable.count))

                    VStack(spacing: 10) {
                        ForEach(importable) { candidate in
                            row(candidate, isExisting: false)
                        }
                    }
                }

                if !needsDate.isEmpty {
                    sectionTitle(String(format: strings.contactsImportNeedsDateSectionFormat, needsDate.count))
                        .padding(.top, 4)

                    VStack(spacing: 10) {
                        ForEach(visibleNeedsDate) { candidate in
                            row(candidate, isExisting: false)
                        }
                    }

                    if visibleNeedsDate.count < needsDate.count {
                        showAllButton
                    }
                }

                if !alreadyThere.isEmpty {
                    sectionTitle(
                        String(format: strings.contactsImportExistingSectionFormat, alreadyThere.count)
                    )
                    .padding(.top, 4)

                    VStack(spacing: 10) {
                        ForEach(alreadyThere) { candidate in
                            row(candidate, isExisting: true)
                        }
                    }
                }

                Text(strings.contactsImportPrivacyNote)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, selectedCount > 0 ? 96 : 32)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }

    private var header: some View {
        Text(strings.contactsImportSubtitle)
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var showAllButton: some View {
        Button {
            showsAllDateless = true
        } label: {
            Text(String(format: strings.contactsImportShowAllFormat, needsDate.count))
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(Palette.coral)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Palette.coral.opacity(0.1))
                )
        }
        .buttonStyle(PressableCardStyle())
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(.caption, design: .rounded, weight: .bold))
            .tracking(1.1)
            .foregroundStyle(.secondary)
    }

    private func row(_ candidate: ContactCandidate, isExisting: Bool) -> some View {
        let isSelected = selection.contains(candidate.id)

        return Button {
            toggle(candidate)
        } label: {
            HStack(spacing: 13) {
                AvatarView(name: candidate.fullName, photoData: candidate.photoData, size: 44)
                    .opacity(isExisting ? 0.5 : 1)

                VStack(alignment: .leading, spacing: 4) {
                    Text(candidate.fullName)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(isExisting ? .secondary : .primary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Image(systemName: candidate.hasDate ? "birthday.cake.fill" : "calendar.badge.plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(rowIconTint(for: candidate, isExisting: isExisting))

                        if candidate.hasDate {
                            Text(dateLabel(for: candidate))
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        if isExisting {
                            badge(strings.contactsImportAlreadyBadge, tint: Palette.sage)
                        } else if !candidate.hasDate {
                            badge(strings.contactsImportNoDateBadge, tint: Palette.clay)
                        } else if !candidate.hasYear {
                            badge(strings.contactsImportNoYearBadge, tint: Palette.clay)
                        }
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: checkboxSymbol(isExisting: isExisting, isSelected: isSelected))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(checkboxTint(isExisting: isExisting, isSelected: isSelected))
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(13)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        isSelected ? Palette.coral.opacity(0.55) : Palette.hairline,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(PressableCardStyle())
        .disabled(isExisting)
        .accessibilityLabel(accessibilityLabel(for: candidate, isExisting: isExisting))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private func badge(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .heavy, design: .rounded))
            .foregroundStyle(tint)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Capsule().fill(tint.opacity(0.14)))
    }

    private func checkboxSymbol(isExisting: Bool, isSelected: Bool) -> String {
        if isExisting { return "checkmark.seal.fill" }
        return isSelected ? "checkmark.circle.fill" : "circle"
    }

    private func checkboxTint(isExisting: Bool, isSelected: Bool) -> Color {
        if isExisting { return Palette.sage.opacity(0.7) }
        return isSelected ? Palette.coral : Color.secondary.opacity(0.5)
    }

    private func rowIconTint(for candidate: ContactCandidate, isExisting: Bool) -> Color {
        if isExisting { return .secondary }
        return candidate.hasDate ? Palette.amber : Palette.clay
    }

    /// The full date when the contact has a year, day and month otherwise.
    private func dateLabel(for candidate: ContactCandidate) -> String {
        let date = candidate.resolvedDate()
        return candidate.hasYear ? settings.dayMonthYear(date) : settings.dayMonth(date)
    }

    private func accessibilityLabel(for candidate: ContactCandidate, isExisting: Bool) -> String {
        var parts = [candidate.fullName]
        parts.append(candidate.hasDate ? dateLabel(for: candidate) : strings.contactsImportNoDateBadge)
        if isExisting { parts.append(strings.contactsImportAlreadyBadge) }
        return parts.joined(separator: ", ")
    }

    // MARK: - Import bar

    private var importBar: some View {
        VStack(spacing: 8) {
            if let note = selectionNote {
                Text(note)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                startImport()
            } label: {
                Text(
                    selectedCount == 1
                        ? strings.contactsImportConfirmOne
                        : String(format: strings.contactsImportConfirmFormat, selectedCount)
                )
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Capsule().fill(Palette.warmGradient))
                .shadow(color: Palette.coral.opacity(0.35), radius: 14, y: 8)
            }
            .buttonStyle(PressableCardStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    /// What the picked contacts still need, if anything.
    ///
    /// A missing date is the more surprising of the two, so it wins the single
    /// line of space above the button.
    private var selectionNote: String? {
        if !selectedDateless.isEmpty { return strings.contactsImportNoDateNote }
        if selectedDated.contains(where: { !$0.hasYear }) { return strings.contactsImportNoYearNote }
        return nil
    }

    // MARK: - Actions

    private func toggle(_ candidate: ContactCandidate) {
        if selection.contains(candidate.id) {
            selection.remove(candidate.id)
        } else {
            selection.insert(candidate.id)
        }
    }

    private func toggleSelectAll() {
        if areAllSelected {
            selection.removeAll()
        } else {
            selection.formUnion(importable.map(\.id))
        }
    }

    /// Imports straight away, or asks for the missing dates first.
    private func startImport() {
        guard selectedCount > 0 else { return }
        if selectedDateless.isEmpty {
            performImport(completions: [])
        } else {
            isCompleting = true
        }
    }

    /// Creates one birthday profile per selected contact, then schedules their reminders.
    ///
    /// Dateless contacts only appear here once the user has given them a date;
    /// the ones they left blank are simply skipped.
    private func performImport(completions: [ContactDateCompletion]) {
        var created: [BirthdayProfile] = []

        for candidate in selectedDated {
            created.append(
                makeProfile(from: candidate, date: candidate.resolvedDate(), hasUnknownYear: !candidate.hasYear)
            )
        }

        for completion in completions {
            created.append(
                makeProfile(
                    from: completion.candidate,
                    date: completion.date,
                    hasUnknownYear: completion.hasUnknownYear
                )
            )
        }

        guard !created.isEmpty else {
            dismiss()
            return
        }

        do {
            try modelContext.save()
        } catch {
            print("[Kudao] Saving imported contacts failed: \(error.localizedDescription)")
        }

        importedCount = created.count
        didImport = true
        scheduleReminders(for: created)
        dismiss()
    }

    /// Builds and inserts one profile, leaving the save to the caller.
    private func makeProfile(
        from candidate: ContactCandidate,
        date: Date,
        hasUnknownYear: Bool
    ) -> BirthdayProfile {
        let profile = BirthdayProfile(
            name: candidate.givenName.isEmpty ? candidate.fullName : candidate.givenName,
            birthDate: date,
            relationship: .friend,
            lastName: candidate.givenName.isEmpty ? "" : candidate.familyName,
            contactPhone: candidate.phone,
            contactEmail: candidate.email,
            photoData: candidate.photoData,
            occasion: .birthday,
            hasUnknownBirthYear: hasUnknownYear
        )
        profile.reminderDaysBefore = settings.reminderDays(for: .birthday)
        profile.giftReminderDaysBefore = settings.giftReminderDays(for: .birthday)
        modelContext.insert(profile)
        return profile
    }

    private func scheduleReminders(for created: [BirthdayProfile]) {
        let strings = self.strings
        let settings = self.settings
        let privacy = ReminderPrivacy(hidesSurprisePreviews: settings.hidesSurpriseNotificationPreviews)
        Task {
            for profile in created {
                await notifications.sync(profile: profile, strings: strings, privacy: privacy)
            }
            WidgetBridge.publish(profiles: created, settings: settings)
        }
    }
}

#Preview {
    ContactsImportView()
        .environment(AppSettings())
        .environment(NotificationService.shared)
        .modelContainer(KudaoModelContainer.preview())
}
