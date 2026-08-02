//
//  ContactsImportView.swift
//  Kudao
//

import SwiftData
import SwiftUI

/// Picks birthdays out of the address book and turns them into profiles.
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

    private var strings: Strings { settings.strings }

    /// Match keys of every birthday profile already stored.
    private var existingKeys: Set<String> {
        Set(
            profiles
                .filter { $0.occasion == .birthday }
                .map { ContactCandidate.matchKey(name: $0.name, lastName: $0.lastName, date: $0.birthDate) }
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
        return allCandidates.filter { $0.fullName.localizedStandardContains(query) }
    }

    /// Contacts that would create something new, and the ones already covered.
    private var importable: [ContactCandidate] {
        let existing = existingKeys
        return filtered.filter { !existing.contains($0.matchKey) }
    }

    private var alreadyThere: [ContactCandidate] {
        let existing = existingKeys
        return filtered.filter { existing.contains($0.matchKey) }
    }

    private var selectedCount: Int { selection.count }

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
            VStack(alignment: .leading, spacing: 16) {
                header

                SearchField(
                    placeholder: strings.searchPlaceholder,
                    clearLabel: strings.searchClear,
                    text: $searchText
                )

                if importable.isEmpty && alreadyThere.isEmpty {
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
                        Image(systemName: "birthday.cake.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(isExisting ? Color.secondary : Palette.amber)

                        Text(dateLabel(for: candidate))
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)

                        if isExisting {
                            badge(strings.contactsImportAlreadyBadge, tint: Palette.sage)
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

    /// The full date when the contact has a year, day and month otherwise.
    private func dateLabel(for candidate: ContactCandidate) -> String {
        let date = candidate.resolvedDate()
        return candidate.hasYear ? settings.dayMonthYear(date) : settings.dayMonth(date)
    }

    private func accessibilityLabel(for candidate: ContactCandidate, isExisting: Bool) -> String {
        var parts = [candidate.fullName, dateLabel(for: candidate)]
        if isExisting { parts.append(strings.contactsImportAlreadyBadge) }
        return parts.joined(separator: ", ")
    }

    // MARK: - Import bar

    private var importBar: some View {
        VStack(spacing: 8) {
            if selectedNeedsYearNote {
                Text(strings.contactsImportNoYearNote)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                importSelected()
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

    /// True when at least one picked contact has no birth year.
    private var selectedNeedsYearNote: Bool {
        allCandidates.contains { selection.contains($0.id) && !$0.hasYear }
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

    /// Creates one birthday profile per selected contact, then schedules their reminders.
    private func importSelected() {
        let picked = allCandidates.filter { selection.contains($0.id) }
        guard !picked.isEmpty else { return }

        var created: [BirthdayProfile] = []

        for candidate in picked {
            let profile = BirthdayProfile(
                name: candidate.givenName.isEmpty ? candidate.fullName : candidate.givenName,
                birthDate: candidate.resolvedDate(),
                relationship: .friend,
                lastName: candidate.givenName.isEmpty ? "" : candidate.familyName,
                contactPhone: candidate.phone,
                contactEmail: candidate.email,
                photoData: candidate.photoData,
                occasion: .birthday,
                hasUnknownBirthYear: !candidate.hasYear
            )
            profile.reminderDaysBefore = settings.reminderDays(for: .birthday)
            profile.giftReminderDaysBefore = settings.giftReminderDays(for: .birthday)
            modelContext.insert(profile)
            created.append(profile)
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
