//
//  DiaryExportService.swift
//  Kudao
//

import Foundation
import OSLog
import UIKit

/// File formats offered by the diary export.
nonisolated enum DiaryExportFormat: String, CaseIterable, Identifiable, Sendable {
    case pdf
    case json

    var id: String { rawValue }

    var fileExtension: String { rawValue }

    var symbolName: String {
        switch self {
        case .pdf: "doc.richtext"
        case .json: "curlybraces"
        }
    }

    func title(_ strings: Strings) -> String {
        switch self {
        case .pdf: strings.exportPDFAction
        case .json: strings.exportJSONAction
        }
    }
}

nonisolated enum DiaryExportError: LocalizedError {
    case encodingFailed
    case writeFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed: "The diary could not be encoded."
        case .writeFailed: "The export file could not be written."
        }
    }
}

// MARK: - Snapshot

/// Value-type copy of everything the export needs, so rendering never touches the model.
nonisolated struct DiaryExportSnapshot: Sendable {
    struct Note: Sendable {
        let id: UUID
        let text: String
        let createdAt: Date
        let status: String
        let category: String?
        let keywords: [String]
        let summary: String
        let isGiftRelevant: Bool
    }

    struct Keyword: Sendable {
        let category: DiaryCategory
        let values: [String]
    }

    struct Plan: Sendable {
        let giftIdea: String
        let giftPriceBand: PriceBand
        let giftReason: String
        let cakeType: String
        let cakeReason: String
        let venueIdea: String
        let venueReason: String
        let guestCount: Int
        let confidence: SuggestionConfidence
        let generatedAt: Date
        let confirmedAt: Date?
    }

    let profileID: UUID
    let name: String
    let birthDate: Date
    let relationship: RelationshipKind
    let isSurpriseMode: Bool
    let createdAt: Date
    let nextBirthday: Date
    let turningAge: Int
    let notes: [Note]
    let keywords: [Keyword]
    let plan: Plan?
    let exportedAt: Date
}

// MARK: - Service

/// Builds the shareable diary file for one profile.
enum DiaryExportService {
    private static let logger = Logger(subsystem: "com.kudao.app", category: "diary-export")

    /// Reads the profile graph into a Sendable snapshot.
    static func snapshot(of profile: BirthdayProfile) -> DiaryExportSnapshot {
        let countdown = profile.countdown

        let notes = profile.diaryEntries
            .sorted { $0.createdAt > $1.createdAt }
            .map { entry in
                DiaryExportSnapshot.Note(
                    id: entry.id,
                    text: entry.textContent,
                    createdAt: entry.createdAt,
                    status: entry.extractionStatus.rawValue,
                    category: entry.extraction.map { $0.category.rawValue },
                    keywords: entry.extraction?.keywords ?? [],
                    summary: entry.extraction?.summary ?? "",
                    isGiftRelevant: entry.extraction?.isGiftRelevant ?? false
                )
            }

        var buckets: [DiaryCategory: [String]] = [:]
        for tag in profile.diaryTags.sorted(by: { $0.createdAt > $1.createdAt }) {
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
        let keywords = DiaryCategory.allCases.compactMap { category -> DiaryExportSnapshot.Keyword? in
            guard let values = buckets[category], !values.isEmpty else { return nil }
            return DiaryExportSnapshot.Keyword(category: category, values: values)
        }

        let plan = profile.partyPlan.map { stored in
            DiaryExportSnapshot.Plan(
                giftIdea: stored.giftIdea,
                giftPriceBand: PriceBand(rawValue: stored.giftPriceRaw) ?? .medium,
                giftReason: stored.giftReason,
                cakeType: stored.cakeType,
                cakeReason: stored.cakeReason,
                venueIdea: stored.venueIdea,
                venueReason: stored.venueReason,
                guestCount: stored.guestCount,
                confidence: SuggestionConfidence(rawValue: stored.confidenceRaw) ?? .low,
                generatedAt: stored.generatedAt,
                confirmedAt: stored.confirmedAt
            )
        }

        return DiaryExportSnapshot(
            profileID: profile.id,
            name: profile.name,
            birthDate: profile.birthDate,
            relationship: profile.relationship,
            isSurpriseMode: profile.isSurpriseMode,
            createdAt: profile.createdAt,
            nextBirthday: countdown.nextDate,
            turningAge: countdown.turningAge,
            notes: notes,
            keywords: keywords,
            plan: plan,
            exportedAt: Date()
        )
    }

    /// Writes the export into a temporary file and returns its URL for sharing.
    static func writeFile(
        _ snapshot: DiaryExportSnapshot,
        format: DiaryExportFormat,
        strings: Strings,
        locale: Locale
    ) throws -> URL {
        let data: Data
        switch format {
        case .json:
            data = try DiaryExportRenderer.json(snapshot)
        case .pdf:
            data = DiaryExportRenderer.pdf(snapshot, strings: strings, locale: locale)
        }

        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("KudaoExports", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let url = directory.appendingPathComponent(fileName(snapshot, format: format))
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            logger.error("Writing the diary export failed: \(error.localizedDescription, privacy: .public)")
            throw DiaryExportError.writeFailed
        }
        return url
    }

    private static func fileName(_ snapshot: DiaryExportSnapshot, format: DiaryExportFormat) -> String {
        let allowed = CharacterSet.alphanumerics
        let slug = snapshot.name.unicodeScalars
            .map { allowed.contains($0) ? Character($0) : "-" }
            .reduce(into: "") { partial, character in
                if character == "-" && (partial.isEmpty || partial.hasSuffix("-")) { return }
                partial.append(character)
            }
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        let name = slug.isEmpty ? "profilo" : slug
        let stamp = ISO8601DateFormatter.exportStamp.string(from: snapshot.exportedAt)
        return "Kudao-\(name)-\(stamp).\(format.fileExtension)"
    }
}

private extension ISO8601DateFormatter {
    static let exportStamp: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        return formatter
    }()
}
