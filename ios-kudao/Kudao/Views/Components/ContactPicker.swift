//
//  ContactPicker.swift
//  Kudao
//

import ContactsUI
import SwiftUI

/// The system contact picker, returning one address-book entry.
///
/// `CNContactPickerViewController` runs out of process: the list, the search
/// field and the scrolling all belong to iOS, and only the single card the user
/// taps is handed back. Nothing else of the address book is ever visible to the
/// app, which is why this needs no permission prompt of its own.
struct ContactPicker: UIViewControllerRepresentable {
    /// Called with the picked contact, already mapped to Kudao's own type.
    let onPicked: (ContactCandidate) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let controller = CNContactPickerViewController()
        controller.delegate = context.coordinator
        // No predicate and no displayed keys: every contact stays tappable and
        // one tap returns the whole card. A missing birthday is not a reason to
        // refuse a contact — the form simply leaves that field alone.
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
        ///
        /// Every field is optional: the picker only guarantees a name, so each
        /// property is read behind `isKeyAvailable` and missing ones come back
        /// empty rather than blocking the import.
        nonisolated private static func candidate(from contact: CNContact) -> ContactCandidate? {
            let stored = contact.isKeyAvailable(CNContactBirthdayKey) ? contact.birthday : nil
            let birthday = (stored?.month != nil && stored?.day != nil) ? stored : nil

            let given = contact.givenName.trimmingCharacters(in: .whitespacesAndNewlines)
            let family = contact.familyName.trimmingCharacters(in: .whitespacesAndNewlines)
            let nickname = contact.isKeyAvailable(CNContactNicknameKey) ? contact.nickname : ""
            let resolvedGiven = given.isEmpty ? nickname.trimmingCharacters(in: .whitespacesAndNewlines) : given
            // A card with no name at all would fill nothing.
            guard !resolvedGiven.isEmpty || !family.isEmpty else { return nil }

            return ContactCandidate(
                id: contact.identifier,
                givenName: resolvedGiven,
                familyName: family,
                birthday: birthday ?? DateComponents(),
                photoData: photoData(from: contact),
                phone: contact.isKeyAvailable(CNContactPhoneNumbersKey)
                    ? (contact.phoneNumbers.first?.value.stringValue ?? "")
                    : "",
                email: contact.isKeyAvailable(CNContactEmailAddressesKey)
                    ? (contact.emailAddresses.first?.value as String? ?? "")
                    : "",
                postalAddress: postalAddress(from: contact)
            )
        }

        /// The best picture the card holds, shrunk exactly like a picked photo.
        ///
        /// The full-size image is preferred over the thumbnail so the avatar
        /// stays sharp, then it goes through the same downscaler used by the
        /// camera and the photo library.
        nonisolated private static func photoData(from contact: CNContact) -> Data? {
            let full = contact.isKeyAvailable(CNContactImageDataKey) ? contact.imageData : nil
            let thumbnail = contact.isKeyAvailable(CNContactThumbnailImageDataKey)
                ? contact.thumbnailImageData
                : nil
            guard let source = full ?? thumbnail else { return nil }
            return ImageDownscaler.compress(source) ?? source
        }

        /// The home address, or the first one on the card, flattened to one line.
        nonisolated private static func postalAddress(from contact: CNContact) -> String {
            guard contact.isKeyAvailable(CNContactPostalAddressesKey) else { return "" }

            let addresses = contact.postalAddresses
            let preferred = addresses.first { $0.label == CNLabelHome } ?? addresses.first
            guard let value = preferred?.value else { return "" }

            return CNPostalAddressFormatter
                .string(from: value, style: .mailingAddress)
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
        }
    }
}
