//
//  ProfileFormView.swift
//  Kudao
//

import SwiftUI
import SwiftData
import PhotosUI

/// Create or edit a celebration profile.
struct ProfileFormView: View {
    let profile: BirthdayProfile?

    @Environment(AppSettings.self) private var settings
    @Environment(NotificationService.self) private var notifications
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var address: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    @State private var relationship: RelationshipKind = .friend
    @State private var favoriteCharacter: String = ""
    @State private var isSurpriseMode: Bool = false
    @State private var photoData: Data?
    @State private var pickerItem: PhotosPickerItem?
    @State private var isLoadingPhoto: Bool = false
    @State private var didSave: Bool = false

    private var strings: Strings { settings.strings }
    private var isEditing: Bool { profile != nil }
    private var canSave: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    /// Life stage of the date currently picked, recomputed as the user scrolls the picker.
    private var ageBracket: AgeBracket {
        let years = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        return AgeBracket.forAge(max(0, years))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                ScrollView {
                    VStack(spacing: 22) {
                        photoPicker

                        FormCard(title: strings.nameLabel, systemImage: "person.text.rectangle") {
                            TextField(strings.namePlaceholder, text: $name)
                                .font(.system(.body, design: .rounded, weight: .medium))
                                .textContentType(.givenName)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.next)

                            Divider().overlay(Palette.hairline)

                            TextField(strings.lastNamePlaceholder, text: $lastName)
                                .font(.system(.body, design: .rounded, weight: .medium))
                                .textContentType(.familyName)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.done)
                        }

                        FormCard(title: strings.birthDateLabel, systemImage: "calendar") {
                            DatePicker(
                                strings.birthDateLabel,
                                selection: $birthDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .tint(Palette.coral)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 7) {
                                Text(strings.ageBracketLabel)
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.secondary)
                                KudaoChip(
                                    title: ageBracket.title(strings),
                                    systemImage: ageBracket.symbolName,
                                    tint: Palette.violet
                                )
                                Spacer(minLength: 0)
                            }
                            .animation(.smooth(duration: 0.25), value: ageBracket)
                        }

                        if ageBracket.wantsFavoriteCharacter {
                            favoriteCharacterCard
                                .transition(.opacity.combined(with: .offset(y: -8)))
                        }

                        FormCard(title: strings.relationshipLabel, systemImage: "person.2.fill") {
                            Menu {
                                Picker(strings.relationshipLabel, selection: $relationship) {
                                    ForEach(RelationshipKind.allCases) { kind in
                                        Label(kind.title(strings), systemImage: kind.symbolName).tag(kind)
                                    }
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: relationship.symbolName)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(relationship.accent)
                                    Text(relationship.title(strings))
                                        .font(.system(.body, design: .rounded, weight: .medium))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                            }
                        }

                        contactCard

                        surpriseToggle

                        Button {
                            save()
                        } label: {
                            Text(isEditing ? strings.saveAction : strings.createAction)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    Capsule().fill(canSave ? AnyShapeStyle(Palette.warmGradient) : AnyShapeStyle(Color.gray.opacity(0.35)))
                                )
                                .shadow(color: canSave ? Palette.coral.opacity(0.35) : .clear, radius: 14, y: 8)
                        }
                        .buttonStyle(PressableCardStyle())
                        .disabled(!canSave)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    .animation(.smooth(duration: 0.3), value: ageBracket.wantsFavoriteCharacter)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(isEditing ? strings.editProfileTitle : strings.newProfileTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(strings.cancelAction) { dismiss() }
                        .font(.system(.body, design: .rounded))
                }
            }
            .sensoryFeedback(.success, trigger: didSave)
            .environment(\.locale, settings.locale)
        }
        .tint(Palette.coral)
        .onAppear(perform: loadExisting)
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            isLoadingPhoto = true
            Task {
                let loaded = try? await newItem.loadTransferable(type: Data.self)
                if let loaded {
                    photoData = ImageDownscaler.compress(loaded) ?? loaded
                }
                isLoadingPhoto = false
            }
        }
    }

    // MARK: - Photo

    private var photoPicker: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                ZStack(alignment: .bottomTrailing) {
                    AvatarView(
                        name: name.isEmpty ? "?" : name,
                        photoData: photoData,
                        size: 116,
                        ringColor: Palette.surface,
                        ringWidth: 4
                    )
                    .overlay {
                        if isLoadingPhoto {
                            Circle().fill(.black.opacity(0.35))
                                .overlay { ProgressView().tint(.white) }
                        }
                    }
                    .clipShape(.circle)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Palette.warmGradient))
                        .overlay(Circle().strokeBorder(Palette.background, lineWidth: 3))
                }
            }
            .buttonStyle(PressableCardStyle())
            .accessibilityLabel(photoData == nil ? strings.addPhoto : strings.changePhoto)

            if photoData != nil {
                Button(role: .destructive) {
                    photoData = nil
                    pickerItem = nil
                } label: {
                    Text(strings.removePhoto)
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                }
            } else {
                Text(strings.addPhoto)
                    .font(.system(.footnote, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Children

    /// Extra hint only children get: a theme for cake and gift ideas.
    private var favoriteCharacterCard: some View {
        FormCard(title: strings.favoriteCharacterLabel, systemImage: "sparkles.tv.fill") {
            TextField(strings.favoriteCharacterPlaceholder, text: $favoriteCharacter)
                .font(.system(.body, design: .rounded, weight: .medium))
                .textInputAutocapitalization(.words)
                .submitLabel(.done)

            Text(strings.favoriteCharacterCaption)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Contacts

    /// Optional contact details; every field is free text and safe to leave empty.
    private var contactCard: some View {
        FormCard(title: strings.contactsSectionTitle, systemImage: "person.crop.rectangle.stack.fill") {
            contactField(
                icon: "house.fill",
                tint: Palette.violet,
                placeholder: strings.addressPlaceholder,
                text: $address,
                contentType: .fullStreetAddress,
                keyboard: .default,
                capitalization: .words
            )

            Divider().overlay(Palette.hairline)

            contactField(
                icon: "phone.fill",
                tint: Palette.teal,
                placeholder: strings.phonePlaceholder,
                text: $phone,
                contentType: .telephoneNumber,
                keyboard: .phonePad,
                capitalization: .never
            )

            Divider().overlay(Palette.hairline)

            contactField(
                icon: "envelope.fill",
                tint: Palette.amber,
                placeholder: strings.emailPlaceholder,
                text: $email,
                contentType: .emailAddress,
                keyboard: .emailAddress,
                capitalization: .never
            )
        }
    }

    private func contactField(
        icon: String,
        tint: Color,
        placeholder: String,
        text: Binding<String>,
        contentType: UITextContentType,
        keyboard: UIKeyboardType,
        capitalization: TextInputAutocapitalization
    ) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 22)

            TextField(placeholder, text: text)
                .font(.system(.body, design: .rounded, weight: .medium))
                .textContentType(contentType)
                .keyboardType(keyboard)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled(keyboard == .emailAddress)
                .submitLabel(.done)
        }
    }

    private var surpriseToggle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isSurpriseMode) {
                HStack(spacing: 8) {
                    Image(systemName: isSurpriseMode ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(isSurpriseMode ? Palette.berry : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                    Text(strings.surpriseTitle)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
            .tint(Palette.berry)

            Text(strings.surpriseDescription)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(isSurpriseMode ? Palette.berry.opacity(0.45) : Palette.hairline, lineWidth: 1)
        )
        .animation(.smooth(duration: 0.25), value: isSurpriseMode)
    }

    // MARK: - Actions

    private func loadExisting() {
        guard let profile else { return }
        guard !didSave, name.isEmpty else { return }
        name = profile.name
        lastName = profile.lastName
        address = profile.address
        phone = profile.contactPhone
        email = profile.contactEmail
        birthDate = profile.birthDate
        relationship = profile.relationship
        favoriteCharacter = profile.favoriteCharacter
        isSurpriseMode = profile.isSurpriseMode
        photoData = profile.photoData
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let saved: BirthdayProfile
        if let profile {
            profile.name = trimmed
            profile.lastName = cleaned(lastName)
            profile.address = cleaned(address)
            profile.contactPhone = cleaned(phone)
            profile.contactEmail = cleaned(email)
            profile.birthDate = birthDate
            profile.relationship = relationship
            profile.favoriteCharacter = ageBracket.wantsFavoriteCharacter ? cleaned(favoriteCharacter) : ""
            profile.isSurpriseMode = isSurpriseMode
            profile.photoData = photoData
            saved = profile
        } else {
            let newProfile = BirthdayProfile(
                name: trimmed,
                birthDate: birthDate,
                relationship: relationship,
                lastName: cleaned(lastName),
                address: cleaned(address),
                contactPhone: cleaned(phone),
                contactEmail: cleaned(email),
                favoriteCharacter: ageBracket.wantsFavoriteCharacter ? cleaned(favoriteCharacter) : "",
                photoData: photoData,
                isSurpriseMode: isSurpriseMode
            )
            modelContext.insert(newProfile)
            saved = newProfile
        }

        try? modelContext.save()
        scheduleReminders(for: saved)

        didSave = true
        dismiss()
    }

    private func cleaned(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Creating or editing a profile (re)plans its local reminders and refreshes the widget.
    private func scheduleReminders(for profile: BirthdayProfile) {
        let strings = self.strings
        let privacy = ReminderPrivacy(hidesSurprisePreviews: settings.hidesSurpriseNotificationPreviews)
        let settings = self.settings
        Task {
            await notifications.sync(profile: profile, strings: strings, privacy: privacy)
            WidgetBridge.publish(profiles: [profile], settings: settings)
        }
    }
}

/// Titled container used by the profile form fields.
private struct FormCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.hairline, lineWidth: 1)
        )
    }
}

#Preview {
    ProfileFormView(profile: nil)
        .environment(AppSettings())
        .environment(NotificationService.shared)
        .modelContainer(KudaoModelContainer.preview())
}
