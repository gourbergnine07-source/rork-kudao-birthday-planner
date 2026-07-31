//
//  NotificationService.swift
//  Kudao
//

import Foundation
import Observation
import OSLog
import SwiftData
import UIKit
import UserNotifications

/// How much a reminder is allowed to reveal on the lock screen.
nonisolated struct ReminderPrivacy: Sendable, Equatable {
    /// Surprise profiles get a neutral "Kudao reminder" wording instead of the name.
    let hidesSurprisePreviews: Bool

    static let revealing = ReminderPrivacy(hidesSurprisePreviews: false)
}

/// One local notification Kudao wants scheduled.
nonisolated struct ScheduledReminder: Sendable, Identifiable, Equatable {
    let id: String
    let title: String
    let body: String
    let fireDate: Date
    let profileID: UUID
    /// Which screen the tap should open: the plan review or the ready-to-send message.
    let kind: ReminderKind
}

/// The reminders Kudao schedules, in the order they fire before a birthday.
nonisolated enum ReminderKind: String, Sendable, CaseIterable {
    case gift
    case birthday
    case message
}

/// Schedules the local birthday and gift reminders and routes notification taps.
///
/// Everything is local: no push backend is involved. Reminders are rescheduled
/// whenever the home screen appears or the app returns to the foreground, so a
/// fired notification is immediately replaced by next year's occurrence.
@Observable
final class NotificationService {
    static let shared = NotificationService()

    /// Prefix shared by every request Kudao owns, so foreign requests are never touched.
    private static let prefix = "kudao.reminder."
    static let profileKey = "profileID"
    static let kindKey = "kind"

    private let center = UNUserNotificationCenter.current()
    private let router = NotificationRouter()
    private let logger = Logger(subsystem: "com.kudao.app", category: "notifications")

    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    /// Set when the user taps a reminder: the home screen opens the confirmation sheet.
    var pendingReviewProfileID: UUID?
    /// Set when the user taps a send-your-wishes reminder: the message tab opens.
    var pendingMessageProfileID: UUID?

    private init() {}

    var isDenied: Bool { authorizationStatus == .denied }

    /// Installs the delegate that routes taps. Called once at app launch.
    func bootstrap() {
        center.delegate = router
        Task { await refreshStatus() }
    }

    func refreshStatus() async {
        authorizationStatus = await center.notificationSettings().authorizationStatus
    }

    /// Asks for permission the first time only; returns whether reminders can be delivered.
    @discardableResult
    func requestAuthorization() async -> Bool {
        await refreshStatus()
        if authorizationStatus == .notDetermined {
            do {
                _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                logger.error("Notification permission request failed: \(error.localizedDescription, privacy: .public)")
            }
            await refreshStatus()
        }
        return canDeliver
    }

    private var canDeliver: Bool {
        authorizationStatus == .authorized || authorizationStatus == .provisional
    }

    /// Rebuilds the full set of pending reminders for the given profiles.
    func sync(
        profiles: [BirthdayProfile],
        strings: Strings,
        privacy: ReminderPrivacy = .revealing
    ) async {
        let reminders = profiles.flatMap {
            Self.reminders(for: $0, strings: strings, privacy: privacy)
        }

        guard await requestAuthorization() else {
            center.removeAllPendingNotificationRequests()
            return
        }

        let wanted = Set(reminders.map(\.id))
        let pending = await center.pendingNotificationRequests()
        let stale = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(Self.prefix) && !wanted.contains($0) }

        if !stale.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: stale)
        }

        for reminder in reminders {
            await schedule(reminder)
        }
    }

    /// Reschedules only one profile's reminders, leaving every other profile untouched.
    func sync(
        profile: BirthdayProfile,
        strings: Strings,
        privacy: ReminderPrivacy = .revealing
    ) async {
        let reminders = Self.reminders(for: profile, strings: strings, privacy: privacy)

        guard await requestAuthorization() else { return }

        let wanted = Set(reminders.map(\.id))
        let stale = Self.identifiers(for: profile.id).filter { !wanted.contains($0) }
        if !stale.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: stale)
        }

        for reminder in reminders {
            await schedule(reminder)
        }
    }

    /// Drops every reminder belonging to a profile, used when it gets deleted.
    func cancelReminders(for profileID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: Self.identifiers(for: profileID))
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func consumePendingReview() {
        pendingReviewProfileID = nil
    }

    func consumePendingMessage() {
        pendingMessageProfileID = nil
    }

    // MARK: - Scheduling

    private func schedule(_ reminder: ScheduledReminder) async {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        content.userInfo = [
            Self.profileKey: reminder.profileID.uuidString,
            Self.kindKey: reminder.kind.rawValue,
        ]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)

        do {
            // Adding with an existing identifier replaces the pending request.
            try await center.add(request)
        } catch {
            logger.error("Scheduling a reminder failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private static func identifier(kind: ReminderKind, profileID: UUID) -> String {
        "\(prefix)\(kind.rawValue).\(profileID.uuidString)"
    }

    /// Every request identifier Kudao may own for a profile.
    private static func identifiers(for profileID: UUID) -> [String] {
        ReminderKind.allCases.map { identifier(kind: $0, profileID: profileID) }
    }

    /// Builds the reminders a profile currently deserves.
    static func reminders(
        for profile: BirthdayProfile,
        strings: Strings,
        privacy: ReminderPrivacy = .revealing
    ) -> [ScheduledReminder] {
        guard !profile.isDeleted else { return [] }

        let name = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return [] }

        /// Surprise profiles can be stripped of every identifying detail.
        let isDiscreet = privacy.hidesSurprisePreviews && profile.isSurpriseMode
        var result: [ScheduledReminder] = []

        if let fireDate = profile.birthdayReminderDate {
            result.append(
                ScheduledReminder(
                    id: identifier(kind: .birthday, profileID: profile.id),
                    title: isDiscreet ? strings.notificationGenericTitle : strings.notificationBirthdayTitle,
                    body: isDiscreet
                        ? strings.notificationGenericBody
                        : String(format: strings.notificationBirthdayBodyFormat, name),
                    fireDate: fireDate,
                    profileID: profile.id,
                    kind: .birthday
                )
            )
        }

        if let fireDate = profile.giftReminderDate {
            let giftIdea = profile.partyPlan?.giftIdea.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let revealingBody = giftIdea.isEmpty
                ? String(format: strings.notificationGiftBodyFallbackFormat, name)
                : String(format: strings.notificationGiftBodyFormat, name, giftIdea)

            result.append(
                ScheduledReminder(
                    id: identifier(kind: .gift, profileID: profile.id),
                    title: isDiscreet ? strings.notificationGenericTitle : strings.notificationGiftTitle,
                    body: isDiscreet ? strings.notificationGenericBody : revealingBody,
                    fireDate: fireDate,
                    profileID: profile.id,
                    kind: .gift
                )
            )
        }

        // The greeting the user scheduled, with a preview of the text they will send.
        if let message = profile.birthdayMessage,
           !message.isDeleted,
           let fireDate = message.reminderFireDate {
            let revealingBody = [
                String(format: strings.notificationMessageBodyFormat, name),
                message.notificationPreview,
            ].joined(separator: "\n")

            result.append(
                ScheduledReminder(
                    id: identifier(kind: .message, profileID: profile.id),
                    title: isDiscreet ? strings.notificationGenericTitle : strings.notificationMessageTitle,
                    body: isDiscreet ? strings.notificationGenericBody : revealingBody,
                    fireDate: fireDate,
                    profileID: profile.id,
                    kind: .message
                )
            )
        }

        return result
    }
}

/// Bridges `UNUserNotificationCenterDelegate` callbacks (which arrive off the main actor)
/// into the observable service.
final class NotificationRouter: NSObject, UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let info = response.notification.request.content.userInfo
        let raw = info[NotificationService.profileKey] as? String
        guard let raw, let profileID = UUID(uuidString: raw) else { return }
        let kind = ReminderKind(rawValue: info[NotificationService.kindKey] as? String ?? "") ?? .birthday

        await MainActor.run {
            switch kind {
            case .message:
                NotificationService.shared.pendingMessageProfileID = profileID
            case .birthday, .gift:
                NotificationService.shared.pendingReviewProfileID = profileID
            }
        }
    }
}
