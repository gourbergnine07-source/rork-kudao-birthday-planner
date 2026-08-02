//
//  CountdownTimerCard.swift
//  Kudao
//

import SwiftUI

/// Live countdown to the next occurrence: days, hours, minutes and seconds.
///
/// The tiles tick once a second while the screen is visible. SwiftUI pauses the
/// timeline as soon as the view leaves the screen, so nothing runs in the
/// background.
struct CountdownTimerCard: View {
    /// Midnight of the next occurrence.
    let targetDate: Date
    let occasion: OccasionKind
    let strings: Strings
    /// Human date of the next occurrence, shown next to the title.
    let dateCaption: String
    /// How far through the year we are, 0 to 1.
    let progress: Double
    let isToday: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedProgress: Double = 0

    private var accent: Color { occasion.accent }

    var body: some View {
        VStack(spacing: 14) {
            titleRow

            if isToday {
                todayState
            } else {
                tiles
            }

            progressBar
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(accent.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: accent.opacity(0.1), radius: 14, y: 6)
        .onAppear {
            guard !reduceMotion else {
                animatedProgress = progress
                return
            }
            withAnimation(.smooth(duration: 0.9).delay(0.1)) { animatedProgress = progress }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.smooth(duration: 0.5)) { animatedProgress = newValue }
        }
    }

    // MARK: - Title

    private var titleRow: some View {
        HStack(spacing: 7) {
            Image(systemName: isToday ? "party.popper.fill" : "hourglass")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(accent)
                .symbolEffect(
                    .bounce,
                    options: reduceMotion ? .nonRepeating : .repeat(.periodic(delay: 3))
                )

            Text(strings.countdownCardTitle)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(accent)
                .textCase(.uppercase)
                .kerning(0.6)

            Spacer(minLength: 8)

            Text(dateCaption)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    // MARK: - Tiles

    private var tiles: some View {
        TimelineView(.periodic(from: targetDate, by: 1)) { context in
            let parts = CountdownParts(target: targetDate, now: context.date)

            HStack(spacing: 4) {
                tile(
                    value: parts.days,
                    caption: parts.days == 1 ? strings.dayUnit : strings.daysUnit,
                    isLead: true
                )
                colon
                tile(value: parts.hours, caption: strings.countdownHoursUnit)
                colon
                tile(value: parts.minutes, caption: strings.countdownMinutesUnit)
                colon
                tile(value: parts.seconds, caption: strings.countdownSecondsUnit)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                String(
                    format: strings.countdownAccessibilityFormat,
                    parts.days,
                    parts.hours,
                    parts.minutes
                )
            )
        }
    }

    private func tile(value: Int, caption: String, isLead: Bool = false) -> some View {
        VStack(spacing: 1) {
            Text(isLead ? "\(value)" : String(format: "%02d", value))
                .font(.system(size: isLead ? 36 : 28, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isLead ? accent : .primary)
                .contentTransition(.numericText(countsDown: true))
                .animation(reduceMotion ? nil : .snappy(duration: 0.28), value: value)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(caption)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var colon: some View {
        Text(":")
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundStyle(accent.opacity(0.3))
            .padding(.bottom, 12)
    }

    // MARK: - Today

    private var todayState: some View {
        VStack(spacing: 3) {
            Text(occasion.todayTitle(strings))
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(accent)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .lineLimit(2)

            Text(strings.countdownTodayCaption)
                .font(.system(.footnote, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    // MARK: - Progress

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(accent.opacity(0.14))

                Capsule()
                    .fill(occasion.gradient)
                    .frame(width: max(8, geo.size.width * min(max(animatedProgress, 0), 1)))
            }
        }
        .frame(height: 6)
        .accessibilityHidden(true)
    }
}

/// Calendar-accurate split of the time left, so a daylight-saving jump never
/// shifts the countdown by an hour.
private struct CountdownParts {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int

    init(target: Date, now: Date, calendar: Calendar = .current) {
        guard now < target else {
            days = 0
            hours = 0
            minutes = 0
            seconds = 0
            return
        }
        let parts = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: target)
        days = max(0, parts.day ?? 0)
        hours = max(0, parts.hour ?? 0)
        minutes = max(0, parts.minute ?? 0)
        seconds = max(0, parts.second ?? 0)
    }
}

#Preview {
    VStack(spacing: 16) {
        CountdownTimerCard(
            targetDate: Date().addingTimeInterval(60 * 60 * 52),
            occasion: .birthday,
            strings: .italian,
            dateCaption: "sab 14 giu",
            progress: 0.82,
            isToday: false
        )
        CountdownTimerCard(
            targetDate: Date(),
            occasion: .birthday,
            strings: .italian,
            dateCaption: "oggi",
            progress: 1,
            isToday: true
        )
    }
    .padding()
    .background(Palette.background)
}
