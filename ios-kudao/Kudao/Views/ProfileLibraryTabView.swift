//
//  ProfileLibraryTabView.swift
//  Kudao
//

import SwiftUI

/// The archive of one profile: every year that has already been lived through.
///
/// It is the counterweight to the countdown at the top of the screen — the
/// profile keeps growing instead of resetting, and this is where that growth
/// becomes visible.
struct ProfileLibraryTabView: View {
    let profile: BirthdayProfile

    @Environment(AppSettings.self) private var settings

    private var strings: Strings { settings.strings }

    private var records: [EventRecord] {
        profile.archivedCycles
    }

    var body: some View {
        VStack(spacing: 12) {
            if records.isEmpty {
                emptyState
            } else {
                header

                ForEach(records) { record in
                    NavigationLink(value: record) {
                        EventRecordCard(record: record, strings: strings)
                    }
                    .buttonStyle(PressableCardStyle())
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Palette.clay)
            Text(String(format: strings.libraryYearsCountFormat, records.count))
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "hourglass")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Palette.clay)
            Text(strings.libraryProfileEmptyMessage)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
        )
    }
}
