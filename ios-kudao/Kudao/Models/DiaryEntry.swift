//
//  DiaryEntry.swift
//  Kudao
//

import Foundation
import SwiftData

/// A note the owner collects during the year about the person's tastes.
@Model
final class DiaryEntry {
    var id: UUID = UUID()
    var textContent: String = ""
    var createdAt: Date = Date()
    var profile: BirthdayProfile?
    var extractionStatusRaw: String = ExtractionStatus.pending.rawValue

    @Relationship(deleteRule: .cascade, inverse: \DiaryTag.entry)
    var extraction: DiaryTag?

    init(textContent: String, profile: BirthdayProfile? = nil) {
        self.id = UUID()
        self.textContent = textContent
        self.profile = profile
        self.createdAt = Date()
        self.extractionStatusRaw = ExtractionStatus.pending.rawValue
    }

    var extractionStatus: ExtractionStatus {
        get { ExtractionStatus(rawValue: extractionStatusRaw) ?? .pending }
        set { extractionStatusRaw = newValue.rawValue }
    }
}
