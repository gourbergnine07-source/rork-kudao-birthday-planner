//
//  EventRecordCard.swift
//  Kudao
//

import SwiftUI

/// One archived cycle, as it appears in the library: a cover, a year, a summary.
///
/// The card is deliberately photographic — a past event is remembered by its
/// picture first — and falls back to a warm monogram panel when that year left
/// no media behind.
struct EventRecordCard: View {
    let record: EventRecord
    let strings: Strings
    /// Shown in the global library, hidden inside a profile that already names itself.
    var showsProfileName: Bool = false

    private var accent: Color { record.occasion.accent }

    private var cover: UIImage? {
        guard let data = record.coverData else { return nil }
        return UIImage(data: data)
    }

    private var summary: String {
        if let plan = record.plan, plan.hasContent {
            return plan.giftIdea.isEmpty ? plan.cakeType : plan.giftIdea
        }
        if let memory = record.memoryHighlights.first {
            return memory
        }
        return record.hasMessage ? record.messageText : strings.libraryNoPlanLabel
    }

    var body: some View {
        HStack(spacing: 14) {
            coverPanel
            details
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }

    private var coverPanel: some View {
        Color.clear
            .frame(width: 72, height: 88)
            .overlay {
                if let cover {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                } else {
                    record.occasion.gradient
                        .overlay {
                            Image(systemName: record.occasion.symbolName)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                }
            }
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                Text(String(record.year))
                    .font(.system(size: 11, design: .rounded).weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(.black.opacity(0.55)))
                    .padding(6)
            }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showsProfileName {
                Text(record.profileName)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .lineLimit(1)
            }

            Text(record.eventDate.formatted(.dateTime.day().month(.wide)))
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(accent)

            Text(summary)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 8) {
                if record.hasMedia {
                    metric("photo.stack.fill", String(record.mediaCount))
                }
                if record.noteCount > 0 {
                    metric(record.occasion.diarySymbolName, String(record.noteCount))
                }
                if record.wasMessageSent {
                    metric("checkmark.seal.fill", strings.librarySentBadge)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metric(_ symbol: String, _ value: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: symbol)
                .font(.system(size: 9, weight: .bold))
            Text(value)
                .font(.system(.caption2, design: .rounded, weight: .semibold))
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Capsule().fill(Palette.surfaceRaised))
    }
}
