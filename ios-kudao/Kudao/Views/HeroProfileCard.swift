//
//  HeroProfileCard.swift
//  Kudao
//

import SwiftUI

/// Large highlight card for the closest upcoming birthday.
struct HeroProfileCard: View {
    let profile: BirthdayProfile
    let settings: AppSettings
    /// True when the profile sits behind Face ID / Touch ID / passcode.
    var isLocked: Bool = false

    private var countdown: BirthdayCountdown { profile.countdown }
    private var strings: Strings { settings.strings }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Palette.warmGradient)

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.30), .clear],
                        center: .topTrailing,
                        startRadius: 8,
                        endRadius: 260
                    )
                )

            if countdown.isToday {
                ConfettiView()
                    .clipShape(.rect(cornerRadius: 30, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    AvatarView(
                        name: profile.name,
                        photoData: profile.photoData,
                        size: 60,
                        ringColor: .white.opacity(0.55),
                        ringWidth: 2
                    )
                    .overlay(alignment: .topTrailing) {
                        if profile.needsPlanConfirmation {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 15, height: 15)
                                .overlay(Circle().strokeBorder(.white.opacity(0.9), lineWidth: 2.5))
                                .offset(x: 2, y: -1)
                                .accessibilityLabel(strings.pendingBadgeLabel)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(profile.name)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            KudaoChip(
                                title: profile.relationship.title(strings),
                                systemImage: profile.relationship.symbolName,
                                onDark: true
                            )
                            if profile.isSurpriseMode {
                                KudaoChip(
                                    title: isLocked ? strings.lockedBadgeLabel : strings.surpriseBadge,
                                    systemImage: isLocked ? "lock.fill" : "eye.slash.fill",
                                    onDark: true
                                )
                            }
                        }
                    }

                    Spacer(minLength: 0)
                }

                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    if countdown.isToday {
                        Text(strings.todayTitle)
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(countdown.daysRemaining)")
                            .font(.system(size: 62, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())

                        VStack(alignment: .leading, spacing: -2) {
                            Text(countdown.daysRemaining == 1 ? strings.dayUnit : strings.daysUnit)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                            Text(strings.daysToGo)
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .opacity(0.85)
                        }
                        .foregroundStyle(.white)
                        .padding(.bottom, 8)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    Label(settings.weekdayDayMonth(countdown.nextDate), systemImage: "calendar")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                    Spacer(minLength: 0)
                    Label(
                        String(format: countdown.isToday ? strings.turnsTodayFormat : strings.turnsFormat, countdown.turningAge),
                        systemImage: "birthday.cake.fill"
                    )
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                }
                .foregroundStyle(.white.opacity(0.92))
                .padding(.top, 2)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .clipShape(.rect(cornerRadius: 30, style: .continuous))
        .shadow(color: Palette.coral.opacity(0.32), radius: 22, x: 0, y: 12)
        .accessibilityElement(children: .combine)
    }
}
