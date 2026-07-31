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
    /// Who else is in this profile; `.none` for a solo one.
    var collaboration: CollaborationSummary = .none

    private var countdown: BirthdayCountdown { profile.countdown }
    private var strings: Strings { settings.strings }
    private var occasion: OccasionKind { profile.occasion }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(occasion.gradient)

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.30), .clear],
                        center: .topTrailing,
                        startRadius: 8,
                        endRadius: 260
                    )
                )

            if countdown.isToday && occasion.isFestive {
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
                            OccasionBadge(occasion: occasion, strings: strings, onDark: true)
                            KudaoChip(
                                title: profile.bondOrRelationshipTitle(strings),
                                systemImage: profile.bondOrRelationshipSymbol,
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
                        Text(occasion.todayTitle(strings))
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                    } else {
                        Text("\(countdown.daysRemaining)")
                            .font(.system(size: 62, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())

                        VStack(alignment: .leading, spacing: -2) {
                            Text(countdown.daysRemaining == 1 ? strings.dayUnit : strings.daysUnit)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                            Text(occasion.countdownSuffix(strings))
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .opacity(0.85)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
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
                    Label(milestoneLabel, systemImage: occasion.symbolName)
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(.white.opacity(0.92))
                .padding(.top, 2)

                if collaboration.isCollaborative {
                    collaborationRibbon
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .clipShape(.rect(cornerRadius: 30, style: .continuous))
        .shadow(color: occasion.accent.opacity(0.32), radius: 22, x: 0, y: 12)
        .accessibilityElement(children: .combine)
    }

    /// Faces of everyone in the room, sitting on the coloured card.
    private var collaborationRibbon: some View {
        HStack(spacing: 8) {
            ParticipantStack(
                names: collaboration.participantNames,
                size: 24,
                ringColor: .white.opacity(0.85),
                maxVisible: 4,
                placeholderTint: .white
            )

            Text(collaboration.caption(strings))
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if collaboration.permission == .view {
                Image(systemName: "eye.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
            }

            Spacer(minLength: 0)
        }
        .padding(.leading, 6)
        .padding(.trailing, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(.white.opacity(0.18)))
        .accessibilityElement(children: .combine)
    }

    /// "Compie 34 anni" / "34 anni insieme" / "34 anni fa".
    private var milestoneLabel: String {
        let years = countdown.turningAge
        switch occasion {
        case .birthday:
            return String(format: countdown.isToday ? strings.turnsTodayFormat : strings.turnsFormat, years)
        case .wedding:
            return String(format: strings.anniversaryYearsFormat, years)
        case .remembrance:
            return String(format: strings.yearsAgoFormat, years)
        case .other:
            return String(format: strings.editionYearsFormat, years)
        }
    }
}
