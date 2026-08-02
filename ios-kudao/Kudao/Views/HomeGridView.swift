//
//  HomeGridView.swift
//  Kudao
//

import SwiftUI

/// The front door of Kudao: a grid of coloured cards, one per occasion.
///
/// Two low "quick action" cards sit on top — the closest date and the plans
/// still waiting for a yes — then one card per occasion, each keeping the exact
/// colour that category wears everywhere else in the app. Empty categories stay
/// on screen with an invitation instead of disappearing.
struct HomeGridView: View {
    let profiles: [BirthdayProfile]
    let collaboration: [UUID: CollaborationSummary]
    /// Opens a profile, honouring the surprise lock.
    let onOpenProfile: (BirthdayProfile) -> Void
    /// Pushes the pre-filtered list screen.
    let onOpenList: (ProfileListScope) -> Void
    /// Starts a new profile, optionally with the occasion already chosen.
    let onCreateProfile: (OccasionKind?) -> Void
    /// Opens the "join with a code" sheet.
    let onJoinShare: () -> Void

    @Environment(AppSettings.self) private var settings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared: Bool = false

    private var strings: Strings { settings.strings }

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    /// Closest date across the whole library.
    private var nextUp: BirthdayProfile? {
        ProfileSortOrder.nearestBirthday.sorted(profiles).first
    }

    private var pendingCount: Int {
        profiles.filter(\.needsPlanConfirmation).count
    }

    private var sharedProfiles: [BirthdayProfile] {
        profiles.filter(\.isCollaborative)
    }

    private var pendingInvites: Int {
        sharedProfiles.reduce(0) { $0 + (collaboration[$1.id]?.pendingInvites ?? 0) }
    }

    /// Everyone who accepted an invitation anywhere, each name once.
    private var companyNames: [String] {
        var seen: Set<String> = []
        var names: [String] = []
        for profile in sharedProfiles {
            for name in collaboration[profile.id]?.participantNames ?? [] where !seen.contains(name) {
                seen.insert(name)
                names.append(name)
            }
        }
        return names
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header

                HStack(spacing: 12) {
                    nextEventCard
                    pendingCard
                }

                sectionLabel(strings.gridCategoriesTitle)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(OccasionKind.allCases.enumerated()), id: \.element) { index, kind in
                        categoryCard(kind)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 22)
                            .animation(
                                reduceMotion ? nil : .smooth(duration: 0.45).delay(Double(index) * 0.06),
                                value: appeared
                            )
                    }
                }

                collaborationCard
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .onAppear { appeared = true }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(strings.homeTitle)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
            Text(strings.homeSubtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
        .padding(.bottom, 2)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(.caption, design: .rounded, weight: .bold))
            .tracking(1.1)
            .foregroundStyle(.secondary)
            .padding(.top, 6)
    }

    // MARK: - Quick actions

    /// Closest celebration: tapping it goes straight into that profile.
    private var nextEventCard: some View {
        let hero = nextUp

        return quickCard(
            symbolName: "sparkles",
            title: strings.gridNextEventTitle,
            value: hero?.name ?? strings.gridNextEventEmpty,
            detail: hero.map { $0.countdown.imminentLabel(strings) },
            tint: hero?.occasion.accent ?? Palette.amber
        ) {
            if let hero { onOpenProfile(hero) }
        }
        .disabled(hero == nil)
    }

    /// Party plans still waiting for a confirmation.
    private var pendingCard: some View {
        let count = pendingCount

        return quickCard(
            symbolName: count > 0 ? "bell.badge.fill" : "checkmark.seal.fill",
            title: strings.reviewBannerTitle,
            value: count > 0
                ? String(format: strings.gridPendingCountFormat, count)
                : strings.gridPendingEmpty,
            detail: nil,
            tint: count > 0 ? Palette.amber : Palette.teal
        ) {
            onOpenList(.pendingPlans)
        }
    }

    private func quickCard(
        symbolName: String,
        title: String,
        value: String,
        detail: String?,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 9) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.14))
                            .frame(width: 30, height: 30)
                        Image(systemName: symbolName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(tint)
                    }

                    Text(title)
                        .font(.system(.footnote, design: .rounded, weight: .bold))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                HStack(spacing: 6) {
                    Text(value)
                        .font(.system(.subheadline, design: .rounded, weight: .heavy))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    if let detail {
                        Text(detail)
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(.white.opacity(0.18)))
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Palette.plum)
            )
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityElement(children: .combine)
    }

    // MARK: - Category cards

    private func categoryCard(_ kind: OccasionKind) -> some View {
        let items = profiles.filter { $0.occasion == kind }
        let next = ProfileSortOrder.nearestBirthday.sorted(items).first

        return Button {
            if items.isEmpty {
                onCreateProfile(kind)
            } else {
                onOpenList(.occasion(.kind(kind)))
            }
        } label: {
            VStack(alignment: .leading, spacing: 9) {
                Image(systemName: kind.symbolName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(items.isEmpty ? AnyShapeStyle(kind.accent) : AnyShapeStyle(Color.white))
                    .frame(height: 24, alignment: .leading)

                Text(kind.pluralTitle(strings))
                    .font(.system(.headline, design: .rounded, weight: .heavy))
                    .foregroundStyle(items.isEmpty ? AnyShapeStyle(Color.primary) : AnyShapeStyle(Color.white))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 4)

                if items.isEmpty {
                    Text(strings.gridCategoryEmptyHint)
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    FlowLayout(spacing: 6, lineSpacing: 6) {
                        statBadge(
                            items.count == 1
                                ? strings.gridProfileCountOne
                                : String(format: strings.gridProfileCountFormat, items.count)
                        )

                        if let next {
                            statBadge(countdownBadge(for: next, kind: kind))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
            .padding(14)
            .background(categoryBackground(kind, isEmpty: items.isEmpty))
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func categoryBackground(_ kind: OccasionKind, isEmpty: Bool) -> some View {
        if isEmpty {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(kind.accent.opacity(0.3), style: StrokeStyle(lineWidth: 1.4, dash: [5, 4]))
                )
        } else {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(kind.gradient)
                .shadow(color: kind.accent.opacity(0.28), radius: 12, y: 7)
        }
    }

    /// Remembrances get a sober "next anniversary" line instead of a festive countdown.
    private func countdownBadge(for profile: BirthdayProfile, kind: OccasionKind) -> String {
        let days = profile.countdown.daysRemaining
        guard kind == .remembrance else { return profile.countdown.imminentLabel(strings) }
        return String(format: strings.gridAnniversaryInFormat, days)
    }

    private func statBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption2, design: .rounded, weight: .bold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Capsule().fill(.white.opacity(0.22)))
    }

    // MARK: - Collaboration

    /// Outlined instead of filled, so it reads as a different kind of thing.
    @ViewBuilder
    private var collaborationCard: some View {
        let shared = sharedProfiles

        Button {
            if shared.isEmpty {
                onJoinShare()
            } else {
                onOpenList(.shared)
            }
        } label: {
            HStack(spacing: 11) {
                ZStack {
                    Circle()
                        .fill(Palette.violet.opacity(0.14))
                        .frame(width: 34, height: 34)
                    Image(systemName: shared.isEmpty ? "person.2.badge.key.fill" : "person.2.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Palette.violet)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(shared.isEmpty ? strings.collaborationInviteTitle : strings.sharedListTitle)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(collaborationCaption(shared.count))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                if !companyNames.isEmpty {
                    ParticipantStack(
                        names: companyNames,
                        size: 24,
                        ringColor: Palette.surface,
                        maxVisible: 3
                    )
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Palette.surface.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Palette.violet.opacity(0.4), lineWidth: 1.4)
            )
        }
        .buttonStyle(PressableCardStyle())
    }

    private func collaborationCaption(_ count: Int) -> String {
        guard count > 0 else { return strings.collaborationInviteMessage }

        let shared = String(format: strings.gridSharedCountFormat, count)
        guard pendingInvites > 0 else { return shared }
        return "\(shared) · \(String(format: strings.pendingInvitesCountFormat, pendingInvites))"
    }
}
