//
//  ProfileRowCard.swift
//  Kudao
//

import SwiftUI

/// Compact card for every profile after the closest one.
struct ProfileRowCard: View {
    let profile: BirthdayProfile
    let settings: AppSettings

    private var countdown: BirthdayCountdown { profile.countdown }
    private var strings: Strings { settings.strings }

    private var ringCaption: String {
        if countdown.isToday { return "🎉" }
        return countdown.daysRemaining == 1 ? strings.dayUnit : strings.daysUnit
    }

    /// Birthdays inside the next seven days get a warm, unmistakable treatment.
    private var isImminent: Bool { countdown.isThisWeek }

    private var accent: Color { isImminent ? Palette.coral : profile.relationship.accent }

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(name: profile.name, photoData: profile.photoData, size: 52)
                .overlay(alignment: .topTrailing) {
                    if profile.needsPlanConfirmation {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 13, height: 13)
                            .overlay(Circle().strokeBorder(cardFill, lineWidth: 2.5))
                            .offset(x: 2, y: -1)
                            .accessibilityLabel(strings.pendingBadgeLabel)
                    }
                }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(profile.name)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if profile.isSurpriseMode {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Palette.berry)
                            .accessibilityLabel(strings.surpriseBadge)
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: profile.relationship.symbolName)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(profile.relationship.accent)
                    Text(settings.dayMonth(countdown.nextDate))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                if isImminent {
                    KudaoChip(
                        title: countdown.imminentLabel(strings),
                        systemImage: countdown.isToday ? "party.popper.fill" : "flame.fill",
                        tint: Palette.coral
                    )
                    .padding(.top, 1)
                    .accessibilityLabel("\(strings.imminentBadge), \(countdown.imminentLabel(strings))")
                }
            }

            Spacer(minLength: 8)

            CountdownRing(
                progress: countdown.yearProgress,
                value: "\(countdown.daysRemaining)",
                caption: ringCaption,
                tint: accent,
                size: 58
            )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(cardFill)
        )
        .overlay(alignment: .leading) {
            if isImminent {
                Capsule()
                    .fill(Palette.warmGradient)
                    .frame(width: 4)
                    .padding(.vertical, 14)
                    .padding(.leading, 3)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    isImminent ? Palette.coral.opacity(0.42) : Palette.hairline,
                    lineWidth: isImminent ? 1.5 : 1
                )
        )
        .shadow(
            color: isImminent ? Palette.coral.opacity(0.18) : Color.black.opacity(0.05),
            radius: isImminent ? 14 : 10,
            x: 0,
            y: 6
        )
        .accessibilityElement(children: .combine)
    }

    private var cardFill: Color {
        isImminent ? Palette.surfaceRaised : Palette.surface
    }
}
