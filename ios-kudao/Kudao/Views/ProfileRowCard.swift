//
//  ProfileRowCard.swift
//  Kudao
//

import SwiftUI

/// Compact card for every profile after the closest one.
struct ProfileRowCard: View {
    let profile: BirthdayProfile
    let settings: AppSettings
    /// True when the profile sits behind Face ID / Touch ID / passcode.
    var isLocked: Bool = false

    private var countdown: BirthdayCountdown { profile.countdown }
    private var strings: Strings { settings.strings }

    private var occasion: OccasionKind { profile.occasion }

    private var ringCaption: String {
        if countdown.isToday { return occasion.isFestive ? "🎉" : "✦" }
        return countdown.daysRemaining == 1 ? strings.dayUnit : strings.daysUnit
    }

    /// Dates inside the next seven days get a warm, unmistakable treatment.
    private var isImminent: Bool { countdown.isThisWeek }

    private var accent: Color { isImminent ? occasion.accent : profile.relationship.accent }

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(name: profile.name, photoData: profile.photoData, size: 52)
                .overlay(alignment: .bottomTrailing) {
                    // The occasion glyph rides the avatar, readable at a glance.
                    Image(systemName: occasion.symbolName)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 21, height: 21)
                        .background(Circle().fill(occasion.gradient))
                        .overlay(Circle().strokeBorder(cardFill, lineWidth: 2))
                        .offset(x: 3, y: 2)
                        .accessibilityLabel(occasion.title(strings))
                }
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
                        HStack(spacing: 3) {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 9, weight: .bold))
                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 9, weight: .bold))
                            }
                        }
                        .foregroundStyle(Palette.berry)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Palette.berry.opacity(0.14)))
                        .accessibilityLabel(
                            isLocked ? "\(strings.surpriseBadge), \(strings.lockedBadgeLabel)" : strings.surpriseBadge
                        )
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: profile.bondOrRelationshipSymbol)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(occasion.usesBond ? Palette.sage : profile.relationship.accent)
                    Text(settings.dayMonth(countdown.nextDate))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                if isImminent {
                    KudaoChip(
                        title: countdown.imminentLabel(strings),
                        systemImage: imminentSymbol,
                        tint: occasion.accent
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
                    .fill(occasion.gradient)
                    .frame(width: 4)
                    .padding(.vertical, 14)
                    .padding(.leading, 3)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    isImminent ? occasion.accent.opacity(0.42) : Palette.hairline,
                    lineWidth: isImminent ? 1.5 : 1
                )
        )
        .shadow(
            color: isImminent ? occasion.accent.opacity(0.18) : Color.black.opacity(0.05),
            radius: isImminent ? 14 : 10,
            x: 0,
            y: 6
        )
        .accessibilityElement(children: .combine)
    }

    private var imminentSymbol: String {
        guard occasion.isFestive else { return countdown.isToday ? "leaf.fill" : "hourglass" }
        return countdown.isToday ? "party.popper.fill" : "flame.fill"
    }

    private var cardFill: Color {
        // A remembrance stays on the calm surface even when the date is close.
        isImminent && occasion.isFestive ? Palette.surfaceRaised : Palette.surface
    }
}
