//
//  ProfileFormView.swift
//  Kudao
//

import SwiftUI
import SwiftData

/// Create or edit a celebration profile.
///
/// Creating one starts with the kind of occasion: everything after that — the
/// fields, the wording, even which questions are worth asking — follows from it.
struct ProfileFormView: View {
    let profile: BirthdayProfile?

    @Environment(AppSettings.self) private var settings
    @Environment(NotificationService.self) private var notifications
    @Environment(KudaoIdentity.self) private var identity
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var hasPickedOccasion: Bool = false
    @State private var occasion: OccasionKind = .birthday
    @State private var isSelfProfile: Bool = false
    @State private var bond: BondKind = .other

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
    @State private var didSave: Bool = false

    private var strings: Strings { settings.strings }
    private var isEditing: Bool { profile != nil }

    /// The occasion step only exists while creating a brand new profile.
    private var isPickingOccasion: Bool { !isEditing && !hasPickedOccasion }

    /// A profile about the user themselves borrows the name from "My profile".
    private var needsNameField: Bool { !isSelfProfile }

    private var resolvedName: String {
        if isSelfProfile {
            return identity.hasName ? identity.trimmedName : strings.selfProfileFallbackName
        }
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool { !resolvedName.isEmpty }

    private var accent: Color { occasion.accent }

    /// Life stage of the date currently picked, recomputed as the user scrolls the picker.
    private var ageBracket: AgeBracket {
        let years = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        return AgeBracket.forAge(max(0, years))
    }

    /// Only a child's birthday gets the themed-character question.
    private var wantsFavoriteCharacter: Bool {
        occasion.wantsAgeBracket && ageBracket.wantsFavoriteCharacter
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackdrop()

                if isPickingOccasion {
                    occasionStep
                        .transition(.opacity.combined(with: .offset(x: -30)))
                } else {
                    detailStep
                        .transition(.opacity.combined(with: .offset(x: 30)))
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isPickingOccasion || isEditing {
                        Button(strings.cancelAction) { dismiss() }
                            .font(.system(.body, design: .rounded))
                    } else {
                        Button {
                            withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
                                hasPickedOccasion = false
                            }
                        } label: {
                            Label(strings.backAction, systemImage: "chevron.left")
                                .font(.system(.body, design: .rounded))
                        }
                    }
                }
            }
            .sensoryFeedback(.success, trigger: didSave)
            .environment(\.locale, settings.locale)
        }
        .tint(accent)
        .onAppear(perform: loadExisting)
    }

    private var navigationTitle: String {
        if isEditing { return strings.editProfileTitle }
        if isPickingOccasion { return strings.newProfileTitle }
        return occasion.title(strings)
    }

    // MARK: - Step 1: what kind of occasion

    private var occasionStep: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 8) {
                    Text(strings.occasionStepTitle)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text(strings.occasionStepSubtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 10)

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                    spacing: 14
                ) {
                    ForEach(Array(OccasionKind.allCases.enumerated()), id: \.element.id) { index, kind in
                        occasionCard(kind, index: index)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    private func occasionCard(_ kind: OccasionKind, index: Int) -> some View {
        Button {
            select(kind)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(kind.gradient)
                        .frame(width: 58, height: 58)
                        .shadow(color: kind.accent.opacity(0.32), radius: 10, y: 5)

                    OccasionGlyph(occasion: kind, size: 26)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(kind.title(strings))
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(kind.caption(strings))
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 176, alignment: .topLeading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(kind.accent.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel("\(kind.title(strings)). \(kind.caption(strings))")
    }

    private func select(_ kind: OccasionKind) {
        occasion = kind
        if !kind.allowsSelfProfile { isSelfProfile = false }
        if !kind.wantsSurpriseMode { isSurpriseMode = false }
        // A wedding or a remembrance is rarely thirty years ago by default.
        if kind != .birthday {
            birthDate = Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date()
        }
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.32)) {
            hasPickedOccasion = true
        }
    }

    // MARK: - Step 2: the details

    private var detailStep: some View {
        ScrollView {
            VStack(spacing: 22) {
                photoPicker

                if occasion.allowsSelfProfile && !isEditing {
                    selfProfileToggle
                }

                if needsNameField {
                    nameCard
                } else {
                    selfNameCard
                }

                dateCard

                if wantsFavoriteCharacter {
                    favoriteCharacterCard
                        .transition(.opacity.combined(with: .offset(y: -8)))
                }

                bondCard

                if occasion.wantsContactDetails {
                    contactCard
                }

                if occasion.wantsSurpriseMode {
                    surpriseToggle
                }

                saveButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .animation(.smooth(duration: 0.3), value: wantsFavoriteCharacter)
            .animation(.smooth(duration: 0.3), value: isSelfProfile)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Text(isEditing ? strings.saveAction : strings.createAction)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule().fill(
                        canSave ? AnyShapeStyle(occasion.gradient) : AnyShapeStyle(Color.gray.opacity(0.35))
                    )
                )
                .shadow(color: canSave ? accent.opacity(0.35) : .clear, radius: 14, y: 8)
        }
        .buttonStyle(PressableCardStyle())
        .disabled(!canSave)
        .padding(.top, 4)
    }

    // MARK: - Photo

    private var photoPicker: some View {
        VStack(spacing: 12) {
            PhotoSourcePicker(
                onPicked: { data in
                    withAnimation(.smooth(duration: 0.25)) { photoData = data }
                },
                onRemoved: photoData == nil ? nil : { photoData = nil }
            ) {
                ZStack(alignment: .bottomTrailing) {
                    AvatarView(
                        name: resolvedName.isEmpty ? "?" : resolvedName,
                        photoData: photoData,
                        size: 116,
                        ringColor: Palette.surface,
                        ringWidth: 4
                    )

                    Image(systemName: "camera.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(occasion.gradient))
                        .overlay(Circle().strokeBorder(Palette.background, lineWidth: 3))
                }
            }
            .buttonStyle(PressableCardStyle())

            Text(photoData == nil ? strings.addPhoto : strings.changePhoto)
                .font(.system(.footnote, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Identity

    private var selfProfileToggle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isSelfProfile) {
                HStack(spacing: 8) {
                    Image(systemName: isSelfProfile ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isSelfProfile ? accent : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                    Text(strings.selfProfileToggleTitle)
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
            .tint(accent)

            Text(strings.selfProfileToggleCaption)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Palette.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(isSelfProfile ? accent.opacity(0.45) : Palette.hairline, lineWidth: 1)
        )
        .animation(.smooth(duration: 0.25), value: isSelfProfile)
    }

    private var nameCard: some View {
        FormCard(title: strings.nameLabel, systemImage: "person.text.rectangle") {
            TextField(namePlaceholder, text: $name)
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
    }

    private var namePlaceholder: String {
        occasion == .remembrance ? strings.rememberedNamePlaceholder : strings.namePlaceholder
    }

    /// When the occasion is the user's own, the name is simply theirs.
    private var selfNameCard: some View {
        FormCard(title: strings.nameLabel, systemImage: "person.crop.circle.fill.badge.checkmark") {
            HStack(spacing: 11) {
                AvatarView(
                    name: identity.hasName ? identity.trimmedName : "?",
                    photoData: identity.photoData,
                    size: 38
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(resolvedName)
                        .font(.system(.body, design: .rounded, weight: .bold))
                    Text(strings.selfProfileNameCaption)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Date

    private var dateCard: some View {
        FormCard(title: occasion.dateLabel(strings), systemImage: "calendar") {
            DatePicker(
                occasion.dateLabel(strings),
                selection: $birthDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .tint(accent)
            .frame(maxWidth: .infinity, alignment: .leading)

            if occasion.wantsAgeBracket {
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
            } else {
                Text(dateHint)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var dateHint: String {
        switch occasion {
        case .wedding: strings.weddingDateHint
        case .remembrance: strings.passingDateHint
        case .other, .birthday: strings.eventDateHint
        }
    }

    // MARK: - Bond or relationship

    @ViewBuilder
    private var bondCard: some View {
        if occasion.usesBond {
            FormCard(title: strings.bondLabel, systemImage: "heart.text.square") {
                Menu {
                    Picker(strings.bondLabel, selection: $bond) {
                        ForEach(BondKind.allCases) { kind in
                            Label(kind.title(strings), systemImage: kind.symbolName).tag(kind)
                        }
                    }
                } label: {
                    pickerLabel(title: bond.title(strings), symbol: bond.symbolName, tint: Palette.sage)
                }

                Text(strings.bondCaption)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            FormCard(title: strings.relationshipLabel, systemImage: "person.2.fill") {
                Menu {
                    Picker(strings.relationshipLabel, selection: $relationship) {
                        ForEach(RelationshipKind.allCases) { kind in
                            Label(kind.title(strings), systemImage: kind.symbolName).tag(kind)
                        }
                    }
                } label: {
                    pickerLabel(
                        title: relationship.title(strings),
                        symbol: relationship.symbolName,
                        tint: relationship.accent
                    )
                }
            }
        }
    }

    private func pickerLabel(title: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
            Text(title)
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
        guard !didSave, name.isEmpty, !hasPickedOccasion else { return }
        occasion = profile.occasion
        isSelfProfile = profile.isSelfProfile
        bond = profile.bond
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
        hasPickedOccasion = true
    }

    private func save() {
        let trimmed = resolvedName
        guard !trimmed.isEmpty else { return }

        let character = wantsFavoriteCharacter ? cleaned(favoriteCharacter) : ""
        let keepsContacts = occasion.wantsContactDetails
        let surprise = occasion.wantsSurpriseMode && isSurpriseMode

        let saved: BirthdayProfile
        if let profile {
            profile.name = trimmed
            profile.lastName = isSelfProfile ? "" : cleaned(lastName)
            profile.address = keepsContacts ? cleaned(address) : ""
            profile.contactPhone = keepsContacts ? cleaned(phone) : ""
            profile.contactEmail = keepsContacts ? cleaned(email) : ""
            profile.birthDate = birthDate
            profile.relationship = relationship
            profile.occasion = occasion
            profile.isSelfProfile = isSelfProfile
            profile.bond = bond
            profile.favoriteCharacter = character
            profile.isSurpriseMode = surprise
            profile.photoData = photoData
            saved = profile
        } else {
            let newProfile = BirthdayProfile(
                name: trimmed,
                birthDate: birthDate,
                relationship: relationship,
                lastName: isSelfProfile ? "" : cleaned(lastName),
                address: keepsContacts ? cleaned(address) : "",
                contactPhone: keepsContacts ? cleaned(phone) : "",
                contactEmail: keepsContacts ? cleaned(email) : "",
                favoriteCharacter: character,
                photoData: photoData,
                isSurpriseMode: surprise,
                occasion: occasion,
                isSelfProfile: isSelfProfile,
                bond: bond
            )
            // A new celebration inherits the reminder preferences from "My profile".
            newProfile.reminderDaysBefore = settings.defaultReminderDaysBefore
            newProfile.giftReminderDaysBefore = settings.defaultGiftReminderDaysBefore
            // Nothing to buy for a remembrance, so the gift nudge starts off.
            newProfile.isGiftReminderEnabled = occasion.wantsSuggestions
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
        .environment(KudaoIdentity.shared)
        .modelContainer(KudaoModelContainer.preview())
}
