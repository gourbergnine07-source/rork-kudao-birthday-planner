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

    // MARK: Authorship (collaborative profiles)

    /// Kudao id of whoever wrote the note; empty for notes written before sharing existed.
    var authorUserID: String = ""
    var authorName: String = ""
    /// True when the note arrived from another participant of the share room.
    var isRemote: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \DiaryTag.entry)
    var extraction: DiaryTag?

    init(
        textContent: String,
        profile: BirthdayProfile? = nil,
        id: UUID = UUID(),
        createdAt: Date = Date(),
        authorUserID: String = "",
        authorName: String = "",
        isRemote: Bool = false
    ) {
        self.id = id
        self.textContent = textContent
        self.profile = profile
        self.createdAt = createdAt
        self.extractionStatusRaw = ExtractionStatus.pending.rawValue
        self.authorUserID = authorUserID
        self.authorName = authorName
        self.isRemote = isRemote
    }

    var extractionStatus: ExtractionStatus {
        get { ExtractionStatus(rawValue: extractionStatusRaw) ?? .pending }
        set { extractionStatusRaw = newValue.rawValue }
    }

    /// Notes saved before collaboration existed have no author and belong to me.
    func isMine(_ userID: String) -> Bool {
        authorUserID.isEmpty || authorUserID == userID
    }
}
