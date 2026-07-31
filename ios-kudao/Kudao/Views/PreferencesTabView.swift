//
//  PreferencesTabView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Preferences tab: every keyword extracted from the diary, grouped by category.
struct PreferencesTabView: View {
    let profile: BirthdayProfile

    @Environment(AppSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var strings: Strings { settings.strings }

    /// Unique keywords per category, newest extraction first.
    private var groups: [(category: DiaryCategory, keywords: [String])] {
        let tags = profile.diaryTags.sorted { $0.createdAt > $1.createdAt }
        var buckets: [DiaryCategory: [String]] = [:]

        for tag in tags {
            for keyword in tag.keywords {
                let cleaned = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !cleaned.isEmpty else { continue }
                var existing = buckets[tag.category] ?? []
                if !existing.contains(where: { $0.localizedCaseInsensitiveCompare(cleaned) == .orderedSame }) {
                    existing.append(cleaned)
                    buckets[tag.category] = existing
                }
            }
        }

        return DiaryCategory.allCases.compactMap { category in
            guard let keywords = buckets[category], !keywords.isEmpty else { return nil }
            return (category, keywords)
        }
    }

    private var giftLeads: [DiaryTag] {
        profile.diaryTags
            .filter { $0.isGiftRelevant && !$0.summary.isEmpty }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        VStack(spacing: 18) {
            if groups.isEmpty && giftLeads.isEmpty {
                PlaceholderPanel(
                    icon: "tag.fill",
                    title: strings.preferencesEmptyTitle,
                    message: strings.preferencesEmptyMessage,
                    tint: Palette.teal
                )
            } else {
                ForEach(groups, id: \.category) { group in
                    categoryCard(group.category, keywords: group.keywords)
                }

                if !groups.isEmpty {
                    Text(strings.removeTagHint)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !giftLeads.isEmpty {
                    giftLeadsCard
                }
            }
        }
        .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: profile.diaryTags.count)
    }

    // MARK: - Cards

    private func categoryCard(_ category: DiaryCategory, keywords: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: category.symbolName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(category.accent)
                Text(category.title(strings))
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                Spacer()
                Text("\(keywords.count)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(category.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(category.accent.opacity(0.14)))
            }

            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(keywords, id: \.self) { keyword in
                    keywordChip(keyword, category: category)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }

    private func keywordChip(_ keyword: String, category: DiaryCategory) -> some View {
        HStack(spacing: 6) {
            Text(keyword)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(category.accent)

            Button {
                remove(keyword, from: category)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(category.accent.opacity(0.75))
                    .frame(width: 18, height: 18)
                    .background(Circle().fill(category.accent.opacity(0.16)))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(strings.removeTagAction): \(keyword)")
        }
        .padding(.leading, 12)
        .padding(.trailing, 6)
        .padding(.vertical, 6)
        .background(Capsule().fill(category.accent.opacity(0.1)))
        .overlay(Capsule().strokeBorder(category.accent.opacity(0.2), lineWidth: 1))
    }

    private var giftLeadsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette.berry)
                Text(strings.giftIdeasSection)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                Spacer()
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(giftLeads) { lead in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Palette.berry)
                            .padding(.top, 3)
                        Text(lead.summary)
                            .font(.system(.footnote, design: .rounded, weight: .medium))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.berry.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.berry.opacity(0.22), lineWidth: 1)
        )
    }

    // MARK: - Actions

    /// Removes a badly extracted keyword from every note in that category.
    private func remove(_ keyword: String, from category: DiaryCategory) {
        for tag in profile.diaryTags where tag.category == category {
            tag.keywords.removeAll { $0.localizedCaseInsensitiveCompare(keyword) == .orderedSame }
        }
        try? modelContext.save()
    }
}
