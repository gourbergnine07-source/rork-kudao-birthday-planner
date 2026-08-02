//
//  ContactsCompletionView.swift
//  Kudao
//

import SwiftUI

/// A contact the user picked without a date, plus the date they chose for it.
nonisolated struct ContactDateCompletion: Identifiable, Sendable, Hashable {
    let candidate: ContactCandidate
    let date: Date
    /// True when the day and month are right but the year is a placeholder.
    let hasUnknownYear: Bool

    var id: String { candidate.id }
}

/// Asks for the dates the address book never had.
///
/// Most address books hold names without birthdays, so the import list lets
/// those contacts be picked anyway and this step collects what is missing.
/// Nothing is created until a date is chosen: a contact left untouched is
/// skipped rather than saved with today's date, which would invent a birthday.
struct ContactsCompletionView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    /// Number of picked contacts that already carry a date, shown in the count.
    let readyCount: Int
    let onConfirm: ([ContactDateCompletion]) -> Void

    @State private var drafts: [Draft]

    init(
        candidates: [ContactCandidate],
        readyCount: Int,
        onConfirm: @escaping ([ContactDateCompletion]) -> Void
    ) {
        self.readyCount = readyCount
        self.onConfirm = onConfirm
        _drafts = State(initialValue: candidates.map { Draft(candidate: $0) })
    }

    private var strings: Strings { settings.strings }

    /// Only the contacts the user actually gave a date to.
    private var completions: [ContactDateCompletion] {
        drafts
            .filter(\.isFilled)
            .map {
                ContactDateCompletion(
                    candidate: $0.candidate,
                    date: $0.date,
                    hasUnknownYear: $0.hasUnknownYear
                )
            }
    }

    private var totalCount: Int { readyCount + completions.count }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        Text(strings.contactsCompleteSubtitle)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 4)

                        ForEach(Array(drafts.enumerated()), id: \.element.id) { index, _ in
                            card(at: index)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(strings.contactsCompleteTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(strings.cancelAction) { dismiss() }
                        .font(.system(.body, design: .rounded))
                }
            }
            .safeAreaInset(edge: .bottom) { confirmBar }
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.coral)
        .pausesInterstitials()
    }

    // MARK: - Rows

    private func card(at index: Int) -> some View {
        let draft = drafts[index]

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 13) {
                AvatarView(name: draft.candidate.fullName, photoData: draft.candidate.photoData, size: 44)

                VStack(alignment: .leading, spacing: 5) {
                    Text(draft.candidate.fullName)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .lineLimit(1)

                    badge(
                        draft.isFilled ? strings.contactsCompleteReadyBadge : strings.contactsCompletePendingBadge,
                        tint: draft.isFilled ? Palette.sage : Palette.clay
                    )
                }

                Spacer(minLength: 8)

                Button {
                    drafts[index].isFilled.toggle()
                } label: {
                    Image(systemName: draft.isFilled ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(draft.isFilled ? Palette.coral : Color.secondary.opacity(0.5))
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    draft.isFilled ? strings.contactsCompleteReadyBadge : strings.contactsCompletePendingBadge
                )
            }

            HStack(spacing: 10) {
                Image(systemName: "birthday.cake.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Palette.amber)

                DatePicker(
                    strings.contactsCompleteTitle,
                    selection: Binding(
                        get: { drafts[index].date },
                        set: { newValue in
                            drafts[index].date = newValue
                            drafts[index].isFilled = true
                        }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)

                Spacer(minLength: 0)
            }

            Button {
                drafts[index].hasUnknownYear.toggle()
                drafts[index].isFilled = true
            } label: {
                Label(
                    strings.contactsCompleteUnknownYear,
                    systemImage: draft.hasUnknownYear ? "checkmark.circle.fill" : "circle"
                )
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(draft.hasUnknownYear ? Palette.coral : Color.secondary)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(
                        draft.hasUnknownYear ? Palette.coral.opacity(0.14) : Color.primary.opacity(0.05)
                    )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    draft.isFilled ? Palette.coral.opacity(0.55) : Palette.hairline,
                    lineWidth: draft.isFilled ? 1.5 : 1
                )
        )
        .animation(.smooth(duration: 0.24), value: draft.isFilled)
    }

    private func badge(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .heavy, design: .rounded))
            .foregroundStyle(tint)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Capsule().fill(tint.opacity(0.14)))
    }

    // MARK: - Confirm

    private var confirmBar: some View {
        VStack(spacing: 8) {
            Text(strings.contactsCompleteHint)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                onConfirm(completions)
            } label: {
                Text(
                    totalCount == 1
                        ? strings.contactsCompleteConfirmOne
                        : String(format: strings.contactsCompleteConfirmFormat, totalCount)
                )
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule().fill(totalCount == 0 ? AnyShapeStyle(Color.secondary.opacity(0.3)) : AnyShapeStyle(Palette.warmGradient))
                )
                .shadow(color: Palette.coral.opacity(totalCount == 0 ? 0 : 0.35), radius: 14, y: 8)
            }
            .buttonStyle(PressableCardStyle())
            .disabled(totalCount == 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .animation(.smooth(duration: 0.24), value: totalCount)
    }

    /// One editable line in the sheet.
    private struct Draft: Identifiable {
        let candidate: ContactCandidate
        /// Starts on today only as a neutral anchor; nothing is saved until
        /// `isFilled` flips, so this value never becomes an invented birthday.
        var date: Date = Date()
        var hasUnknownYear: Bool = false
        var isFilled: Bool = false

        var id: String { candidate.id }
    }
}

#Preview {
    ContactsCompletionView(
        candidates: [
            ContactCandidate(
                id: "1",
                givenName: "Giulia",
                familyName: "Rossi",
                birthday: DateComponents(),
                photoData: nil,
                phone: "",
                email: "",
                postalAddress: ""
            ),
            ContactCandidate(
                id: "2",
                givenName: "Marco",
                familyName: "Bianchi",
                birthday: DateComponents(),
                photoData: nil,
                phone: "",
                email: "",
                postalAddress: ""
            ),
        ],
        readyCount: 2,
        onConfirm: { _ in }
    )
    .environment(AppSettings())
}
