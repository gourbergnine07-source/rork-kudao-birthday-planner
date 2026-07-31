//
//  BirthdayMessage.swift
//  Kudao
//

import Foundation
import SwiftData

/// The birthday greeting prepared for one profile, plus when the user wants to be reminded to send it.
///
/// Kudao never sends anything by itself: `isSent` is flipped by the user once they
/// confirm they pressed send in WhatsApp, Messages or their mail app.
@Model
final class BirthdayMessage {
    var id: UUID = UUID()
    /// Text shown in the editor: AI generated first, then freely editable.
    var text: String = ""
    /// When the local "time to send your wishes" notification fires.
    var scheduledAt: Date = Date()
    /// Master switch for that notification.
    var isScheduleEnabled: Bool = true
    var isSent: Bool = false
    var sentAt: Date?
    /// Voice the last generation used, so the tone picker reopens where the user left it.
    var toneRaw: String = GreetingTone.warm.rawValue
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    // MARK: Automatic refresh from the diary

    /// When true the draft is rewritten as soon as new notes change the extracted keywords.
    var isAutoRefreshEnabled: Bool = true
    /// Set the moment the user edits the text by hand: automatic rewrites then stop.
    var isUserEdited: Bool = false
    /// Fingerprint of the diary keywords the current text was written from.
    var sourceSignature: String = ""
    /// Last time new diary material rewrote the draft on its own.
    var autoRefreshedAt: Date?

    var profile: BirthdayProfile?

    init(
        text: String = "",
        scheduledAt: Date,
        tone: GreetingTone = .warm,
        profile: BirthdayProfile? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.scheduledAt = scheduledAt
        self.toneRaw = tone.rawValue
        self.profile = profile
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var tone: GreetingTone {
        get { GreetingTone(rawValue: toneRaw) ?? .warm }
        set { toneRaw = newValue.rawValue }
    }

    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasText: Bool { !trimmedText.isEmpty }

    /// True while Kudao is still allowed to rewrite the draft by itself.
    var followsDiary: Bool { isAutoRefreshEnabled && !isUserEdited && !isSent }

    /// Records a manual edit, which freezes the text against automatic rewrites.
    func markUserEdited() {
        guard !isUserEdited else { return }
        isUserEdited = true
        updatedAt = Date()
    }

    /// Hands the draft back to the automatic refresh, dropping the "edited" flag.
    func resumeAutoRefresh() {
        isUserEdited = false
        isAutoRefreshEnabled = true
        updatedAt = Date()
    }

    /// Fire date of the send reminder, or nil when there is nothing left to remind about.
    var reminderFireDate: Date? {
        guard isScheduleEnabled, !isSent, hasText, scheduledAt > Date() else { return nil }
        return scheduledAt
    }

    /// Short lock-screen preview of the greeting.
    var notificationPreview: String {
        let flattened = trimmedText
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespaces)
        guard flattened.count > 120 else { return flattened }
        return String(flattened.prefix(120)) + "\u{2026}"
    }

    func markSent(_ sent: Bool) {
        isSent = sent
        sentAt = sent ? Date() : nil
        updatedAt = Date()
    }

    /// Default send moment: the next birthday at the shared reminder hour.
    static func defaultSendDate(for profile: BirthdayProfile) -> Date {
        profile.reminderFireDate(daysBefore: 0)
            ?? Calendar.current.date(byAdding: .day, value: 1, to: Date())
            ?? Date()
    }
}
