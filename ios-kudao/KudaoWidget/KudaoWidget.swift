//
//  KudaoWidget.swift
//  KudaoWidget
//

import SwiftUI
import WidgetKit

nonisolated struct CountdownEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetCountdownSnapshot

    var strings: WidgetStrings { WidgetStrings.table(for: snapshot.languageCode) }

    /// Nearest birthday computed at render time, so the number stays right.
    var lead: (entry: WidgetCountdownEntry, countdown: WidgetCountdown)? {
        snapshot.entries
            .map { ($0, WidgetCountdown(birthDate: $0.birthDate, reference: date)) }
            .min { $0.1.daysRemaining < $1.1.daysRemaining }
    }

    /// The runners-up, used by the medium and large families.
    var followers: [(entry: WidgetCountdownEntry, countdown: WidgetCountdown)] {
        snapshot.entries
            .map { ($0, WidgetCountdown(birthDate: $0.birthDate, reference: date)) }
            .sorted { $0.1.daysRemaining < $1.1.daysRemaining }
            .dropFirst()
            .prefix(3)
            .map { ($0.0, $0.1) }
    }

    static func placeholder(reference: Date = Date()) -> CountdownEntry {
        CountdownEntry(
            date: reference,
            snapshot: WidgetCountdownSnapshot(
                languageCode: "it",
                generatedAt: reference,
                entries: [
                    WidgetCountdownEntry(
                        id: "placeholder",
                        name: "Giulia",
                        initials: "G",
                        birthDate: Calendar.current.date(byAdding: .day, value: 12, to: reference) ?? reference,
                        isMasked: false,
                        relationshipRaw: "friend",
                        hidesAge: false
                    )
                ]
            )
        )
    }
}

nonisolated struct CountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        .placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        let snapshot = WidgetSnapshotReader.load()
        let entry = snapshot.entries.isEmpty && context.isPreview
            ? CountdownEntry.placeholder()
            : CountdownEntry(date: Date(), snapshot: snapshot)
        completion(entry)
    }

    /// One entry per upcoming midnight for a week: the countdown ticks down on its own.
    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let snapshot = WidgetSnapshotReader.load()
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        var entries: [CountdownEntry] = [CountdownEntry(date: now, snapshot: snapshot)]
        for offset in 1...7 {
            guard let midnight = calendar.date(byAdding: .day, value: offset, to: startOfToday) else { continue }
            entries.append(CountdownEntry(date: midnight, snapshot: snapshot))
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - Views

nonisolated struct CountdownWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CountdownEntry

    var body: some View {
        switch family {
        case .accessoryCircular: AccessoryCircularView(entry: entry)
        case .accessoryRectangular: AccessoryRectangularView(entry: entry)
        case .accessoryInline: AccessoryInlineView(entry: entry)
        case .systemMedium: MediumCountdownView(entry: entry)
        case .systemLarge, .systemExtraLarge: LargeCountdownView(entry: entry)
        default: SmallCountdownView(entry: entry)
        }
    }
}

/// Shared header: masked profiles show a gift glyph instead of initials.
nonisolated struct WidgetAvatar: View {
    let entry: WidgetCountdownEntry
    var size: CGFloat = 34

    var body: some View {
        Circle()
            .fill(.white.opacity(0.24))
            .frame(width: size, height: size)
            .overlay {
                if entry.isMasked {
                    Image(systemName: "gift.fill")
                        .font(.system(size: size * 0.42, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text(entry.initials)
                        .font(.system(size: size * 0.42, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1.5))
    }
}

nonisolated struct SmallCountdownView: View {
    let entry: CountdownEntry

    var body: some View {
        if let lead = entry.lead {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    WidgetAvatar(entry: lead.entry, size: 26)
                    Text(lead.entry.name)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 4)

                if lead.countdown.isToday {
                    Text(entry.strings.today)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                } else {
                    Text("\(lead.countdown.daysRemaining)")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text(lead.countdown.daysRemaining == 1 ? entry.strings.dayUnit : entry.strings.daysUnit)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                }

                Spacer(minLength: 4)

                Text(lead.countdown.nextDate, format: dayMonth(entry.snapshot.languageCode))
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .containerBackground(for: .widget) { WidgetPalette.warmGradient }
        } else {
            EmptyStateView(strings: entry.strings)
        }
    }
}

nonisolated struct MediumCountdownView: View {
    let entry: CountdownEntry

    var body: some View {
        if let lead = entry.lead {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 7) {
                        WidgetAvatar(entry: lead.entry, size: 30)
                        Text(lead.entry.name)
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 2)

                    if lead.countdown.isToday {
                        Text(entry.strings.today)
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    } else {
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("\(lead.countdown.daysRemaining)")
                                .font(.system(size: 46, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                            VStack(alignment: .leading, spacing: -2) {
                                Text(lead.countdown.daysRemaining == 1 ? entry.strings.dayUnit : entry.strings.daysUnit)
                                    .font(.system(.footnote, design: .rounded, weight: .bold))
                                Text(entry.strings.toGo)
                                    .font(.system(.caption2, design: .rounded))
                                    .opacity(0.85)
                            }
                            .foregroundStyle(.white)
                            .padding(.bottom, 5)
                        }
                    }

                    Spacer(minLength: 2)

                    HStack(spacing: 6) {
                        Image(systemName: "birthday.cake.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text(lead.countdown.nextDate, format: dayMonth(entry.snapshot.languageCode))
                        // Contacts imported without a birth year have no age to show.
                        if lead.entry.showsAge {
                            Text("·")
                            Text(String(format: entry.strings.turnsFormat, lead.countdown.turningAge))
                        }
                    }
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                }

                if !entry.followers.isEmpty {
                    VStack(alignment: .leading, spacing: 7) {
                        ForEach(entry.followers.prefix(3), id: \.entry.id) { follower in
                            HStack(spacing: 7) {
                                WidgetAvatar(entry: follower.entry, size: 20)
                                Text(follower.entry.name)
                                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                                    .lineLimit(1)
                                Spacer(minLength: 0)
                                Text("\(follower.countdown.daysRemaining)")
                                    .font(.system(.caption, design: .rounded, weight: .heavy))
                            }
                            .foregroundStyle(.white.opacity(0.92))
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(width: 118)
                }
            }
            .containerBackground(for: .widget) { WidgetPalette.warmGradient }
        } else {
            EmptyStateView(strings: entry.strings)
        }
    }
}

nonisolated struct LargeCountdownView: View {
    let entry: CountdownEntry

    var body: some View {
        if let lead = entry.lead {
            VStack(alignment: .leading, spacing: 14) {
                Text(entry.strings.nextUp.uppercased())
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: 12) {
                    WidgetAvatar(entry: lead.entry, size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(lead.entry.name)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(lead.countdown.nextDate, format: dayMonth(entry.snapshot.languageCode))
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Spacer(minLength: 0)
                }

                if lead.countdown.isToday {
                    Text(entry.strings.today)
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                } else {
                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text("\(lead.countdown.daysRemaining)")
                            .font(.system(size: 64, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                        VStack(alignment: .leading, spacing: -2) {
                            Text(lead.countdown.daysRemaining == 1 ? entry.strings.dayUnit : entry.strings.daysUnit)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                            Text(entry.strings.toGo)
                                .font(.system(.caption, design: .rounded))
                                .opacity(0.85)
                        }
                        .foregroundStyle(.white)
                        .padding(.bottom, 8)
                    }
                }

                if !entry.followers.isEmpty {
                    VStack(spacing: 0) {
                        Divider().overlay(.white.opacity(0.3))

                        ForEach(entry.followers, id: \.entry.id) { follower in
                            HStack(spacing: 10) {
                                WidgetAvatar(entry: follower.entry, size: 26)
                                Text(follower.entry.name)
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .lineLimit(1)
                                Spacer(minLength: 0)
                                Text("\(follower.countdown.daysRemaining)")
                                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                                Text(follower.countdown.daysRemaining == 1 ? entry.strings.dayUnit : entry.strings.daysUnit)
                                    .font(.system(.caption2, design: .rounded, weight: .medium))
                                    .opacity(0.85)
                            }
                            .foregroundStyle(.white.opacity(0.94))
                            .padding(.vertical, 8)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .containerBackground(for: .widget) { WidgetPalette.warmGradient }
        } else {
            EmptyStateView(strings: entry.strings)
        }
    }
}

nonisolated struct AccessoryCircularView: View {
    let entry: CountdownEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let lead = entry.lead {
                VStack(spacing: -2) {
                    Image(systemName: "birthday.cake.fill")
                        .font(.system(size: 9, weight: .bold))
                    Text("\(lead.countdown.daysRemaining)")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                }
            } else {
                Image(systemName: "gift")
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }
}

nonisolated struct AccessoryRectangularView: View {
    let entry: CountdownEntry

    var body: some View {
        if let lead = entry.lead {
            VStack(alignment: .leading, spacing: 1) {
                Text(lead.entry.name)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .lineLimit(1)
                Text(
                    lead.countdown.isToday
                        ? entry.strings.today
                        : "\(lead.countdown.daysRemaining) \(lead.countdown.daysRemaining == 1 ? entry.strings.dayUnit : entry.strings.daysUnit)"
                )
                .font(.system(.title3, design: .rounded, weight: .heavy))
                Text(lead.countdown.nextDate, format: dayMonth(entry.snapshot.languageCode))
                    .font(.system(.caption2, design: .rounded))
                    .opacity(0.8)
            }
        } else {
            Text(entry.strings.emptyMessage)
                .font(.system(.caption, design: .rounded, weight: .semibold))
        }
    }
}

nonisolated struct AccessoryInlineView: View {
    let entry: CountdownEntry

    var body: some View {
        if let lead = entry.lead {
            if lead.countdown.isToday {
                Text("\(lead.entry.name) · \(entry.strings.today)")
            } else {
                Text("\(lead.entry.name) · \(lead.countdown.daysRemaining) \(lead.countdown.daysRemaining == 1 ? entry.strings.dayUnit : entry.strings.daysUnit)")
            }
        } else {
            Text(entry.strings.emptyTitle)
        }
    }
}

nonisolated struct EmptyStateView: View {
    let strings: WidgetStrings

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: "birthday.cake.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
            Text(strings.emptyTitle)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(strings.emptyMessage)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) { WidgetPalette.warmGradient }
    }
}

/// "3 giugno" style date following the language chosen in the app.
nonisolated private func dayMonth(_ languageCode: String) -> Date.FormatStyle {
    Date.FormatStyle(locale: Locale(identifier: languageCode))
        .day(.defaultDigits)
        .month(.abbreviated)
}

// MARK: - Widget

nonisolated struct KudaoWidget: Widget {
    let kind: String = "KudaoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownProvider()) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName(WidgetStrings.table(for: deviceLanguageCode()).displayName)
        .description(WidgetStrings.table(for: deviceLanguageCode()).description)
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

/// The gallery entry is rendered before any snapshot is read, so it follows the device language.
nonisolated private func deviceLanguageCode() -> String {
    for identifier in Locale.preferredLanguages {
        let code = Locale(identifier: identifier).language.languageCode?.identifier ?? ""
        if ["it", "en", "fr", "es"].contains(code) { return code }
    }
    return "it"
}
