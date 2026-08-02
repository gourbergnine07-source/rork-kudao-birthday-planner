//
//  ContactsImportService.swift
//  Kudao
//

import Contacts
import Foundation
import OSLog

/// Where the address-book import currently stands.
nonisolated enum ContactsAccessState: Equatable, Sendable {
    /// Nothing asked yet.
    case idle
    case loading
    /// Contacts read successfully; the array can still be empty.
    case loaded([ContactCandidate])
    /// The user said no, or the device restricts contacts.
    case denied
    /// Reading failed for a reason the user can retry.
    case failed
}

/// Reads the system address book so contacts can become profiles.
///
/// Contacts without a birthday are returned too: the import sheet lets the user
/// add them and asks for the date afterwards, which is the only way to reach the
/// many address books where dates were never filled in.
///
/// Only the fields Kudao actually fills in are requested, and nothing is ever
/// written back: the address book stays exactly as the user left it.
@Observable
final class ContactsImportService {
    private static let logger = Logger(subsystem: "com.kudao.app", category: "contacts")

    private(set) var state: ContactsAccessState = .idle

    /// True once the user has refused access, so the UI can point at Settings.
    var isDenied: Bool { state == .denied }

    /// Requests access if needed and loads every usable contact.
    func load() async {
        state = .loading

        let granted = await Self.requestAccess()
        guard granted else {
            state = .denied
            return
        }

        do {
            let candidates = try await Self.fetchCandidates()
            state = .loaded(candidates)
        } catch {
            Self.logger.error("Reading contacts failed: \(error.localizedDescription, privacy: .public)")
            state = .failed
        }
    }

    /// Resets to the untouched state, used when the sheet closes.
    func reset() {
        state = .idle
    }

    // MARK: - Contacts framework

    private static func requestAccess() async -> Bool {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            return true
        // iOS 18 can grant access to a subset of the address book; whatever the
        // user shared is enough for an import.
        case .limited:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                CNContactStore().requestAccess(for: .contacts) { granted, error in
                    if let error {
                        logger.error("Contacts permission failed: \(error.localizedDescription, privacy: .public)")
                    }
                    continuation.resume(returning: granted)
                }
            }
        default:
            return false
        }
    }

    /// Walks the address book on a background thread and keeps everyone with a name.
    private static func fetchCandidates() async throws -> [ContactCandidate] {
        try await Task.detached(priority: .userInitiated) {
            let keys: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactNicknameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
            ]

            let request = CNContactFetchRequest(keysToFetch: keys)
            request.sortOrder = .givenName
            request.unifyResults = true

            var found: [ContactCandidate] = []
            var seen: Set<String> = []

            try CNContactStore().enumerateContacts(with: request) { contact, _ in
                let stored = contact.birthday
                let birthday = (stored?.month != nil && stored?.day != nil) ? stored : nil

                let given = contact.givenName.trimmingCharacters(in: .whitespacesAndNewlines)
                let family = contact.familyName.trimmingCharacters(in: .whitespacesAndNewlines)
                let nickname = contact.nickname.trimmingCharacters(in: .whitespacesAndNewlines)

                // A card with nobody attached to it is not worth importing.
                let resolvedGiven = given.isEmpty ? nickname : given
                guard !resolvedGiven.isEmpty || !family.isEmpty else { return }

                let candidate = ContactCandidate(
                    id: contact.identifier,
                    givenName: resolvedGiven,
                    familyName: family,
                    birthday: birthday ?? DateComponents(),
                    photoData: contact.thumbnailImageData,
                    phone: contact.phoneNumbers.first?.value.stringValue ?? "",
                    email: contact.emailAddresses.first?.value as String? ?? ""
                )

                // Unified contacts can still repeat across accounts.
                guard seen.insert(candidate.matchKey).inserted else { return }
                found.append(candidate)
            }

            return found.sorted {
                $0.fullName.localizedStandardCompare($1.fullName) == .orderedAscending
            }
        }.value
    }
}
