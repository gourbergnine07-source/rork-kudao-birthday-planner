//
//  ParticipantsView.swift
//  Kudao
//

import SwiftUI
import SwiftData
import UIKit

/// Who has access to a profile, with owner-only revoke controls.
struct ParticipantsView: View {
    let profile: BirthdayProfile

    @Environment(AppSettings.self) private var settings
    @Environment(KudaoIdentity.self) private var identity
    @Environment(CollaborationService.self) private var collaboration
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var pendingRemoval: ProfileShare?
    @State private var isSharingInvite: String?
    @State private var copiedCode: String?

    private var strings: Strings { settings.strings }

    private var allShares: [ProfileShare] {
        collaboration.shares(for: profile, context: modelContext)
    }

    private var participants: [ProfileShare] {
        allShares
            .filter { !$0.sharedWithUserID.isEmpty }
            .sorted { lhs, rhs in
                if lhs.isOwner != rhs.isOwner { return lhs.isOwner }
                return lhs.invitedAt < rhs.invitedAt
            }
    }

    private var pendingInvites: [ProfileShare] {
        allShares
            .filter { $0.sharedWithUserID.isEmpty && !$0.inviteCode.isEmpty }
            .sorted { $0.invitedAt > $1.invitedAt }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if participants.isEmpty && pendingInvites.isEmpty {
                            PlaceholderPanel(
                                icon: "person.2.fill",
                                title: strings.participantsEmptyTitle,
                                message: strings.participantsEmptyMessage,
                                tint: Palette.violet
                            )
                            .padding(.top, 8)
                        }

                        if !participants.isEmpty {
                            sectionTitle(
                                String(format: strings.participantsCountFormat, participants.count)
                            )
                            VStack(spacing: 10) {
                                ForEach(participants) { share in
                                    participantRow(share)
                                }
                            }
                        }

                        if !pendingInvites.isEmpty {
                            sectionTitle(strings.participantPendingTitle)
                            VStack(spacing: 10) {
                                ForEach(pendingInvites) { invite in
                                    pendingRow(invite)
                                }
                            }
                        }

                        if let message = collaboration.errorMessage {
                            Text(message)
                                .font(.system(.footnote, design: .rounded, weight: .medium))
                                .foregroundStyle(Palette.berry)
                                .padding(.top, 4)
                        }

                        Text(profile.isOwnedByMe ? strings.ownerCannotBeRemoved : strings.guestLeaveHint)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.tertiary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await collaboration.sync(
                        profile: profile,
                        identity: identity,
                        strings: strings,
                        context: modelContext
                    )
                }
            }
            .navigationTitle(strings.participantsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(strings.doneAction) { dismiss() }
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
            .sheet(item: Binding(
                get: { isSharingInvite.map(InviteText.init) },
                set: { isSharingInvite = $0?.code }
            )) { item in
                ShareSheet(text: String(format: strings.inviteMessageFormat, profile.name, item.code))
            }
            .alert(
                strings.removeParticipantAction,
                isPresented: Binding(get: { pendingRemoval != nil }, set: { if !$0 { pendingRemoval = nil } })
            ) {
                Button(strings.cancelAction, role: .cancel) { pendingRemoval = nil }
                Button(strings.removeParticipantAction, role: .destructive) {
                    if let share = pendingRemoval { remove(share) }
                    pendingRemoval = nil
                }
            } message: {
                Text(
                    String(
                        format: strings.removeParticipantConfirmFormat,
                        pendingRemoval?.displayName ?? ""
                    )
                )
            }
            .task {
                await collaboration.sync(
                    profile: profile,
                    identity: identity,
                    strings: strings,
                    context: modelContext
                )
            }
        }
        .tint(Palette.coral)
        .environment(\.locale, settings.locale)
    }

    /// Wraps an invite code so it can drive an `item:` sheet.
    private struct InviteText: Identifiable {
        let code: String
        var id: String { code }
    }

    // MARK: - Rows

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(.caption, design: .rounded, weight: .bold))
            .tracking(1.1)
            .foregroundStyle(.secondary)
            .padding(.top, 6)
    }

    private func participantRow(_ share: ProfileShare) -> some View {
        let isMe = share.sharedWithUserID == identity.userID
        let canRemove = profile.isOwnedByMe && !share.isOwner && !isMe

        return HStack(spacing: 12) {
            AvatarView(name: share.displayName, photoData: nil, size: 42)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(share.displayName.isEmpty ? strings.participantUnknown : share.displayName)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .lineLimit(1)

                    if isMe {
                        Text(strings.participantYou)
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundStyle(Palette.coral)
                    }
                }

                HStack(spacing: 6) {
                    if share.isOwner {
                        KudaoChip(
                            title: strings.participantOwnerBadge,
                            systemImage: "crown.fill",
                            tint: Palette.amber
                        )
                    } else {
                        KudaoChip(
                            title: share.permission.title(strings),
                            systemImage: share.permission.symbolName,
                            tint: share.permission.accent
                        )
                    }
                }

                if let acceptedAt = share.acceptedAt {
                    Text(String(format: strings.joinedAtFormat, settings.noteTimestamp(acceptedAt)))
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer(minLength: 0)

            if canRemove {
                Button {
                    pendingRemoval = share
                } label: {
                    Image(systemName: "person.badge.minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Palette.berry)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Palette.berry.opacity(0.12)))
                }
                .buttonStyle(PressableCardStyle())
                .accessibilityLabel("\(strings.removeParticipantAction) \(share.displayName)")
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Palette.surface))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Palette.hairline, lineWidth: 1))
    }

    private func pendingRow(_ invite: ProfileShare) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Palette.violet.opacity(0.14))
                        .frame(width: 42, height: 42)
                    Image(systemName: "hourglass")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Palette.violet)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(invite.inviteCode)
                        .font(.system(.headline, design: .monospaced, weight: .bold))
                        .tracking(3)
                    KudaoChip(
                        title: invite.permission.title(strings),
                        systemImage: invite.permission.symbolName,
                        tint: invite.permission.accent
                    )
                }

                Spacer(minLength: 0)

                if profile.isOwnedByMe {
                    Button {
                        collaboration.discardPendingInvite(
                            code: invite.inviteCode,
                            profile: profile,
                            context: modelContext
                        )
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Palette.surfaceRaised))
                    }
                    .buttonStyle(PressableCardStyle())
                    .accessibilityLabel(strings.discardInviteAction)
                }
            }

            if profile.isOwnedByMe {
                HStack(spacing: 10) {
                    Button {
                        UIPasteboard.general.string = invite.inviteCode
                        copiedCode = invite.inviteCode
                    } label: {
                        Label(
                            copiedCode == invite.inviteCode ? strings.copiedLabel : strings.copyCodeAction,
                            systemImage: copiedCode == invite.inviteCode ? "checkmark" : "doc.on.doc"
                        )
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(Palette.coral)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Palette.coral.opacity(0.12)))
                    }
                    .buttonStyle(PressableCardStyle())

                    Button {
                        isSharingInvite = invite.inviteCode
                    } label: {
                        Label(strings.shareInviteAction, systemImage: "square.and.arrow.up")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(Palette.violet)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Palette.violet.opacity(0.12)))
                    }
                    .buttonStyle(PressableCardStyle())
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Palette.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.violet.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Actions

    private func remove(_ share: ProfileShare) {
        let userID = share.sharedWithUserID
        Task {
            await collaboration.removeParticipant(
                userID: userID,
                profile: profile,
                identity: identity,
                strings: strings,
                context: modelContext
            )
        }
    }
}
