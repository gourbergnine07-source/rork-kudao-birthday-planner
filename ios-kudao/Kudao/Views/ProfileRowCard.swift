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

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(name: profile.name, photoData: profile.photoData, size: 52)

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
            }

            Spacer(minLength: 8)

            CountdownRing(
                progress: countdown.yearProgress,
                value: "\(countdown.daysRemaining)",
                caption: ringCaption,
                tint: profile.relationship.accent,
                size: 58
            )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
        .accessibilityElement(children: .combine)
    }
}
