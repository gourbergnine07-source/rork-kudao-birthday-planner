//
//  ContactPicker.swift
//  Kudao
//

import ContactsUI
import SwiftUI

/// The system contact picker, returning one address-book entry.
///
/// `CNContactPickerViewController` runs out of process, so choosing a single
/// contact needs no permission prompt at all: iOS hands back only what the user
/// tapped. That is why the profile form uses this instead of reading the whole
/// address book.
struct ContactPicker: UIViewControllerRepresentable {
    /// Called with the picked contact, already mapped to Kudao's own type.
    let onPicked: (ContactCandidate) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let controller = CNContactPickerViewController()
        controller.delegate = context.coordinator
        controller.displayedPropertyKeys = [CNContactBirthdayKey]
        // A contact with no birthday would leave the form half filled.
        controller.predicateForEnablingContact = NSPredicate(format: "birthday != nil")
        return controller
    }

    func updateUIViewController(_ controller: CNContactPickerViewController, context: Context) {
        context.coordinator.onPicked = onPicked
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        var onPicked: (ContactCandidate) -> Void

        init(onPicked: @escaping (ContactCandidate) -> Void) {
            self.onPicked = onPicked
        }

        nonisolated func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            guard let candidate = Self.candidate(from: contact) else { return }
            let handler = onPicked
            Task { @MainActor in handler(candidate) }
        }

        /// Maps a system contact into the app's own value type.
        nonisolated private static func candidate(from contact: CNContact) -> ContactCandidate? {
            guard
                let birthday = contact.birthday,
                birthday.month != nil,
                birthday.day != nil
            else { return nil }

            let given = contact.givenName.trimmingCharacters(in: .whitespacesAndNewlines)
            let family = contact.familyName.trimmingCharacters(in: .whitespacesAndNewlines)
            let nickname = contact.isKeyAvailable(CNContactNicknameKey) ? contact.nickname : ""
            let resolvedGiven = given.isEmpty ? nickname.trimmingCharacters(in: .whitespacesAndNewlines) : given
            guard !resolvedGiven.isEmpty || !family.isEmpty else { return nil }

            return ContactCandidate(
                id: contact.identifier,
                givenName: resolvedGiven,
                familyName: family,
                birthday: birthday,
                photoData: contact.isKeyAvailable(CNContactThumbnailImageDataKey) ? contact.thumbnailImageData : nil,
                phone: contact.isKeyAvailable(CNContactPhoneNumbersKey)
                    ? (contact.phoneNumbers.first?.value.stringValue ?? "")
                    : "",
                email: contact.isKeyAvailable(CNContactEmailAddressesKey)
                    ? (contact.emailAddresses.first?.value as String? ?? "")
                    : ""
            )
        }
    }
}
