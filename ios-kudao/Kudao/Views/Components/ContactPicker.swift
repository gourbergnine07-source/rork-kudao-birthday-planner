//
//  ContactPicker.swift
//  Kudao
//

import ContactsUI
import SwiftUI

/// The system contact picker, presented as a modal over whatever is on screen.
///
/// `CNContactPickerViewController` runs out of process: the list, the search
/// field and the scrolling all belong to iOS, and only the single card the user
/// taps is handed back. Nothing else of the address book is ever visible to the
/// app, which is why this needs no permission prompt of its own.
///
/// It is deliberately *not* wrapped in a SwiftUI `.sheet`. Being a remote view
/// controller it dismisses itself once a card is tapped, and inside a sheet that
/// dismissal walks the whole presented stack: the profile form went down with it
/// and the user landed back on the Home grid. Instead an invisible host lives in
/// the background of the form and presents the picker from UIKit, so the form
/// stays alive underneath with every field the user already typed, and closing
/// the picker closes only the picker.
struct ContactPickerPresenter: UIViewControllerRepresentable {
    /// Drives the presentation; set back to `false` on pick or on cancel.
    @Binding var isPresented: Bool
    /// Called with the picked contact, already mapped to Kudao's own type.
    let onPicked: (ContactCandidate) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let host = UIViewController()
        host.view.backgroundColor = .clear
        // The host is only an anchor for the presentation: it must never take a
        // touch away from the form it sits behind.
        host.view.isUserInteractionEnabled = false
        return host
    }

    func updateUIViewController(_ host: UIViewController, context: Context) {
        let coordinator = context.coordinator
        coordinator.onPicked = onPicked
        coordinator.onFinish = { isPresented = false }
        coordinator.sync(isPresented: isPresented, from: host)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        var onPicked: (ContactCandidate) -> Void
        /// Puts the binding back to `false` once the picker is gone.
        var onFinish: () -> Void = {}

        private weak var picker: CNContactPickerViewController?
        /// Mirrors the binding, so a state refresh never presents twice.
        private var isShowing = false

        init(onPicked: @escaping (ContactCandidate) -> Void) {
            self.onPicked = onPicked
        }

        @MainActor
        func sync(isPresented: Bool, from host: UIViewController) {
            if isPresented, !isShowing {
                isShowing = true
                present(from: host, attempt: 0)
            } else if !isPresented, isShowing {
                isShowing = false
                picker?.presentingViewController?.dismiss(animated: true)
                picker = nil
            }
        }

        @MainActor
        private func present(from host: UIViewController, attempt: Int) {
            // A tap can land a moment before the host is in a window, or while
            // the keyboard's own transition still owns the presentation slot.
            guard isShowing else { return }
            guard let presenter = Self.presenter(for: host) else {
                guard attempt < 12 else {
                    isShowing = false
                    onFinish()
                    return
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(80))
                    self.present(from: host, attempt: attempt + 1)
                }
                return
            }

            let controller = CNContactPickerViewController()
            controller.delegate = self
            // No predicate and no displayed keys: every contact stays tappable
            // and one tap returns the whole card. A missing birthday is not a
            // reason to refuse a contact — the form leaves that field alone.
            picker = controller
            presenter.present(controller, animated: true)
        }

        /// The view controller that owns the screen the form is drawn in.
        ///
        /// Presenting from the topmost ancestor keeps the picker a sibling of the
        /// form rather than a child of it, which is what stops its dismissal from
        /// cascading down the stack.
        @MainActor
        private static func presenter(for host: UIViewController) -> UIViewController? {
            guard host.view.window != nil else { return nil }

            var candidate = host
            while let parent = candidate.parent { candidate = parent }
            // Something else is already up: wait rather than fight over it.
            return candidate.presentedViewController == nil ? candidate : nil
        }

        // MARK: - CNContactPickerDelegate
        //
        // These always arrive on the main thread, and the picker takes itself
        // off screen: the app only has to record that it is gone.

        nonisolated func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let candidate = Self.candidate(from: contact)
            MainActor.assumeIsolated {
                self.isShowing = false
                self.picker = nil
                if let candidate { self.onPicked(candidate) }
                self.onFinish()
            }
        }

        nonisolated func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            MainActor.assumeIsolated {
                self.isShowing = false
                self.picker = nil
                // Nothing picked, nothing changed: the form is exactly as it was.
                self.onFinish()
            }
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
