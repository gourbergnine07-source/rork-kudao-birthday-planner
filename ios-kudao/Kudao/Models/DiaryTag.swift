//
//  DiaryTag.swift
//  Kudao
//

import Foundation
import SwiftData

/// Structured data extracted from a diary note by the AI pass.
@Model
final class DiaryTag {
    var id: UUID = UUID()
    var categoryRaw: String = DiaryCategory.other.rawValue
    /// Free keywords such as "sushi", "vinili", "Lisbona".
    var keywords: [String] = []
    var isGiftRelevant: Bool = false
    /// 5-10 word summary of the note.
    var summary: String = ""
    var createdAt: Date = Date()

    var entry: DiaryEntry?
    var profile: BirthdayProfile?

    init(
        category: DiaryCategory,
        keywords: [String],
        isGiftRelevant: Bool,
        summary: String,
        entry: DiaryEntry? = nil,
        profile: BirthdayProfile? = nil
    ) {
        self.id = UUID()
        self.categoryRaw = category.rawValue
        self.keywords = keywords
        self.isGiftRelevant = isGiftRelevant
        self.summary = summary
        self.entry = entry
        self.profile = profile
        self.createdAt = Date()
    }

    var category: DiaryCategory {
        get { DiaryCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}
