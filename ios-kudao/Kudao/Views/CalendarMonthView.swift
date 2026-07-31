//
//  CalendarMonthView.swift
//  Kudao
//

import SwiftUI
import UIKit

/// One day of the displayed month, with the birthdays that fall on it.
struct CalendarDay: Identifiable, Equatable {
    let date: Date
    let number: Int
    let profiles: [BirthdayProfile]

    var id: Date { date }
    var hasBirthday: Bool { !profiles.isEmpty }
}

/// Month grid where every day holding a birthday becomes a photo tile.
struct CalendarMonthView: View {
    let profiles: [BirthdayProfile]
    let settings: AppSettings
    @Binding var month: Date
    let isLocked: (BirthdayProfile) -> Bool
    let onSelect: (BirthdayProfile) -> Void
    let onAdd: (Date) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var strings: Strings { settings.strings }
    private let calendar: Calendar = .current

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    }

    /// Every day of the visible month with its matching birthdays.
    private var days: [CalendarDay] {
        guard let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let range = calendar.range(of: .day, in: .month, for: start) else { return [] }

        let visibleMonth = calendar.component(.month, from: start)
        var byDay: [Int: [BirthdayProfile]] = [:]
        for profile in profiles {
            let parts = calendar.dateComponents([.month, .day], from: profile.birthDate)
            guard parts.month == visibleMonth, let day = parts.day else { continue }
            byDay[day, default: []].append(profile)
        }

        return range.compactMap { day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: start) else { return nil }
            let matches = (byDay[day] ?? []).sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
            return CalendarDay(date: date, number: day, profiles: matches)
        }
    }

    private var monthCount: Int {
        days.reduce(0) { $0 + $1.profiles.count }
    }

    private var isCurrentMonth: Bool {
        calendar.isDate(month, equalTo: Date(), toGranularity: .month)
    }

    private var monthTitle: String {
        let raw = month.formatted(
            Date.FormatStyle(locale: settings.locale).month(.wide).year()
        )
        guard let first = raw.first else { return raw }
        return String(first).localizedUppercase + raw.dropFirst()
    }

    var body: some View {
        VStack(spacing: 14) {
            monthBar
            addButton
            grid
        }
        .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: month)
    }

    // MARK: - Header

    private var monthBar: some View {
        HStack(spacing: 12) {
            stepButton(systemImage: "chevron.left", label: strings.previousMonthLabel, step: -1)

            VStack(spacing: 2) {
                Text(monthTitle)
                    .font(.system(.title3, design: .rounded, weight: .heavy))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                Text(
                    monthCount == 0
                        ? strings.monthNoBirthdays
                        : String(format: strings.monthCountFormat, monthCount)
                )
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(monthCount == 0 ? Color.secondary : Palette.coral)
            }
            .frame(maxWidth: .infinity)

            stepButton(systemImage: "chevron.right", label: strings.nextMonthLabel, step: 1)
        }
        .overlay(alignment: .bottom) {
            if !isCurrentMonth {
                Button {
                    month = Date()
                } label: {
                    Text(strings.todayAction)
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(Palette.coral)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Palette.coral.opacity(0.14)))
                }
                .buttonStyle(PressableCardStyle())
                .offset(y: 22)
            }
        }
        .padding(.bottom, isCurrentMonth ? 0 : 24)
    }

    private func stepButton(systemImage: String, label: String, step: Int) -> some View {
        Button {
            guard let shifted = calendar.date(byAdding: .month, value: step, to: month) else { return }
            month = shifted
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Palette.coral)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Palette.surface))
                .overlay(Circle().strokeBorder(Palette.hairline, lineWidth: 1))
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel(label)
    }

    private var addButton: some View {
        Button {
            onAdd(defaultAddDate)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .heavy))
                Text(strings.addBirthdayAction)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Capsule().fill(Palette.warmGradient))
            .shadow(color: Palette.coral.opacity(0.3), radius: 12, y: 6)
        }
        .buttonStyle(PressableCardStyle())
    }

    /// New profiles default to the 1st of the visible month (or today when it is this month).
    private var defaultAddDate: Date {
        isCurrentMonth ? Date() : (days.first?.date ?? Date())
    }

    // MARK: - Grid

    private var grid: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(days) { day in
                    dayCell(day)
                }
            }

            Text(strings.tapDayHint)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(monthSwipe)
    }

    /// Horizontal swipes flip the month without fighting the vertical scroll.
    private var monthSwipe: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let horizontal = value.translation.width
                guard abs(horizontal) > abs(value.translation.height) * 1.6, abs(horizontal) > 55 else { return }
                let step = horizontal < 0 ? 1 : -1
                guard let shifted = calendar.date(byAdding: .month, value: step, to: month) else { return }
                month = shifted
            }
    }

    @ViewBuilder
    private func dayCell(_ day: CalendarDay) -> some View {
        if let profile = day.profiles.first {
            Button {
                onSelect(profile)
            } label: {
                CalendarDayCell(
                    day: day,
                    profile: profile,
                    settings: settings,
                    isLocked: isLocked(profile),
                    isToday: calendar.isDateInToday(day.date)
                )
            }
            .buttonStyle(PressableCardStyle())
        } else {
            Button {
                onAdd(day.date)
            } label: {
                CalendarDayCell(
                    day: day,
                    profile: nil,
                    settings: settings,
                    isLocked: false,
                    isToday: calendar.isDateInToday(day.date)
                )
            }
            .buttonStyle(PressableCardStyle())
        }
    }
}

/// Single tile of the month grid: plain date, or a full-bleed portrait when someone celebrates.
struct CalendarDayCell: View {
    let day: CalendarDay
    let profile: BirthdayProfile?
    let settings: AppSettings
    let isLocked: Bool
    let isToday: Bool

    private var strings: Strings { settings.strings }

    private var weekday: String {
        let raw = day.date.formatted(
            Date.FormatStyle(locale: settings.locale).weekday(.abbreviated)
        )
        guard let first = raw.first else { return raw }
        return String(first).localizedUppercase + raw.dropFirst()
    }

    private var accent: Color {
        guard let profile else { return Palette.hairline }
        if isLocked { return Palette.berry }
        return isToday ? Palette.coral : profile.relationship.accent
    }

    private var image: Image? {
        guard !isLocked, let data = profile?.photoData, let ui = UIImage(data: data) else { return nil }
        return Image(uiImage: ui)
    }

    var body: some View {
        Color(profile == nil ? .clear : .black)
            .aspectRatio(0.76, contentMode: .fit)
            .background(baseFill)
            .overlay {
                if let image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
            }
            .overlay {
                if profile != nil {
                    LinearGradient(
                        colors: [.black.opacity(0.45), .clear, .black.opacity(0.72)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)
                }
            }
            .clipShape(.rect(cornerRadius: 18, style: .continuous))
            .overlay(alignment: .topLeading) { dateStack }
            .overlay(alignment: .topTrailing) { glyph }
            .overlay(alignment: .bottomLeading) { nameLabel }
            .overlay(alignment: .bottomTrailing) { extraCount }
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        profile == nil
                            ? (isToday ? Palette.coral.opacity(0.7) : Palette.hairline)
                            : accent,
                        lineWidth: profile == nil ? (isToday ? 1.6 : 1) : 2
                    )
            )
            .shadow(
                color: profile == nil ? .black.opacity(0.04) : accent.opacity(0.28),
                radius: profile == nil ? 5 : 12,
                y: profile == nil ? 2 : 6
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private var baseFill: some View {
        if isLocked {
            LinearGradient(
                colors: [Palette.plum, Palette.berry.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if profile != nil {
            Palette.avatarGradient(for: profile?.name ?? "")
        } else {
            (isToday ? Palette.surfaceRaised : Palette.surface)
        }
    }

    private var dateStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(weekday)
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(profile == nil ? Color.secondary : .white.opacity(0.85))
            Text("\(day.number)")
                .font(.system(.headline, design: .rounded, weight: .heavy))
                .foregroundStyle(profile == nil ? (isToday ? Palette.coral : Color.primary) : .white)
        }
        .shadow(color: profile == nil ? .clear : .black.opacity(0.5), radius: 3, y: 1)
        .padding(.horizontal, 9)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var glyph: some View {
        if let profile {
            Image(systemName: isLocked ? "eye.slash.fill" : profile.relationship.symbolName)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(.black.opacity(0.35)))
                .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 0.8))
                .padding(7)
        } else if isToday {
            Circle()
                .fill(Palette.coral)
                .frame(width: 6, height: 6)
                .padding(9)
        }
    }

    @ViewBuilder
    private var nameLabel: some View {
        if let profile {
            HStack(spacing: 3) {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8, weight: .heavy))
                }
                Text(isLocked ? strings.maskedProfileName : profile.name)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.6), radius: 3, y: 1)
            .padding(.horizontal, 9)
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var extraCount: some View {
        let extra = day.profiles.count - 1
        if extra > 0 {
            Text(String(format: strings.moreOnDayFormat, extra))
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(Capsule().fill(Palette.coral))
                .padding(7)
        }
    }

    private var accessibilityText: String {
        let date = settings.weekdayDayMonth(day.date)
        guard let profile else { return date }
        let name = isLocked ? strings.maskedProfileName : profile.name
        return "\(date), \(name)\(isLocked ? ", \(strings.lockedBadgeLabel)" : "")"
    }
}
