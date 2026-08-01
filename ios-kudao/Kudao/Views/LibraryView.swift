//
//  LibraryView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Every cycle Kudao has already closed, across every profile.
///
/// The home grid looks forward; this screen is the only one that looks back.
/// Years are the spine of the layout because that is how people remember an
/// occasion — "the year we booked the boat", not "record #12".
struct LibraryView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.modelContext) private var context
    @Query private var records: [EventRecord]
    @Query private var profiles: [BirthdayProfile]

    @State private var occasionFilter: OccasionFilter = .all
    @State private var profileFilter: UUID?
    /// Archived cycle waiting for the owner to confirm they really mean it.
    @State private var pendingDeletion: EventRecord?

    private var strings: Strings { settings.strings }

    /// Records matching both filters, newest event first.
    private var results: [EventRecord] {
        records
            .filter { record in
                guard occasionFilter.matchesOccasion(record.occasion) else { return false }
                guard let profileFilter else { return true }
                return record.profileID == profileFilter
            }
            .sorted { $0.eventDate > $1.eventDate }
    }

    /// Results grouped under their year, most recent year on top.
    private var years: [(year: Int, records: [EventRecord])] {
        Dictionary(grouping: results, by: \.year)
            .map { (year: $0.key, records: $0.value) }
            .sorted { $0.year > $1.year }
    }

    /// Occasions that actually appear in the archive, so the filter stays honest.
    private var availableFilters: [OccasionFilter] {
        let kinds = Set(records.map(\.occasion))
        return [.all] + OccasionKind.allCases.filter { kinds.contains($0) }.map { .kind($0) }
    }

    /// Profiles with at least one archived cycle, alphabetical.
    private var archivedProfiles: [BirthdayProfile] {
        let ids = Set(records.map(\.profileID))
        return profiles
            .filter { ids.contains($0.id) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        ZStack {
            WarmBackdrop()

            if records.isEmpty {
                emptyState
            } else {
                content
            }
        }
        .navigationTitle(strings.libraryTitle)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            strings.libraryDeleteEventTitle,
            isPresented: Binding(
                get: { pendingDeletion != nil },
                set: { if !$0 { pendingDeletion = nil } }
            ),
            titleVisibility: .visible,
            presenting: pendingDeletion
        ) { record in
            Button(strings.libraryDeleteEventAction, role: .destructive) {
                EventArchivist.delete(record, context: context)
                pendingDeletion = nil
            }
            Button(strings.cancelAction, role: .cancel) { pendingDeletion = nil }
        } message: { record in
            Text(
                String(
                    format: strings.libraryDeleteEventMessageFormat,
                    String(record.year),
                    record.profileName
                )
            )
        }
        .environment(\.locale, settings.locale)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 18) {
                filterBar
                summaryLine

                ForEach(years, id: \.year) { group in
                    yearSection(group.year, records: group.records)
                }

                if results.isEmpty {
                    Text(strings.libraryFilterEmptyMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Sections

    private func yearSection(_ year: Int, records: [EventRecord]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(String(year))
                    .font(.system(.title3, design: .rounded, weight: .heavy))
                    .foregroundStyle(Palette.clay)
                Rectangle()
                    .fill(Palette.hairline)
                    .frame(height: 1)
            }

            ForEach(records) { record in
                NavigationLink(value: record) {
                    EventRecordCard(record: record, strings: strings, showsProfileName: true)
                }
                .buttonStyle(PressableCardStyle())
                .contextMenu {
                    Button(role: .destructive) {
                        pendingDeletion = record
                    } label: {
                        Label(strings.libraryDeleteEventAction, systemImage: "trash")
                    }
                }
            }
        }
    }

    private var summaryLine: some View {
        Text(String(format: strings.libraryCountFormat, results.count))
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Filters

    private var filterBar: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(availableFilters) { filter in
                        chip(filter)
                    }
                }
            }
            .scrollIndicators(.hidden)

            if archivedProfiles.count > 1 {
                profileMenu
            }
        }
        .padding(.top, 4)
    }

    private func chip(_ filter: OccasionFilter) -> some View {
        let isSelected = filter == occasionFilter
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                occasionFilter = filter
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: filter.symbolName)
                    .font(.system(size: 11, weight: .bold))
                Text(filter.title(strings))
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(isSelected ? .white : .secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule().fill(isSelected ? AnyShapeStyle(filter.accent) : AnyShapeStyle(Palette.surface))
            )
            .overlay(Capsule().strokeBorder(isSelected ? .clear : Palette.hairline, lineWidth: 1))
        }
        .buttonStyle(PressableCardStyle())
    }

    private var profileMenu: some View {
        Menu {
            Button {
                profileFilter = nil
            } label: {
                Label(strings.libraryAllProfiles, systemImage: "person.3.fill")
            }
            ForEach(archivedProfiles) { profile in
                Button {
                    profileFilter = profile.id
                } label: {
                    Label(profile.fullName, systemImage: profile.occasion.symbolName)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 13, weight: .semibold))
                Text(selectedProfileName)
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Capsule().fill(Palette.surface))
            .overlay(Capsule().strokeBorder(Palette.hairline, lineWidth: 1))
        }
    }

    private var selectedProfileName: String {
        guard let profileFilter,
              let match = archivedProfiles.first(where: { $0.id == profileFilter }) else {
            return strings.libraryAllProfiles
        }
        return match.fullName
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Palette.surfaceRaised)
                    .frame(width: 104, height: 104)
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Palette.clay)
            }

            VStack(spacing: 8) {
                Text(strings.libraryEmptyTitle)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text(strings.libraryEmptyMessage)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
    }
}

extension OccasionFilter {
    /// Matches an occasion directly, without a profile in hand.
    func matchesOccasion(_ kind: OccasionKind) -> Bool {
        switch self {
        case .all: true
        case .kind(let selected): selected == kind
        }
    }
}
