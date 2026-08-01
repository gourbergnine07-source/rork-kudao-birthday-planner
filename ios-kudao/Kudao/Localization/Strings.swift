//
//  Strings.swift
//  Kudao
//

import Foundation

/// Every user-facing string, one value set per supported language.
/// Values ending in `Format` are `String(format:)` templates.
nonisolated struct Strings: Sendable {
    let homeTitle: String
    let homeSubtitle: String
    let upNext: String
    let othersSection: String
    let emptyTitle: String
    let emptyMessage: String
    let emptyAction: String

    let searchPlaceholder: String
    let searchClear: String
    let resultsSection: String
    let noResultsTitle: String
    let noResultsMessageFormat: String
    let sortLabel: String
    let sortNearest: String
    let sortAlphabetical: String
    let sortRecentlyAdded: String

    let newProfileTitle: String
    let editProfileTitle: String
    let nameLabel: String
    let namePlaceholder: String
    let photoLabel: String
    let addPhoto: String
    let changePhoto: String
    let removePhoto: String
    let birthDateLabel: String
    let relationshipLabel: String
    let surpriseTitle: String
    let surpriseDescription: String
    let surpriseBadge: String

    let saveAction: String
    let cancelAction: String
    let deleteAction: String
    let createAction: String
    let retryAction: String

    let relFriend: String
    let relFamily: String
    let relPartner: String
    let relColleague: String

    let todayTitle: String
    let tomorrowLabel: String
    let todayLabel: String
    let yesterdayLabel: String
    let dayUnit: String
    let daysUnit: String
    let daysToGo: String
    let turnsFormat: String
    let turnsTodayFormat: String
    let nextBirthdayLabel: String
    let imminentBadge: String
    let imminentDaysFormat: String

    let diaryTab: String
    let preferencesTab: String
    let suggestionsTab: String
    let diaryEmptyTitle: String
    let diaryEmptyMessage: String
    let preferencesEmptyTitle: String
    let preferencesEmptyMessage: String
    let suggestionsEmptyTitle: String
    let suggestionsEmptyMessage: String
    let comingSoon: String

    let diaryComposerPlaceholderFormat: String
    let diarySendNote: String
    let diaryNotesSection: String
    let diaryNotesCountFormat: String
    let deleteNoteAction: String
    let analyzingLabel: String
    let analysisFailedLabel: String
    let giftIdeaBadge: String
    let giftIdeasSection: String
    let tagsSection: String
    let removeTagHint: String
    let removeTagAction: String

    let planTitleFormat: String
    let suggestionsGeneratingTitle: String
    let suggestionsGeneratingMessage: String
    let suggestionsNoTagsTitle: String
    let suggestionsNoTagsMessage: String
    let suggestionsErrorTitle: String
    let generateAction: String
    let regenerateAction: String
    let regenerateAllAction: String
    let giftCardTitle: String
    let cakeCardTitle: String
    let venueCardTitle: String
    let guestsCardTitle: String
    let reasonLabel: String
    let priceBandLabel: String
    let priceLow: String
    let priceMedium: String
    let priceHigh: String
    let confidenceLabel: String
    let confidenceLow: String
    let confidenceMedium: String
    let confidenceHigh: String
    let lowConfidenceBanner: String
    let confirmAllAction: String
    let confirmedAtFormat: String
    let unconfirmedChanges: String
    let editSuggestionTitle: String
    let editedBadge: String
    let guestsUnitFormat: String
    let basedOnTagsFormat: String
    let doneAction: String

    let catFood: String
    let catTravel: String
    let catShopping: String
    let catHobby: String
    let catPlaces: String
    let catOther: String

    let profileSettings: String
    let editData: String
    let deleteProfile: String
    let deleteConfirmTitle: String
    let deleteConfirmMessageFormat: String

    let languageLabel: String
    let profilesCountFormat: String
    let ageNowFormat: String

    let remindersMenuTitle: String
    let remindersSectionTitle: String
    let reminderToggleTitle: String
    let reminderToggleDescription: String
    let reminderDaysTitle: String
    let dayBeforeFormat: String
    let daysBeforeFormat: String
    let giftReminderToggleTitle: String
    let giftReminderDescription: String
    let giftReminderDaysTitle: String
    let reminderScheduledFormat: String
    let reminderDisabledLabel: String
    let notificationsDeniedTitle: String
    let notificationsDeniedMessage: String
    let openSettingsAction: String
    let notificationBirthdayTitle: String
    let notificationBirthdayBodyFormat: String
    let notificationGiftTitle: String
    let notificationGiftBodyFormat: String
    let notificationGiftBodyFallbackFormat: String

    let exportSectionTitle: String
    let exportSectionDescription: String
    let exportPDFAction: String
    let exportJSONAction: String
    let exportPreparing: String
    let exportFailedTitle: String
    let exportFailedMessage: String
    let exportDocumentTitleFormat: String
    let exportGeneratedAtFormat: String
    let exportProfileSection: String
    let exportPlanSection: String
    let exportNotesSection: String
    let exportNoNotes: String
    let exportNoPlan: String

    let reviewBannerTitle: String
    let reviewBannerSubtitleFormat: String
    let planReviewTitle: String
    let planReviewSubtitleFormat: String
    let planReviewTodayFormat: String
    let planReviewNoPlanTitle: String
    let planReviewNoPlanMessage: String
    let confirmAction: String
    let modifyAction: String
    let pendingBadgeLabel: String

    let appSettingsMenu: String
    let settingsTitle: String
    let settingsLanguageSection: String
    let settingsSurpriseSection: String
    let settingsSurpriseFooter: String
    let faceIDToggleTitle: String
    let faceIDToggleDescription: String
    let hidePreviewsToggleTitle: String
    let hidePreviewsToggleDescription: String
    let biometryUnavailableNote: String
    let unlockReasonFormat: String
    let unlockAction: String
    let unlockFailedTitle: String
    let unlockFailedMessage: String
    let lockedBadgeLabel: String
    let notificationGenericTitle: String
    let notificationGenericBody: String
    let maskedProfileName: String
    let settingsWidgetSection: String
    let settingsWidgetHint: String
    let settingsSharingNote: String

    let lastNameLabel: String
    let lastNamePlaceholder: String
    let noLastNameLabel: String
    let addressLabel: String
    let addressPlaceholder: String
    let phoneLabel: String
    let phonePlaceholder: String
    let emailLabel: String
    let emailPlaceholder: String
    let contactsSectionTitle: String
    let birthLabel: String
    let ageLabel: String
    let ageYearsFormat: String
    let notificationActiveLabel: String
    let notificationOffLabel: String
    let daysBeforeShortLabel: String
    let hourShortLabel: String
    let editAction: String

    let sendWishesAction: String
    let messageTab: String
    let messageSectionTitle: String
    let messageGeneratingTitle: String
    let messageGeneratingMessage: String
    let messageEmptyTitle: String
    let messageEmptyMessage: String
    let messageToneLabel: String
    let toneWarm: String
    let toneFunny: String
    let toneElegant: String
    let messageRegenerateAction: String
    let messageCopyAction: String
    let messageCopiedLabel: String
    let messageShareAction: String
    let messageSMSAction: String
    let messageEmailAction: String
    let messageEmailSubjectFormat: String
    let messageBasedOnNote: String

    let buyOnlineAction: String
    let findStoreAction: String
    let noPlanAlertTitle: String
    let noPlanAlertMessage: String
    let giftFromPlanFormat: String

    let storesTitle: String
    let storesSearchingLabel: String
    let storesEmptyTitle: String
    let storesEmptyMessage: String
    let storesPermissionTitle: String
    let storesPermissionMessage: String
    let storesPermissionAction: String
    let storesDeniedTitle: String
    let storesDeniedMessage: String
    let storesFailedTitle: String
    let storesFailedMessage: String
    let storesRadiusNote: String
    let storesSearchingCategoryFormat: String
    let openInMapsAction: String
    let distanceKmFormat: String
    let distanceMetersFormat: String

    let shareProfileAction: String
    let shareProfileTitle: String
    let shareProfileSubtitleFormat: String
    let permissionSectionTitle: String
    let permissionViewTitle: String
    let permissionViewCaption: String
    let permissionEditTitle: String
    let permissionEditCaption: String
    let generateInviteAction: String
    let inviteReadyTitle: String
    let inviteCodeLabel: String
    let inviteHint: String
    let copyCodeAction: String
    let copiedLabel: String
    let shareInviteAction: String
    let newInviteAction: String
    let discardInviteAction: String
    let inviteMessageFormat: String
    let shareBlockedSurpriseTitle: String
    let shareBlockedSurpriseMessage: String
    let yourNameLabel: String
    let yourNamePlaceholder: String
    let yourNameCaption: String

    let participantsTitle: String
    let participantsMenuTitle: String
    let participantsCountFormat: String
    let participantOwnerBadge: String
    let participantYou: String
    let participantUnknown: String
    let participantPendingTitle: String
    let removeParticipantAction: String
    let removeParticipantConfirmFormat: String
    let ownerCannotBeRemoved: String
    let guestLeaveHint: String
    let participantsEmptyTitle: String
    let participantsEmptyMessage: String
    let joinedAtFormat: String

    let joinShareMenuTitle: String
    let joinShareTitle: String
    let joinShareSubtitle: String
    let joinCodePlaceholder: String
    let joinAction: String
    let pasteCodeAction: String
    let joinSuccessFormat: String
    let joinSuccessCaption: String
    let sharedProfileFallbackName: String

    let shareErrorGeneric: String
    let shareErrorInvalidCode: String
    let shareErrorCodeUsed: String
    let shareErrorOwnProfile: String
    let shareErrorNoAccess: String
    let shareErrorReadOnly: String
    let shareErrorNotOwner: String
    let shareErrorOffline: String

    let sharedBadge: String
    let sharedByFormat: String
    let readOnlyBadge: String
    let readOnlyDiaryMessage: String
    let readOnlyPlanMessage: String
    let voteUpLabel: String
    let voteDownLabel: String
    let voteTallyFormat: String
    let votesEmptyLabel: String
    let syncingLabel: String
    let collaborationSectionTitle: String
    let collaborationHubTitle: String
    let collaborationHubCountFormat: String
    let collaborationInviteTitle: String
    let collaborationInviteMessage: String
    let inviteSomeoneAction: String
    let pendingInvitesCountFormat: String
    let collaborationOnlyYou: String

    let ageBracketLabel: String
    let ageBracketChild: String
    let ageBracketTeen: String
    let ageBracketAdult: String
    let ageBracketSenior: String
    let favoriteCharacterLabel: String
    let favoriteCharacterPlaceholder: String
    let favoriteCharacterCaption: String

    let messageGenerateAction: String
    let messageWriteMyselfAction: String
    let messagePlaceholder: String
    let messageEditorHint: String
    let messageSentBadge: String
    let messageScheduleTitle: String
    let messageScheduleToggle: String
    let messageSendDateLabel: String
    let messageScheduleReadyFormat: String
    let messagePastDateLabel: String
    let messageAlreadySentLabel: String
    let messageMarkSentShortAction: String
    let messageMarkSentAction: String
    let messageMarkUnsentAction: String
    let messageNotYetAction: String
    let messageSentConfirmTitle: String
    let messageSentConfirmMessage: String
    let messageContactTitle: String
    let messageContactCaption: String
    let messageNoContactLabel: String
    let messageNeedsPhoneHint: String
    let messageWhatsAppAction: String
    let messageMessagesAction: String
    let messageOpenFailedTitle: String
    let messageOpenFailedMessage: String
    let notificationMessageTitle: String
    let notificationMessageBodyFormat: String

    let messageAutoRefreshToggle: String
    let messageAutoRefreshCaption: String
    let messageAutoRefreshPausedLabel: String
    let messageAutoRefreshResumeAction: String
    let messageAutoRefreshedFormat: String

    let galleryTab: String
    let gallerySectionTitle: String
    let galleryCountFormat: String
    let galleryAddAction: String
    let galleryFromLibraryAction: String
    let galleryCaptureAction: String
    let galleryEmptyTitle: String
    let galleryEmptyMessage: String
    let galleryLockedTitle: String
    let galleryLockedMessageFormat: String
    let galleryUploadingTitle: String
    let galleryUploadingCountFormat: String
    let galleryDeleteAction: String
    let galleryDeleteConfirmTitle: String
    let galleryDeleteConfirmMessage: String
    let galleryPrivacyNote: String
    let galleryLoadingLabel: String
    let galleryMediaUnavailable: String
    let galleryTooLargeMessage: String
    let galleryPrepareFailedMessage: String
    let galleryRetryUnavailable: String
    let cloudSectionTitle: String
    let cloudSectionCaption: String
    let cloudManageTitle: String
    let cloudOnLabel: String
    let cloudOffLabel: String
    let cloudOffCaption: String
    let cloudNeverSynced: String
    let cloudLastSyncFormat: String
    let cloudEnableTitle: String
    let cloudEnableCaption: String
    let cloudEnableAction: String
    let cloudCodeLabel: String
    let cloudCodeCaption: String
    let cloudCopyAction: String
    let cloudCopiedLabel: String
    let cloudActionsTitle: String
    let cloudSyncNowAction: String
    let cloudDisableAction: String
    let cloudDeleteRemoteAction: String
    let cloudDisableTitle: String
    let cloudDisableMessage: String
    let cloudRestoreTitle: String
    let cloudRestoreHint: String
    let cloudRestorePlaceholder: String
    let cloudRestoreAction: String
    let cloudRestoredFormat: String
    let cloudBackedUpBanner: String
    let cloudPrivacyNote: String
    let cloudUnavailableMessage: String
    let cloudInvalidCodeMessage: String
    let cloudUnknownCodeMessage: String
    let cloudGenericErrorMessage: String
    let gallerySortLabel: String
    let gallerySortNewest: String
    let gallerySortOldest: String
    let myProfileTitle: String
    let myProfileSubtitle: String
    let notificationDefaultsTitle: String
    let notificationDefaultsCaption: String
    let defaultReminderDaysLabel: String
    let defaultGiftDaysLabel: String
    let defaultReminderTimeLabel: String
    let defaultsAppliedNote: String
    let privacySectionTitle: String
    let privacyMovedCaption: String
    let accountSectionTitle: String
    let accountNoLoginTitle: String
    let accountNoLoginCaption: String
    let accountVaultCaption: String
    let accountSignOutAction: String
    let accountSignOutTitle: String
    let accountSignOutMessage: String
    let appInfoTitle: String
    let appVersionLabel: String
    let appSupportAction: String
    let appSupportCaption: String
    let galleryPreparingTitle: String
    let galleryUploadAction: String
    let galleryCaptionSheetTitle: String
    let galleryCaptionSheetMessage: String
    let galleryCaptionPlaceholder: String
    let galleryCaptionAddAction: String
    let galleryCaptionEditAction: String
    let galleryCaptionEditorTitle: String
    let photoSourceCameraAction: String
    let photoSourceLibraryAction: String
    let photoCropTitle: String
    let photoCropHint: String
    let photoUseAction: String
    let cameraDeniedTitle: String
    let cameraDeniedMessage: String
    let libraryDeniedTitle: String
    let libraryDeniedMessage: String
    let notificationGalleryTitle: String
    let notificationGalleryBodyFormat: String

    // MARK: Occasions

    let occasionBirthday: String
    let occasionWedding: String
    let occasionRemembrance: String
    let occasionOther: String
    let occasionBirthdayCaption: String
    let occasionWeddingCaption: String
    let occasionRemembranceCaption: String
    let occasionOtherCaption: String
    let occasionBirthdayPlural: String
    let occasionWeddingPlural: String
    let occasionRemembrancePlural: String
    let occasionOtherPlural: String
    let occasionStepTitle: String
    let occasionStepSubtitle: String
    let weddingDateLabel: String
    let passingDateLabel: String
    let eventDateLabel: String
    let weddingDateHint: String
    let passingDateHint: String
    let eventDateHint: String
    let weddingStatLabel: String
    let passingStatLabel: String
    let eventStatLabel: String
    let yearsTogetherLabel: String
    let yearsSinceLabel: String
    let yearsElapsedLabel: String
    let daysToAnniversary: String
    let daysToRemembrance: String
    let daysToEvent: String
    let todayAnniversaryTitle: String
    let todayRemembranceTitle: String
    let todayEventTitle: String
    let anniversaryYearsFormat: String
    let yearsAgoFormat: String
    let editionYearsFormat: String
    let sendAnniversaryWishesAction: String
    let writeThoughtAction: String
    let sendEventWishesAction: String
    let memoriesTab: String
    let thoughtTab: String
    let traitsTab: String
    let reminderOnTheDayLabel: String
    let rememberedNamePlaceholder: String
    let bondLabel: String
    let bondCaption: String
    let bondParent: String
    let bondGrandparent: String
    let bondSibling: String
    let bondSpouse: String
    let bondChild: String
    let bondFriend: String
    let bondOther: String
    let selfProfileToggleTitle: String
    let selfProfileToggleCaption: String
    let selfProfileNameCaption: String
    let selfProfileFallbackName: String
    let backAction: String
    let filterAllOccasions: String
    let filterEmptyTitle: String
    let filterEmptyMessageFormat: String
    let anniversaryGiftCardTitle: String
    let experienceCardTitle: String
    let anniversaryVenueCardTitle: String
    let toneIntimate: String
    let toneSober: String
    let notificationAnniversaryTitle: String
    let notificationAnniversaryBodyFormat: String
    let notificationRemembranceTitle: String
    let notificationRemembranceBodyFormat: String
    let notificationEventTitle: String
    let notificationEventBodyFormat: String

    // MARK: Email account

    let accountSignInTitle: String
    let accountSignInCaption: String
    let accountSignedInCaption: String
    let authSignInTab: String
    let authSignUpTab: String
    let authSignInTitle: String
    let authSignInSubtitle: String
    let authSignUpTitle: String
    let authSignUpSubtitle: String
    let authEmailPlaceholder: String
    let authPasswordPlaceholder: String
    let authPasswordHintFormat: String
    let authSignInAction: String
    let authSignUpAction: String
    let authForgotPasswordAction: String
    let authResetSentMessage: String
    let authOptionalNote: String
    let authConfirmTitle: String
    let authConfirmMessageFormat: String
    let authResendAction: String
    let authSignedInBadge: String
    let authVaultLinkedTitle: String
    let authVaultLinkedCaption: String
    let authVaultMissingTitle: String
    let authVaultMissingCaption: String
    let authRestoredFormat: String
    let authSignOutAction: String
    let authSignOutNote: String
    let authUnavailableMessage: String
    let authInvalidEmailMessage: String
    let authMissingPasswordMessage: String
    let authWeakPasswordFormat: String
    let authWrongCredentialsMessage: String
    let authNotConfirmedMessage: String
    let authEmailTakenMessage: String
    let authRateLimitMessage: String
    let authOfflineMessage: String
    let authGenericErrorMessage: String

    let notificationSettingsMenuTitle: String
    let notificationSettingsCaption: String
    let notificationsActiveLabel: String
    let enableNotificationsAction: String
    let mainReminderLabel: String
    let applyToExistingFormat: String
    let appliedToExistingLabel: String
    let resetToShippedAction: String
    let noProfilesInCategoryLabel: String

    // MARK: Gallery timeline

    let galleryAutoOrderNote: String

    // MARK: Diary reminders

    let diaryReminderSectionTitle: String
    let diaryReminderToggleTitle: String
    let diaryReminderCaption: String
    let diaryFrequencyLabel: String
    let diaryCadenceDaily: String
    let diaryCadenceEveryThreeDays: String
    let diaryCadenceWeekly: String
    let diaryCadenceNever: String
    let diaryReminderTimeLabel: String
    let diaryReminderNextFormat: String
    let diaryReminderPeopleFormat: String
    let diaryReminderRemembranceNote: String
    let diaryReminderExcludeTitle: String
    let diaryReminderExcludeCaption: String
    let diaryReminderOffNote: String
    let diaryNudgeTitle: String
    let diaryNudgeVariantOne: String
    let diaryNudgeVariantTwo: String
    let diaryNudgeVariantThree: String
    let diaryNudgePersonFormatOne: String
    let diaryNudgePersonFormatTwo: String
    let diaryNudgePairFormat: String
    let quickNoteTitle: String
    let quickNoteCaption: String
    let quickNoteEmptyMessage: String
    let quickNoteSaveAction: String

    // MARK: Home grid

    let gridCategoriesTitle: String
    let gridNextEventTitle: String
    let gridNextEventEmpty: String
    let gridPendingCountFormat: String
    let gridPendingEmpty: String
    let gridProfileCountFormat: String
    let gridProfileCountOne: String
    let gridCategoryEmptyHint: String
    let gridAnniversaryInFormat: String
    let gridSharedCountFormat: String
    let sharedListTitle: String
    let pendingScopeEmptyMessage: String
    let sharedScopeEmptyMessage: String

    // MARK: Amazon affiliation

    let buyOnAmazonAction: String
    let affiliateSectionTitle: String
    let affiliateCaption: String
    let affiliateTagLabel: String
    let affiliateActiveBadge: String
    let affiliateFallbackNote: String
    let affiliateDisclosure: String
    let linkPreviewTitle: String
    let linkPreviewBadgeLabel: String
    let linkPreviewStoreLabel: String
    let linkPreviewQueryLabel: String
    let linkPreviewNoTag: String
    let linkPreviewNoTagHint: String
    let linkPreviewUrlLabel: String
    let linkPreviewOpenAction: String
    let linkPreviewCopyAction: String
    let linkPreviewCopiedLabel: String
    let linkPreviewGoogleAction: String

    // MARK: Library of past events

    let libraryTitle: String
    let libraryEmptyTitle: String
    let libraryEmptyMessage: String
    let libraryProfileEmptyMessage: String
    let libraryFilterEmptyMessage: String
    let libraryAllProfiles: String
    let libraryCountFormat: String
    let libraryYearsCountFormat: String
    let libraryPlanSection: String
    let libraryNoPlanLabel: String
    let librarySentBadge: String
    let libraryNotSentBadge: String
    let libraryMemoriesSection: String
    let libraryMediaSection: String
    let libraryMediaCountFormat: String
    let libraryNotesCountFormat: String
    let libraryKeywordsSection: String
    let libraryArchivedOnFormat: String
}

extension Strings {
    static let italian = Strings(
        homeTitle: "Festeggiati",
        homeSubtitle: "Annota tutto l'anno, festeggia alla perfezione.",
        upNext: "Il prossimo",
        othersSection: "In arrivo",
        emptyTitle: "Nessun festeggiato",
        emptyMessage: "Aggiungi le persone a cui tieni e inizia a raccogliere idee per il loro compleanno.",
        emptyAction: "Crea il primo profilo",
        searchPlaceholder: "Cerca un nome",
        searchClear: "Cancella la ricerca",
        resultsSection: "Risultati",
        noResultsTitle: "Nessun risultato",
        noResultsMessageFormat: "Nessun profilo corrisponde a «%@».",
        sortLabel: "Ordina",
        sortNearest: "Compleanno più vicino",
        sortAlphabetical: "Nome (A-Z)",
        sortRecentlyAdded: "Aggiunti di recente",
        newProfileTitle: "Nuovo profilo",
        editProfileTitle: "Modifica profilo",
        nameLabel: "Nome",
        namePlaceholder: "Come si chiama?",
        photoLabel: "Foto",
        addPhoto: "Aggiungi foto",
        changePhoto: "Cambia foto",
        removePhoto: "Rimuovi foto",
        birthDateLabel: "Data di nascita",
        relationshipLabel: "Relazione",
        surpriseTitle: "Modalità sorpresa",
        surpriseDescription: "Il profilo resta nascosto: non sarà visibile né condivisibile con il festeggiato.",
        surpriseBadge: "Sorpresa",
        saveAction: "Salva",
        cancelAction: "Annulla",
        deleteAction: "Elimina",
        createAction: "Crea profilo",
        retryAction: "Riprova",
        relFriend: "Amico",
        relFamily: "Famiglia",
        relPartner: "Partner",
        relColleague: "Collega",
        todayTitle: "È oggi!",
        tomorrowLabel: "Domani",
        todayLabel: "Oggi",
        yesterdayLabel: "Ieri",
        dayUnit: "giorno",
        daysUnit: "giorni",
        daysToGo: "al compleanno",
        turnsFormat: "Compie %d anni",
        turnsTodayFormat: "Compie %d anni oggi",
        nextBirthdayLabel: "Prossimo compleanno",
        imminentBadge: "Questa settimana",
        imminentDaysFormat: "Tra %d giorni",
        diaryTab: "Diario",
        preferencesTab: "Preferenze",
        suggestionsTab: "Suggerimenti",
        diaryEmptyTitle: "Diario vuoto",
        diaryEmptyMessage: "Scrivi la prima nota: gusti, desideri e dettagli che noti durante l'anno.",
        preferencesEmptyTitle: "Ancora nessuna preferenza",
        preferencesEmptyMessage: "Le parole chiave vengono estratte automaticamente dalle note del diario.",
        suggestionsEmptyTitle: "Ancora nessun suggerimento",
        suggestionsEmptyMessage: "Regalo, torta, locale e numero di invitati appariranno qui in base al diario.",
        comingSoon: "Presto disponibile",
        diaryComposerPlaceholderFormat: "Cosa hai notato oggi su %@?",
        diarySendNote: "Salva nota",
        diaryNotesSection: "Note",
        diaryNotesCountFormat: "%d note",
        deleteNoteAction: "Elimina nota",
        analyzingLabel: "Analisi in corso…",
        analysisFailedLabel: "Parole chiave non estratte",
        giftIdeaBadge: "Idea regalo",
        giftIdeasSection: "Spunti regalo",
        tagsSection: "Parole chiave",
        removeTagHint: "Tocca la × per rimuovere una parola chiave sbagliata.",
        removeTagAction: "Rimuovi parola chiave",
        planTitleFormat: "Piano festa per %@",
        suggestionsGeneratingTitle: "Sto pensando…",
        suggestionsGeneratingMessage: "Leggo le preferenze raccolte e preparo il piano.",
        suggestionsNoTagsTitle: "Serve almeno una nota",
        suggestionsNoTagsMessage: "Scrivi qualche nota nel diario: i suggerimenti nascono dalle preferenze estratte.",
        suggestionsErrorTitle: "Suggerimenti non disponibili",
        generateAction: "Genera suggerimenti",
        regenerateAction: "Rigenera",
        regenerateAllAction: "Rigenera tutto",
        giftCardTitle: "Regalo",
        cakeCardTitle: "Torta",
        venueCardTitle: "Locale",
        guestsCardTitle: "Invitati",
        reasonLabel: "Perché",
        priceBandLabel: "Fascia di prezzo",
        priceLow: "Fascia bassa",
        priceMedium: "Fascia media",
        priceHigh: "Fascia alta",
        confidenceLabel: "Confidenza",
        confidenceLow: "bassa",
        confidenceMedium: "media",
        confidenceHigh: "alta",
        lowConfidenceBanner: "Scrivi più note nel diario per suggerimenti più precisi.",
        confirmAllAction: "Conferma tutto",
        confirmedAtFormat: "Piano confermato il %@",
        unconfirmedChanges: "Modifiche da confermare",
        editSuggestionTitle: "Modifica suggerimento",
        editedBadge: "Modificato",
        guestsUnitFormat: "%d persone",
        basedOnTagsFormat: "Basato su %d parole chiave",
        doneAction: "Fine",
        catFood: "Cibo",
        catTravel: "Viaggi",
        catShopping: "Shopping",
        catHobby: "Hobby",
        catPlaces: "Luoghi",
        catOther: "Altro",
        profileSettings: "Impostazioni profilo",
        editData: "Modifica dati",
        deleteProfile: "Elimina profilo",
        deleteConfirmTitle: "Eliminare il profilo?",
        deleteConfirmMessageFormat: "Il profilo di %@ e tutte le note del diario verranno eliminati.",
        languageLabel: "Lingua",
        profilesCountFormat: "%d profili",
        ageNowFormat: "%d anni",
        remindersMenuTitle: "Promemoria e notifiche",
        remindersSectionTitle: "Promemoria",
        reminderToggleTitle: "Promemoria compleanno",
        reminderToggleDescription: "Un avviso locale quando il compleanno si avvicina, con i suggerimenti pronti.",
        reminderDaysTitle: "Ricordami",
        dayBeforeFormat: "%d giorno prima",
        daysBeforeFormat: "%d giorni prima",
        giftReminderToggleTitle: "Notifica promemoria regalo separata",
        giftReminderDescription: "Un avviso in più, prima del promemoria compleanno, per comprare il regalo in tempo.",
        giftReminderDaysTitle: "Promemoria regalo",
        reminderScheduledFormat: "Prossimo avviso: %@",
        reminderDisabledLabel: "Nessun promemoria pianificato",
        notificationsDeniedTitle: "Notifiche disattivate",
        notificationsDeniedMessage: "Attiva le notifiche di Kudao nelle impostazioni di iOS per ricevere i promemoria.",
        openSettingsAction: "Apri Impostazioni",
        notificationBirthdayTitle: "Compleanno in arrivo",
        notificationBirthdayBodyFormat: "Il compleanno di %@ si avvicina! Controlla i suggerimenti su Kudao",
        notificationGiftTitle: "Promemoria regalo",
        notificationGiftBodyFormat: "Non dimenticare il regalo per %@: %@",
        notificationGiftBodyFallbackFormat: "Non dimenticare il regalo per %@. Apri Kudao per scegliere un'idea.",
        exportSectionTitle: "Esporta diario",
        exportSectionDescription: "Salva note e parole chiave di questo profilo in un file da condividere o archiviare.",
        exportPDFAction: "Esporta in PDF",
        exportJSONAction: "Esporta in JSON",
        exportPreparing: "Preparo il file…",
        exportFailedTitle: "Esportazione non riuscita",
        exportFailedMessage: "Non è stato possibile creare il file. Riprova.",
        exportDocumentTitleFormat: "Diario di %@",
        exportGeneratedAtFormat: "Esportato il %@",
        exportProfileSection: "Profilo",
        exportPlanSection: "Piano festa",
        exportNotesSection: "Note del diario",
        exportNoNotes: "Nessuna nota nel diario.",
        exportNoPlan: "Nessun piano festa salvato.",
        reviewBannerTitle: "Da confermare",
        reviewBannerSubtitleFormat: "%d piani festa aspettano il tuo ok",
        planReviewTitle: "Tutto pronto?",
        planReviewSubtitleFormat: "Il compleanno di %@ è tra %d giorni. Conferma il piano o modificalo.",
        planReviewTodayFormat: "Oggi è il compleanno di %@. Conferma il piano o modificalo.",
        planReviewNoPlanTitle: "Nessun piano ancora",
        planReviewNoPlanMessage: "Apri i suggerimenti per creare il piano festa di questo profilo.",
        confirmAction: "Conferma",
        modifyAction: "Modifica",
        pendingBadgeLabel: "Piano da confermare",
        appSettingsMenu: "Impostazioni app",
        settingsTitle: "Impostazioni",
        settingsLanguageSection: "Lingua",
        settingsSurpriseSection: "Modalità sorpresa",
        settingsSurpriseFooter: "Queste protezioni valgono per tutti i profili con la modalità sorpresa attiva.",
        faceIDToggleTitle: "Proteggi profili sorpresa con Face ID",
        faceIDToggleDescription: "Chiede Face ID, Touch ID o il codice del dispositivo prima di aprire un profilo sorpresa.",
        hidePreviewsToggleTitle: "Nascondi anteprima notifiche per profili sorpresa",
        hidePreviewsToggleDescription: "Le notifiche mostrano solo “Promemoria Kudao”, senza il nome della persona.",
        biometryUnavailableNote: "Nessuna biometria configurata: verrà chiesto il codice del dispositivo.",
        unlockReasonFormat: "Sblocca il profilo di %@",
        unlockAction: "Sblocca",
        unlockFailedTitle: "Sblocco non riuscito",
        unlockFailedMessage: "Non è stato possibile verificare la tua identità. Riprova.",
        lockedBadgeLabel: "Profilo protetto",
        notificationGenericTitle: "Promemoria Kudao",
        notificationGenericBody: "Apri Kudao per vedere il promemoria.",
        maskedProfileName: "Sorpresa",
        settingsWidgetSection: "Widget",
        settingsWidgetHint: "Tieni premuto sulla schermata Home, tocca Modifica, poi Aggiungi widget e scegli Kudao per il conto alla rovescia.",
        settingsSharingNote: "I profili sorpresa resteranno esclusi da qualsiasi condivisione con il festeggiato.",
        lastNameLabel: "Cognome",
        lastNamePlaceholder: "Cognome (opzionale)",
        noLastNameLabel: "Cognome non indicato",
        addressLabel: "Indirizzo",
        addressPlaceholder: "Via, citt\u{00E0} (opzionale)",
        phoneLabel: "Telefono",
        phonePlaceholder: "Numero di telefono (opzionale)",
        emailLabel: "Email",
        emailPlaceholder: "Indirizzo email (opzionale)",
        contactsSectionTitle: "Contatti",
        birthLabel: "Nascita",
        ageLabel: "Et\u{00E0}",
        ageYearsFormat: "%d anni",
        notificationActiveLabel: "Notifica attiva",
        notificationOffLabel: "Notifica disattivata",
        daysBeforeShortLabel: "giorni prima:",
        hourShortLabel: "ora:",
        editAction: "Modifica",
        sendWishesAction: "Invia auguri",
        messageTab: "Messaggio",
        messageSectionTitle: "Messaggio di auguri",
        messageGeneratingTitle: "Scrivo gli auguri\u{2026}",
        messageGeneratingMessage: "Uso le note del diario per un messaggio davvero personale.",
        messageEmptyTitle: "Nessun messaggio",
        messageEmptyMessage: "Genera un messaggio di auguri personalizzato dalle parole chiave raccolte nel diario.",
        messageToneLabel: "Tono",
        toneWarm: "Affettuoso",
        toneFunny: "Spiritoso",
        toneElegant: "Elegante",
        messageRegenerateAction: "Rigenera",
        messageCopyAction: "Copia",
        messageCopiedLabel: "Copiato",
        messageShareAction: "Condividi",
        messageSMSAction: "Messaggi",
        messageEmailAction: "Email",
        messageEmailSubjectFormat: "Buon compleanno %@!",
        messageBasedOnNote: "Scritto dalle parole chiave del diario",
        buyOnlineAction: "Acquista online",
        findStoreAction: "Trova un negozio vicino a te",
        noPlanAlertTitle: "Nessuna idea regalo",
        noPlanAlertMessage: "Genera prima i suggerimenti nella tab Suggerimenti.",
        giftFromPlanFormat: "Idea regalo: %@",
        storesTitle: "Negozi vicini",
        storesSearchingLabel: "Cerco negozi\u{2026}",
        storesEmptyTitle: "Nessun negozio trovato",
        storesEmptyMessage: "Non ci sono negozi di questo tipo entro 5 km da te.",
        storesPermissionTitle: "Serve la posizione",
        storesPermissionMessage: "Kudao usa la tua posizione solo per cercare negozi vicini.",
        storesPermissionAction: "Consenti la posizione",
        storesDeniedTitle: "Posizione non disponibile",
        storesDeniedMessage: "Attiva i servizi di localizzazione per Kudao nelle Impostazioni.",
        storesFailedTitle: "Ricerca non riuscita",
        storesFailedMessage: "Non riesco a cercare i negozi adesso. Riprova tra poco.",
        storesRadiusNote: "Entro 5 km da te",
        storesSearchingCategoryFormat: "Cerco: %@",
        openInMapsAction: "Apri in Mappe",
        distanceKmFormat: "%.1f km",
        distanceMetersFormat: "%d m",
        shareProfileAction: "Condividi profilo",
        shareProfileTitle: "Condividi profilo",
        shareProfileSubtitleFormat: "Invita qualcuno a organizzare il compleanno di %@ con te.",
        permissionSectionTitle: "Cosa pu\u{00F2} fare",
        permissionViewTitle: "Sola lettura",
        permissionViewCaption: "Vede profilo, diario e suggerimenti senza modificarli.",
        permissionEditTitle: "Pu\u{00F2} collaborare",
        permissionEditCaption: "Aggiunge note nel diario e vota i suggerimenti.",
        generateInviteAction: "Genera codice invito",
        inviteReadyTitle: "Invito pronto",
        inviteCodeLabel: "Codice invito",
        inviteHint: "Chi lo riceve apre Kudao, tocca l'icona impostazioni e scegli \u{00AB}Unisciti a un profilo\u{00BB}.",
        copyCodeAction: "Copia codice",
        copiedLabel: "Copiato",
        shareInviteAction: "Condividi invito",
        newInviteAction: "Genera un altro codice",
        discardInviteAction: "Annulla invito",
        inviteMessageFormat: "Organizziamo insieme il compleanno di %@ su Kudao! Apri l'app, vai su Impostazioni \u{2192} Unisciti a un profilo e inserisci il codice: %@",
        shareBlockedSurpriseTitle: "Profilo sorpresa protetto",
        shareBlockedSurpriseMessage: "Disattiva la protezione sorpresa nelle impostazioni per poter condividere questo profilo.",
        yourNameLabel: "Il tuo nome",
        yourNamePlaceholder: "Come ti chiami",
        yourNameCaption: "Serve agli altri partecipanti per riconoscere le tue note.",
        participantsTitle: "Partecipanti",
        participantsMenuTitle: "Partecipanti",
        participantsCountFormat: "%d partecipanti",
        participantOwnerBadge: "Proprietario",
        participantYou: "Tu",
        participantUnknown: "Partecipante",
        participantPendingTitle: "Inviti in attesa",
        removeParticipantAction: "Rimuovi",
        removeParticipantConfirmFormat: "%@ perder\u{00E0} l'accesso a questo profilo. Le note gi\u{00E0} scritte restano nel diario.",
        ownerCannotBeRemoved: "Il proprietario non pu\u{00F2} essere rimosso: per chiudere la condivisione elimina il profilo.",
        guestLeaveHint: "Solo il proprietario del profilo pu\u{00F2} gestire gli accessi.",
        participantsEmptyTitle: "Nessun partecipante",
        participantsEmptyMessage: "Condividi il profilo per organizzare la festa insieme a qualcun altro.",
        joinedAtFormat: "Dal %@",
        joinShareMenuTitle: "Unisciti a un profilo",
        joinShareTitle: "Unisciti a un profilo",
        joinShareSubtitle: "Inserisci il codice invito che hai ricevuto.",
        joinCodePlaceholder: "CODICE",
        joinAction: "Unisciti",
        pasteCodeAction: "Incolla dagli appunti",
        joinSuccessFormat: "Ora collabori al compleanno di %@",
        joinSuccessCaption: "Trovi il profilo nella tua lista, con le note e i suggerimenti condivisi.",
        sharedProfileFallbackName: "Profilo condiviso",
        shareErrorGeneric: "Qualcosa \u{00E8} andato storto. Riprova.",
        shareErrorInvalidCode: "Codice non valido. Controlla e riprova.",
        shareErrorCodeUsed: "Questo codice \u{00E8} gi\u{00E0} stato usato da un'altra persona.",
        shareErrorOwnProfile: "Questo profilo \u{00E8} gi\u{00E0} tuo.",
        shareErrorNoAccess: "Non hai pi\u{00F9} accesso a questo profilo condiviso.",
        shareErrorReadOnly: "Hai accesso in sola lettura a questo profilo.",
        shareErrorNotOwner: "Solo il proprietario del profilo pu\u{00F2} farlo.",
        shareErrorOffline: "Nessuna connessione. Riprova quando torni online.",
        sharedBadge: "Condiviso",
        sharedByFormat: "Condiviso da %@",
        readOnlyBadge: "Sola lettura",
        readOnlyDiaryMessage: "Hai accesso in sola lettura: puoi leggere le note ma non aggiungerne.",
        readOnlyPlanMessage: "Il piano \u{00E8} gestito dal proprietario del profilo.",
        voteUpLabel: "Mi piace",
        voteDownLabel: "Non mi convince",
        voteTallyFormat: "%1$d a favore \u{00B7} %2$d contro",
        votesEmptyLabel: "Ancora nessun voto",
        syncingLabel: "Aggiornamento\u{2026}",
        collaborationSectionTitle: "Condivisione",
        collaborationHubTitle: "Insieme ad altri",
        collaborationHubCountFormat: "%d profili condivisi",
        collaborationInviteTitle: "Organizza in gruppo",
        collaborationInviteMessage: "Invita chi vuoi in un profilo, o unisciti con un codice.",
        inviteSomeoneAction: "Invita qualcuno",
        pendingInvitesCountFormat: "%d inviti in attesa",
        collaborationOnlyYou: "Solo tu, per ora",
        ageBracketLabel: "Fascia d\u{2019}et\u{00E0}",
        ageBracketChild: "Bambino",
        ageBracketTeen: "Adolescente",
        ageBracketAdult: "Adulto",
        ageBracketSenior: "Anziano",
        favoriteCharacterLabel: "Cartone o personaggio preferito",
        favoriteCharacterPlaceholder: "Es. Bluey, Spider-Man, Frozen",
        favoriteCharacterCaption: "Facoltativo: aiuta a scegliere torta e regalo a tema.",
        messageGenerateAction: "Genera messaggio",
        messageWriteMyselfAction: "Scrivilo tu",
        messagePlaceholder: "Scrivi qui i tuoi auguri\u{2026}",
        messageEditorHint: "Modifica il testo come vuoi: lo inviamo esattamente cos\u{00EC}.",
        messageSentBadge: "Inviato",
        messageScheduleTitle: "Programmazione invio",
        messageScheduleToggle: "Ricordami di inviarlo",
        messageSendDateLabel: "Invia il",
        messageScheduleReadyFormat: "Ti avvisiamo il %@",
        messagePastDateLabel: "Scegli una data futura per ricevere il promemoria.",
        messageAlreadySentLabel: "Messaggio gi\u{00E0} inviato.",
        messageMarkSentShortAction: "Segna come inviato",
        messageMarkSentAction: "S\u{00EC}, l\u{2019}ho inviato",
        messageMarkUnsentAction: "Segna come da inviare",
        messageNotYetAction: "Non ancora",
        messageSentConfirmTitle: "Hai inviato gli auguri?",
        messageSentConfirmMessage: "Se confermi, non ti ricorderemo pi\u{00F9} di inviare questo messaggio.",
        messageContactTitle: "Contatto destinatario",
        messageContactCaption: "Serve per aprire WhatsApp o Messaggi con il testo gi\u{00E0} pronto.",
        messageNoContactLabel: "Nessun contatto salvato",
        messageNeedsPhoneHint: "Aggiungi un numero per aprire la chat gi\u{00E0} compilata.",
        messageWhatsAppAction: "Apri WhatsApp",
        messageMessagesAction: "Apri Messaggi",
        messageOpenFailedTitle: "App non disponibile",
        messageOpenFailedMessage: "Non riusciamo ad aprire l\u{2019}app su questo dispositivo. Il testo \u{00E8} stato copiato negli appunti.",
        notificationMessageTitle: "Auguri da inviare",
        notificationMessageBodyFormat: "\u{00C8} il momento di augurare buon compleanno a %@!",
        messageAutoRefreshToggle: "Aggiorna con le nuove note",
        messageAutoRefreshCaption: "Quando aggiungi note o parole chiave al diario, riscriviamo la bozza degli auguri.",
        messageAutoRefreshPausedLabel: "Hai modificato il testo a mano: l\u{2019}aggiornamento automatico \u{00E8} in pausa.",
        messageAutoRefreshResumeAction: "Riprendi",
        messageAutoRefreshedFormat: "Aggiornato con le tue ultime note \u{00B7} %@",
        galleryTab: "Galleria",
        gallerySectionTitle: "Ricordi della festa",
        galleryCountFormat: "%d ricordi",
        galleryAddAction: "Aggiungi ricordi",
        galleryFromLibraryAction: "Scegli dalla libreria",
        galleryCaptureAction: "Scatta o registra",
        galleryEmptyTitle: "Nessun ricordo ancora",
        galleryEmptyMessage: "Carica le foto e i video della festa: li vedranno tutti i partecipanti al profilo.",
        galleryLockedTitle: "Disponibile dal giorno della festa",
        galleryLockedMessageFormat: "La galleria condivisa si apre il %@, cos\u{00EC} puoi raccogliere subito foto e video del compleanno.",
        galleryUploadingTitle: "Caricamento in corso\u{2026}",
        galleryUploadingCountFormat: "%d in attesa",
        galleryDeleteAction: "Elimina ricordo",
        galleryDeleteConfirmTitle: "Eliminare il ricordo?",
        galleryDeleteConfirmMessage: "La foto o il video sparir\u{00E0} anche per gli altri partecipanti.",
        galleryPrivacyNote: "Solo chi ha accesso al profilo pu\u{00F2} vedere e caricare questi ricordi.",
        galleryLoadingLabel: "Caricamento\u{2026}",
        galleryMediaUnavailable: "Contenuto non disponibile offline. Riprova quando torni online.",
        galleryTooLargeMessage: "Il file \u{00E8} troppo grande: prova con un video pi\u{00F9} corto (max 25 MB).",
        galleryPrepareFailedMessage: "Non riusciamo a preparare questo contenuto. Riprova con un altro file.",
        galleryRetryUnavailable: "Il file originale non \u{00E8} pi\u{00F9} disponibile: caricalo di nuovo.",
        cloudSectionTitle: "Backup e ripristino",
        cloudSectionCaption: "Tieni al sicuro profili, diario, piani e messaggi.",
        cloudManageTitle: "Backup e ripristino",
        cloudOnLabel: "Backup attivo",
        cloudOffLabel: "Backup non attivo",
        cloudOffCaption: "Al momento i tuoi dati vivono solo su questo iPhone.",
        cloudNeverSynced: "Nessun salvataggio ancora effettuato.",
        cloudLastSyncFormat: "Ultimo salvataggio: %@",
        cloudEnableTitle: "Attiva il backup",
        cloudEnableCaption: "Kudao salva una copia dei tuoi profili, delle note del diario, dei piani festa e dei messaggi. Ricevi un codice di ripristino per rimetterli su un altro iPhone.",
        cloudEnableAction: "Attiva il backup",
        cloudCodeLabel: "Il tuo codice di ripristino",
        cloudCodeCaption: "Conservalo in un posto sicuro: \u{00E8} l\u{2019}unica chiave per recuperare i tuoi dati. Chi ha il codice pu\u{00F2} ripristinarli.",
        cloudCopyAction: "Copia il codice",
        cloudCopiedLabel: "Codice copiato",
        cloudActionsTitle: "Gestione",
        cloudSyncNowAction: "Salva adesso",
        cloudDisableAction: "Disattiva il backup",
        cloudDeleteRemoteAction: "Disattiva ed elimina la copia",
        cloudDisableTitle: "Disattivare il backup?",
        cloudDisableMessage: "I dati restano su questo iPhone. Puoi anche eliminare del tutto la copia salvata.",
        cloudRestoreTitle: "Ripristina su questo iPhone",
        cloudRestoreHint: "Hai gi\u{00E0} un backup? Inserisci il codice di ripristino per riportare qui tutto.",
        cloudRestorePlaceholder: "CODICE",
        cloudRestoreAction: "Ripristina",
        cloudRestoredFormat: "%d elementi ripristinati",
        cloudBackedUpBanner: "Tutto salvato",
        cloudPrivacyNote: "Kudao non chiede email n\u{00E9} password: la copia \u{00E8} legata solo al tuo codice di ripristino, salvato nel portachiavi di iOS. I profili condivisi da altri non vengono salvati qui.",
        cloudUnavailableMessage: "Il backup non \u{00E8} disponibile in questa versione dell\u{2019}app.",
        cloudInvalidCodeMessage: "Codice non valido: controlla di averlo copiato per intero.",
        cloudUnknownCodeMessage: "Nessun backup trovato con questo codice.",
        cloudGenericErrorMessage: "Non riesco a raggiungere il backup: controlla la connessione e riprova.",
        gallerySortLabel: "Ordine",
        gallerySortNewest: "Dai pi\u{00F9} recenti",
        gallerySortOldest: "Dai pi\u{00F9} vecchi",
        myProfileTitle: "Il mio profilo",
        myProfileSubtitle: "Foto e nome che vedono le persone con cui condividi un festeggiato.",
        notificationDefaultsTitle: "Impostazioni notifiche",
        notificationDefaultsCaption: "Valori usati per ogni nuovo festeggiato. Puoi sempre cambiarli sul singolo profilo.",
        defaultReminderDaysLabel: "Promemoria compleanno",
        defaultGiftDaysLabel: "Promemoria regalo",
        defaultReminderTimeLabel: "Orario",
        defaultsAppliedNote: "L\u{2019}orario vale per tutti i promemoria gi\u{00E0} programmati.",
        privacySectionTitle: "Privacy",
        privacyMovedCaption: "Face ID e anteprime discrete si gestiscono da Il mio profilo.",
        accountSectionTitle: "Account",
        accountNoLoginTitle: "Nessun accesso richiesto",
        accountNoLoginCaption: "Kudao funziona senza email n\u{00E9} password: i dati restano su questo iPhone.",
        accountVaultCaption: "Recuperabile con il tuo codice di ripristino.",
        accountSignOutAction: "Esci dal backup",
        accountSignOutTitle: "Uscire dal backup?",
        accountSignOutMessage: "Questo iPhone smette di salvare nel cloud. I dati restano qui e la copia salvata non viene toccata: puoi rientrare con il codice di ripristino.",
        appInfoTitle: "Info app",
        appVersionLabel: "Versione",
        appSupportAction: "Scrivi al supporto",
        appSupportCaption: "Rispondiamo di solito entro un paio di giorni lavorativi.",
        galleryPreparingTitle: "Preparo i ricordi\u{2026}",
        galleryUploadAction: "Carica i ricordi",
        galleryCaptionSheetTitle: "Nuovi ricordi",
        galleryCaptionSheetMessage: "Aggiungi una breve didascalia a ogni ricordo. Puoi anche lasciarla vuota.",
        galleryCaptionPlaceholder: "Scrivi una didascalia\u{2026}",
        galleryCaptionAddAction: "Aggiungi didascalia",
        galleryCaptionEditAction: "Modifica didascalia",
        galleryCaptionEditorTitle: "Didascalia",
        photoSourceCameraAction: "Scatta foto",
        photoSourceLibraryAction: "Scegli dalla libreria",
        photoCropTitle: "Inquadra la foto",
        photoCropHint: "Trascina per spostare, pizzica per ingrandire.",
        photoUseAction: "Usa questa foto",
        cameraDeniedTitle: "Fotocamera non accessibile",
        cameraDeniedMessage: "Kudao non ha il permesso di usare la fotocamera. Attivalo nelle Impostazioni di iOS per scattare una foto.",
        libraryDeniedTitle: "Foto non accessibili",
        libraryDeniedMessage: "Kudao non ha il permesso di accedere alle tue foto. Attivalo nelle Impostazioni di iOS per sceglierne una.",
        notificationGalleryTitle: "Ricordi della festa",
        notificationGalleryBodyFormat: "Carica i tuoi ricordi della festa di %@ su Kudao!",

        occasionBirthday: "Compleanno",
        occasionWedding: "Matrimonio",
        occasionRemembrance: "Commemorazione",
        occasionOther: "Altro",
        occasionBirthdayCaption: "Regalo, torta, invitati e auguri per chi festeggia.",
        occasionWeddingCaption: "Anniversario di nozze: regalo ed esperienza di coppia.",
        occasionRemembranceCaption: "Custodisci i ricordi di una persona che non c\u{2019}\u{00E8} pi\u{00F9}.",
        occasionOtherCaption: "Una ricorrenza libera, con le tue regole.",
        occasionBirthdayPlural: "Compleanni",
        occasionWeddingPlural: "Matrimoni",
        occasionRemembrancePlural: "Commemorazioni",
        occasionOtherPlural: "Altro",
        occasionStepTitle: "Che occasione \u{00E8}?",
        occasionStepSubtitle: "Kudao adatta domande, suggerimenti e promemoria al tipo che scegli.",
        weddingDateLabel: "Data del matrimonio",
        passingDateLabel: "Data della scomparsa",
        eventDateLabel: "Data dell\u{2019}evento",
        weddingDateHint: "Il giorno delle nozze: l\u{2019}anniversario si calcola da qui.",
        passingDateHint: "Il giorno da ricordare ogni anno.",
        eventDateHint: "La data che torna ogni anno.",
        weddingStatLabel: "Nozze",
        passingStatLabel: "Scomparsa",
        eventStatLabel: "Data",
        yearsTogetherLabel: "Anni insieme",
        yearsSinceLabel: "Anni fa",
        yearsElapsedLabel: "Anni",
        daysToAnniversary: "all\u{2019}anniversario",
        daysToRemembrance: "alla ricorrenza",
        daysToEvent: "all\u{2019}evento",
        todayAnniversaryTitle: "\u{00C8} oggi l\u{2019}anniversario!",
        todayRemembranceTitle: "Oggi \u{00E8} il giorno del ricordo",
        todayEventTitle: "\u{00C8} oggi!",
        anniversaryYearsFormat: "%d anni insieme",
        yearsAgoFormat: "%d anni fa",
        editionYearsFormat: "%d\u{00B0} anno",
        sendAnniversaryWishesAction: "Fai gli auguri",
        writeThoughtAction: "Scrivi un pensiero",
        sendEventWishesAction: "Scrivi un messaggio",
        memoriesTab: "Ricordi",
        thoughtTab: "Pensiero",
        traitsTab: "Tratti",
        reminderOnTheDayLabel: "Il giorno stesso",
        rememberedNamePlaceholder: "Nome della persona",
        bondLabel: "Legame",
        bondCaption: "Serve solo a dare il tono giusto ai testi che Kudao prepara.",
        bondParent: "Genitore",
        bondGrandparent: "Nonno o nonna",
        bondSibling: "Fratello o sorella",
        bondSpouse: "Coniuge o compagno",
        bondChild: "Figlio o figlia",
        bondFriend: "Amico",
        bondOther: "Persona cara",
        selfProfileToggleTitle: "\u{00C8} un\u{2019}occasione mia",
        selfProfileToggleCaption: "Attivalo per il tuo matrimonio o una tua ricorrenza: Kudao usa il tuo nome.",
        selfProfileNameCaption: "Preso dal tuo profilo. Cambialo da \u{201C}Il mio profilo\u{201D}.",
        selfProfileFallbackName: "Io",
        backAction: "Indietro",
        filterAllOccasions: "Tutti",
        filterEmptyTitle: "Niente qui",
        filterEmptyMessageFormat: "Non hai ancora occasioni nella categoria \u{201C}%@\u{201D}.",
        anniversaryGiftCardTitle: "Regalo anniversario",
        experienceCardTitle: "Esperienza di coppia",
        anniversaryVenueCardTitle: "Dove festeggiare",
        toneIntimate: "Intimo",
        toneSober: "Sobrio",
        notificationAnniversaryTitle: "Anniversario in arrivo",
        notificationAnniversaryBodyFormat: "Preparati per l\u{2019}anniversario di %@.",
        notificationRemembranceTitle: "Giorno del ricordo",
        notificationRemembranceBodyFormat: "Oggi ricordiamo %@.",
        notificationEventTitle: "Ricorrenza in arrivo",
        notificationEventBodyFormat: "Si avvicina la ricorrenza di %@.",

        accountSignInTitle: "Accedi con email",
        accountSignInCaption: "Facoltativo: ritrovi i tuoi dati anche senza il codice di ripristino.",
        accountSignedInCaption: "Account collegato al tuo backup.",
        authSignInTab: "Accedi",
        authSignUpTab: "Registrati",
        authSignInTitle: "Bentornato",
        authSignInSubtitle: "Accedi per ritrovare i tuoi festeggiati su questo iPhone.",
        authSignUpTitle: "Crea il tuo account",
        authSignUpSubtitle: "Un\u{2019}email e una password: bastano a non perdere pi\u{00F9} nulla.",
        authEmailPlaceholder: "La tua email",
        authPasswordPlaceholder: "Password",
        authPasswordHintFormat: "Almeno %d caratteri.",
        authSignInAction: "Accedi",
        authSignUpAction: "Crea account",
        authForgotPasswordAction: "Password dimenticata?",
        authResetSentMessage: "Ti abbiamo inviato un\u{2019}email per reimpostare la password.",
        authOptionalNote: "L\u{2019}account \u{00E8} facoltativo. Kudao funziona lo stesso senza, e il codice di ripristino continua a valere.",
        authConfirmTitle: "Conferma la tua email",
        authConfirmMessageFormat: "Abbiamo scritto a %@. Apri il link nell\u{2019}email, poi torna qui e accedi.",
        authResendAction: "Invia di nuovo l\u{2019}email",
        authSignedInBadge: "Accesso effettuato",
        authVaultLinkedTitle: "Backup collegato",
        authVaultLinkedCaption: "I tuoi dati tornano indietro accedendo con questa email, ovunque.",
        authVaultMissingTitle: "Nessun backup collegato",
        authVaultMissingCaption: "Attiva il backup: da quel momento sar\u{00E0} legato a questo account.",
        authRestoredFormat: "Recuperati %d elementi dal tuo account.",
        authSignOutAction: "Esci dall\u{2019}account",
        authSignOutNote: "Uscendo resti su questo iPhone con tutti i tuoi dati: sparisce solo l\u{2019}accesso rapido.",
        authUnavailableMessage: "Servizio non disponibile in questa versione dell\u{2019}app.",
        authInvalidEmailMessage: "Controlla l\u{2019}indirizzo email.",
        authMissingPasswordMessage: "Inserisci la password.",
        authWeakPasswordFormat: "La password deve avere almeno %d caratteri.",
        authWrongCredentialsMessage: "Email o password non corretti.",
        authNotConfirmedMessage: "Devi prima confermare la tua email: controlla la posta.",
        authEmailTakenMessage: "Esiste gi\u{00E0} un account con questa email. Prova ad accedere.",
        authRateLimitMessage: "Troppi tentativi. Riprova tra qualche minuto.",
        authOfflineMessage: "Sembri offline. Controlla la connessione e riprova.",
        authGenericErrorMessage: "Qualcosa \u{00E8} andato storto. Riprova tra poco.",

        notificationSettingsMenuTitle: "Notifiche",
        notificationSettingsCaption: "Scegli con quanto anticipo vuoi essere avvisato, per ogni tipo di occasione.",
        notificationsActiveLabel: "Notifiche attive",
        enableNotificationsAction: "Attiva le notifiche",
        mainReminderLabel: "Avviso principale",
        applyToExistingFormat: "Applica ai %d profili esistenti",
        appliedToExistingLabel: "Applicato",
        resetToShippedAction: "Valori consigliati",
        noProfilesInCategoryLabel: "Nessun profilo di questo tipo, per ora.",
        galleryAutoOrderNote: "Ordinati in automatico: i ricordi pi\u{00F9} recenti in alto.",
        diaryReminderSectionTitle: "Promemoria diario",
        diaryReminderToggleTitle: "Promemoria diario",
        diaryReminderCaption: "Un invito gentile ad annotare qualcosa, anche quando la ricorrenza \u{00E8} lontana.",
        diaryFrequencyLabel: "Frequenza",
        diaryCadenceDaily: "Giornaliera",
        diaryCadenceEveryThreeDays: "Ogni 3 giorni",
        diaryCadenceWeekly: "Settimanale",
        diaryCadenceNever: "Mai",
        diaryReminderTimeLabel: "Orario dell\u{2019}invito",
        diaryReminderNextFormat: "Prossimo invito: %@",
        diaryReminderPeopleFormat: "%d profili coinvolti",
        diaryReminderRemembranceNote: "Le commemorazioni restano sempre fuori da questi inviti.",
        diaryReminderExcludeTitle: "Escludi dai promemoria diario",
        diaryReminderExcludeCaption: "Questo profilo non verr\u{00E0} pi\u{00F9} nominato negli inviti a scrivere.",
        diaryReminderOffNote: "I promemoria diario sono disattivati nelle impostazioni notifiche.",
        diaryNudgeTitle: "Diario Kudao",
        diaryNudgeVariantOne: "Hai notato qualcosa su qualcuno di speciale oggi? Scrivilo su Kudao.",
        diaryNudgeVariantTwo: "Un dettaglio, un gusto, un\u{2019}idea: annotalo ora, ti sar\u{00E0} utile dopo.",
        diaryNudgeVariantThree: "Tieni aggiornati i profili delle persone che contano.",
        diaryNudgePersonFormatOne: "Hai scoperto qualcosa su %@ di recente?",
        diaryNudgePersonFormatTwo: "Due righe su %@: il te del futuro ringrazier\u{00E0}.",
        diaryNudgePairFormat: "Hai novit\u{00E0} su %@ o %@? Un dettaglio in pi\u{00F9} li rende speciali.",
        quickNoteTitle: "Nota al volo",
        quickNoteCaption: "Scegli la persona e scrivi: bastano poche parole.",
        quickNoteEmptyMessage: "Nessun profilo disponibile per una nota. Creane uno e torna qui.",
        quickNoteSaveAction: "Salva",
        gridCategoriesTitle: "Categorie",
        gridNextEventTitle: "Prossimo evento",
        gridNextEventEmpty: "Nessuna data",
        gridPendingCountFormat: "%d piani",
        gridPendingEmpty: "Tutto ok",
        gridProfileCountFormat: "%d profili",
        gridProfileCountOne: "1 profilo",
        gridCategoryEmptyHint: "Nessun profilo, tocca per aggiungere",
        gridAnniversaryInFormat: "Anniversario tra %d g",
        gridSharedCountFormat: "%d profili condivisi",
        sharedListTitle: "Condivisi con te",
        pendingScopeEmptyMessage: "Nessun piano festa in attesa: sei in pari.",
        sharedScopeEmptyMessage: "Non stai ancora organizzando niente insieme ad altri.",
        buyOnAmazonAction: "Acquista su Amazon",
        affiliateSectionTitle: "Affiliazione Amazon",
        affiliateCaption: "Ogni mercato Amazon ha il suo tag: quello di amazon.it non guadagna nulla su amazon.fr. Il mercato viene scelto dalla lingua dell\u{2019}app, o da quella del dispositivo.",
        affiliateTagLabel: "Tag affiliato",
        affiliateActiveBadge: "In uso",
        affiliateFallbackNote: "Senza tag il pulsante apre comunque Amazon, ma senza commissione.",
        affiliateDisclosure: "Come Affiliato Amazon, Kudao riceve un guadagno dagli acquisti idonei, senza costi aggiuntivi per te",
        linkPreviewTitle: "Anteprima link",
        linkPreviewBadgeLabel: "Vedi il link prima di aprirlo",
        linkPreviewStoreLabel: "Negozio",
        linkPreviewQueryLabel: "Ricerca",
        linkPreviewNoTag: "Nessun tag per questo mercato",
        linkPreviewNoTagHint: "Il link apre lo stesso Amazon, ma non genera commissioni. Aggiungi il tag in Il mio profilo \u{203A} Affiliazione Amazon.",
        linkPreviewUrlLabel: "URL di destinazione",
        linkPreviewOpenAction: "Apri in Safari",
        linkPreviewCopyAction: "Copia link",
        linkPreviewCopiedLabel: "Copiato",
        linkPreviewGoogleAction: "Cerca invece su Google Shopping",
        libraryTitle: "Libreria",
        libraryEmptyTitle: "La libreria \u{00E8} ancora vuota",
        libraryEmptyMessage: "Quando una data passa, Kudao la archivia qui: piano, messaggio e foto di quell\u{2019}anno restano per sempre.",
        libraryProfileEmptyMessage: "Il primo anno finir\u{00E0} in libreria subito dopo la prossima data.",
        libraryFilterEmptyMessage: "Nessun evento archiviato con questi filtri.",
        libraryAllProfiles: "Tutti i profili",
        libraryCountFormat: "%d eventi archiviati",
        libraryYearsCountFormat: "%d anni in archivio",
        libraryPlanSection: "Il piano di quell\u{2019}anno",
        libraryNoPlanLabel: "Nessun piano salvato per quell\u{2019}anno",
        librarySentBadge: "Inviato",
        libraryNotSentBadge: "Mai inviato",
        libraryMemoriesSection: "Note dell\u{2019}anno",
        libraryMediaSection: "Foto e video",
        libraryMediaCountFormat: "%d ricordi raccolti",
        libraryNotesCountFormat: "%d note scritte in quell\u{2019}anno",
        libraryKeywordsSection: "Cosa sapevamo allora",
        libraryArchivedOnFormat: "Archiviato il %@"
    )

    static let english = Strings(
        homeTitle: "Celebrations",
        homeSubtitle: "Take notes all year, celebrate perfectly.",
        upNext: "Up next",
        othersSection: "Coming up",
        emptyTitle: "No one yet",
        emptyMessage: "Add the people you care about and start collecting ideas for their birthday.",
        emptyAction: "Create first profile",
        searchPlaceholder: "Search a name",
        searchClear: "Clear search",
        resultsSection: "Results",
        noResultsTitle: "No results",
        noResultsMessageFormat: "No profile matches “%@”.",
        sortLabel: "Sort",
        sortNearest: "Closest birthday",
        sortAlphabetical: "Name (A-Z)",
        sortRecentlyAdded: "Recently added",
        newProfileTitle: "New profile",
        editProfileTitle: "Edit profile",
        nameLabel: "Name",
        namePlaceholder: "What's their name?",
        photoLabel: "Photo",
        addPhoto: "Add photo",
        changePhoto: "Change photo",
        removePhoto: "Remove photo",
        birthDateLabel: "Date of birth",
        relationshipLabel: "Relationship",
        surpriseTitle: "Surprise mode",
        surpriseDescription: "The profile stays hidden: it won't be visible or shareable with the birthday person.",
        surpriseBadge: "Surprise",
        saveAction: "Save",
        cancelAction: "Cancel",
        deleteAction: "Delete",
        createAction: "Create profile",
        retryAction: "Try again",
        relFriend: "Friend",
        relFamily: "Family",
        relPartner: "Partner",
        relColleague: "Colleague",
        todayTitle: "It's today!",
        tomorrowLabel: "Tomorrow",
        todayLabel: "Today",
        yesterdayLabel: "Yesterday",
        dayUnit: "day",
        daysUnit: "days",
        daysToGo: "to the birthday",
        turnsFormat: "Turning %d",
        turnsTodayFormat: "Turning %d today",
        nextBirthdayLabel: "Next birthday",
        imminentBadge: "This week",
        imminentDaysFormat: "In %d days",
        diaryTab: "Diary",
        preferencesTab: "Preferences",
        suggestionsTab: "Suggestions",
        diaryEmptyTitle: "Empty diary",
        diaryEmptyMessage: "Write the first note: tastes, wishes and details you spot during the year.",
        preferencesEmptyTitle: "No preferences yet",
        preferencesEmptyMessage: "Keywords are pulled automatically from your diary notes.",
        suggestionsEmptyTitle: "No suggestions yet",
        suggestionsEmptyMessage: "Gift, cake, venue and guest count will show up here based on your diary.",
        comingSoon: "Coming soon",
        diaryComposerPlaceholderFormat: "What did you notice about %@ today?",
        diarySendNote: "Save note",
        diaryNotesSection: "Notes",
        diaryNotesCountFormat: "%d notes",
        deleteNoteAction: "Delete note",
        analyzingLabel: "Analyzing…",
        analysisFailedLabel: "Keywords not extracted",
        giftIdeaBadge: "Gift idea",
        giftIdeasSection: "Gift leads",
        tagsSection: "Keywords",
        removeTagHint: "Tap × to remove a keyword that got it wrong.",
        removeTagAction: "Remove keyword",
        planTitleFormat: "Party plan for %@",
        suggestionsGeneratingTitle: "Thinking…",
        suggestionsGeneratingMessage: "Reading the collected preferences and drafting the plan.",
        suggestionsNoTagsTitle: "One note needed first",
        suggestionsNoTagsMessage: "Write a few diary notes: suggestions are built from the extracted preferences.",
        suggestionsErrorTitle: "Suggestions unavailable",
        generateAction: "Generate suggestions",
        regenerateAction: "Regenerate",
        regenerateAllAction: "Regenerate all",
        giftCardTitle: "Gift",
        cakeCardTitle: "Cake",
        venueCardTitle: "Venue",
        guestsCardTitle: "Guests",
        reasonLabel: "Why",
        priceBandLabel: "Price range",
        priceLow: "Low range",
        priceMedium: "Mid range",
        priceHigh: "High range",
        confidenceLabel: "Confidence",
        confidenceLow: "low",
        confidenceMedium: "medium",
        confidenceHigh: "high",
        lowConfidenceBanner: "Write more diary notes for sharper suggestions.",
        confirmAllAction: "Confirm all",
        confirmedAtFormat: "Plan confirmed on %@",
        unconfirmedChanges: "Unconfirmed changes",
        editSuggestionTitle: "Edit suggestion",
        editedBadge: "Edited",
        guestsUnitFormat: "%d people",
        basedOnTagsFormat: "Based on %d keywords",
        doneAction: "Done",
        catFood: "Food",
        catTravel: "Travel",
        catShopping: "Shopping",
        catHobby: "Hobbies",
        catPlaces: "Places",
        catOther: "Other",
        profileSettings: "Profile settings",
        editData: "Edit details",
        deleteProfile: "Delete profile",
        deleteConfirmTitle: "Delete this profile?",
        deleteConfirmMessageFormat: "%@'s profile and all diary notes will be deleted.",
        languageLabel: "Language",
        profilesCountFormat: "%d profiles",
        ageNowFormat: "%d years old",
        remindersMenuTitle: "Reminders & notifications",
        remindersSectionTitle: "Reminders",
        reminderToggleTitle: "Birthday reminder",
        reminderToggleDescription: "A local alert when the birthday gets close, with the suggestions ready.",
        reminderDaysTitle: "Remind me",
        dayBeforeFormat: "%d day before",
        daysBeforeFormat: "%d days before",
        giftReminderToggleTitle: "Separate gift reminder",
        giftReminderDescription: "An extra alert, earlier than the birthday reminder, to buy the gift in time.",
        giftReminderDaysTitle: "Gift reminder",
        reminderScheduledFormat: "Next alert: %@",
        reminderDisabledLabel: "No reminder scheduled",
        notificationsDeniedTitle: "Notifications are off",
        notificationsDeniedMessage: "Turn on Kudao notifications in iOS settings to get your reminders.",
        openSettingsAction: "Open Settings",
        notificationBirthdayTitle: "Birthday coming up",
        notificationBirthdayBodyFormat: "%@'s birthday is coming up! Check your suggestions on Kudao",
        notificationGiftTitle: "Gift reminder",
        notificationGiftBodyFormat: "Don't forget %@'s gift: %@",
        notificationGiftBodyFallbackFormat: "Don't forget %@'s gift. Open Kudao to pick an idea.",
        exportSectionTitle: "Export diary",
        exportSectionDescription: "Save this profile's notes and keywords as a file you can share or archive.",
        exportPDFAction: "Export as PDF",
        exportJSONAction: "Export as JSON",
        exportPreparing: "Preparing the file…",
        exportFailedTitle: "Export failed",
        exportFailedMessage: "The file could not be created. Please try again.",
        exportDocumentTitleFormat: "%@'s diary",
        exportGeneratedAtFormat: "Exported on %@",
        exportProfileSection: "Profile",
        exportPlanSection: "Party plan",
        exportNotesSection: "Diary notes",
        exportNoNotes: "No diary notes yet.",
        exportNoPlan: "No party plan saved.",
        reviewBannerTitle: "Needs confirming",
        reviewBannerSubtitleFormat: "%d party plans are waiting for your go-ahead",
        planReviewTitle: "All set?",
        planReviewSubtitleFormat: "%@'s birthday is in %d days. Confirm the plan or tweak it.",
        planReviewTodayFormat: "Today is %@'s birthday. Confirm the plan or tweak it.",
        planReviewNoPlanTitle: "No plan yet",
        planReviewNoPlanMessage: "Open the suggestions to build this profile's party plan.",
        confirmAction: "Confirm",
        modifyAction: "Edit",
        pendingBadgeLabel: "Plan to confirm",
        appSettingsMenu: "App settings",
        settingsTitle: "Settings",
        settingsLanguageSection: "Language",
        settingsSurpriseSection: "Surprise mode",
        settingsSurpriseFooter: "These protections apply to every profile with surprise mode enabled.",
        faceIDToggleTitle: "Protect surprise profiles with Face ID",
        faceIDToggleDescription: "Asks for Face ID, Touch ID or your device passcode before opening a surprise profile.",
        hidePreviewsToggleTitle: "Hide notification previews for surprise profiles",
        hidePreviewsToggleDescription: "Notifications only show “Kudao reminder”, never the person’s name.",
        biometryUnavailableNote: "No biometrics set up: your device passcode will be requested.",
        unlockReasonFormat: "Unlock %@’s profile",
        unlockAction: "Unlock",
        unlockFailedTitle: "Unlock failed",
        unlockFailedMessage: "We couldn’t verify your identity. Please try again.",
        lockedBadgeLabel: "Protected profile",
        notificationGenericTitle: "Kudao reminder",
        notificationGenericBody: "Open Kudao to see the reminder.",
        maskedProfileName: "Surprise",
        settingsWidgetSection: "Widget",
        settingsWidgetHint: "Touch and hold the Home Screen, tap Edit, then Add Widget and pick Kudao for the countdown.",
        settingsSharingNote: "Surprise profiles will stay out of any sharing with the birthday person.",
        lastNameLabel: "Last name",
        lastNamePlaceholder: "Last name (optional)",
        noLastNameLabel: "No last name",
        addressLabel: "Address",
        addressPlaceholder: "Street, city (optional)",
        phoneLabel: "Phone",
        phonePlaceholder: "Phone number (optional)",
        emailLabel: "Email",
        emailPlaceholder: "Email address (optional)",
        contactsSectionTitle: "Contact",
        birthLabel: "Born",
        ageLabel: "Age",
        ageYearsFormat: "%d years",
        notificationActiveLabel: "Reminder on",
        notificationOffLabel: "Reminder off",
        daysBeforeShortLabel: "days before:",
        hourShortLabel: "time:",
        editAction: "Edit",
        sendWishesAction: "Send wishes",
        messageTab: "Message",
        messageSectionTitle: "Birthday message",
        messageGeneratingTitle: "Writing the wishes\u{2026}",
        messageGeneratingMessage: "Using your diary notes to make it truly personal.",
        messageEmptyTitle: "No message yet",
        messageEmptyMessage: "Generate a personal birthday message from the keywords collected in the diary.",
        messageToneLabel: "Tone",
        toneWarm: "Warm",
        toneFunny: "Playful",
        toneElegant: "Elegant",
        messageRegenerateAction: "Regenerate",
        messageCopyAction: "Copy",
        messageCopiedLabel: "Copied",
        messageShareAction: "Share",
        messageSMSAction: "Messages",
        messageEmailAction: "Email",
        messageEmailSubjectFormat: "Happy birthday %@!",
        messageBasedOnNote: "Written from your diary keywords",
        buyOnlineAction: "Buy online",
        findStoreAction: "Find a shop near you",
        noPlanAlertTitle: "No gift idea yet",
        noPlanAlertMessage: "Generate the suggestions in the Suggestions tab first.",
        giftFromPlanFormat: "Gift idea: %@",
        storesTitle: "Nearby shops",
        storesSearchingLabel: "Looking for shops\u{2026}",
        storesEmptyTitle: "No shop found",
        storesEmptyMessage: "There is no shop of this kind within 5 km of you.",
        storesPermissionTitle: "Location needed",
        storesPermissionMessage: "Kudao uses your location only to look for nearby shops.",
        storesPermissionAction: "Allow location",
        storesDeniedTitle: "Location unavailable",
        storesDeniedMessage: "Turn on location services for Kudao in Settings.",
        storesFailedTitle: "Search failed",
        storesFailedMessage: "Shops cannot be searched right now. Please try again shortly.",
        storesRadiusNote: "Within 5 km of you",
        storesSearchingCategoryFormat: "Searching: %@",
        openInMapsAction: "Open in Maps",
        distanceKmFormat: "%.1f km",
        distanceMetersFormat: "%d m",
        shareProfileAction: "Share profile",
        shareProfileTitle: "Share profile",
        shareProfileSubtitleFormat: "Invite someone to plan %@'s birthday with you.",
        permissionSectionTitle: "What they can do",
        permissionViewTitle: "View only",
        permissionViewCaption: "Sees the profile, the diary and the suggestions without changing them.",
        permissionEditTitle: "Can collaborate",
        permissionEditCaption: "Adds diary notes and votes on the suggestions.",
        generateInviteAction: "Generate invite code",
        inviteReadyTitle: "Invite ready",
        inviteCodeLabel: "Invite code",
        inviteHint: "They open Kudao, tap the settings icon and choose \u{201C}Join a profile\u{201D}.",
        copyCodeAction: "Copy code",
        copiedLabel: "Copied",
        shareInviteAction: "Share invite",
        newInviteAction: "Generate another code",
        discardInviteAction: "Discard invite",
        inviteMessageFormat: "Let's plan %@'s birthday together on Kudao! Open the app, go to Settings \u{2192} Join a profile and enter the code: %@",
        shareBlockedSurpriseTitle: "Protected surprise profile",
        shareBlockedSurpriseMessage: "Turn off surprise protection in the settings to share this profile.",
        yourNameLabel: "Your name",
        yourNamePlaceholder: "What's your name",
        yourNameCaption: "Other participants use it to recognise your notes.",
        participantsTitle: "Participants",
        participantsMenuTitle: "Participants",
        participantsCountFormat: "%d participants",
        participantOwnerBadge: "Owner",
        participantYou: "You",
        participantUnknown: "Participant",
        participantPendingTitle: "Pending invites",
        removeParticipantAction: "Remove",
        removeParticipantConfirmFormat: "%@ will lose access to this profile. The notes they already wrote stay in the diary.",
        ownerCannotBeRemoved: "The owner cannot be removed: delete the profile to end the sharing.",
        guestLeaveHint: "Only the profile owner can manage access.",
        participantsEmptyTitle: "No participants yet",
        participantsEmptyMessage: "Share the profile to plan the party together with someone else.",
        joinedAtFormat: "Since %@",
        joinShareMenuTitle: "Join a profile",
        joinShareTitle: "Join a profile",
        joinShareSubtitle: "Enter the invite code you received.",
        joinCodePlaceholder: "CODE",
        joinAction: "Join",
        pasteCodeAction: "Paste from clipboard",
        joinSuccessFormat: "You now help plan %@'s birthday",
        joinSuccessCaption: "The profile is in your list, with the shared notes and suggestions.",
        sharedProfileFallbackName: "Shared profile",
        shareErrorGeneric: "Something went wrong. Please try again.",
        shareErrorInvalidCode: "Invalid code. Please check it and try again.",
        shareErrorCodeUsed: "This code has already been used by someone else.",
        shareErrorOwnProfile: "This profile is already yours.",
        shareErrorNoAccess: "You no longer have access to this shared profile.",
        shareErrorReadOnly: "You have view-only access to this profile.",
        shareErrorNotOwner: "Only the profile owner can do that.",
        shareErrorOffline: "No connection. Please try again once you are online.",
        sharedBadge: "Shared",
        sharedByFormat: "Shared by %@",
        readOnlyBadge: "View only",
        readOnlyDiaryMessage: "You have view-only access: you can read the notes but not add any.",
        readOnlyPlanMessage: "The plan is managed by the profile owner.",
        voteUpLabel: "Love it",
        voteDownLabel: "Not convinced",
        voteTallyFormat: "%1$d for \u{00B7} %2$d against",
        votesEmptyLabel: "No votes yet",
        syncingLabel: "Refreshing\u{2026}",
        collaborationSectionTitle: "Sharing",
        collaborationHubTitle: "Together with others",
        collaborationHubCountFormat: "%d shared profiles",
        collaborationInviteTitle: "Plan it together",
        collaborationInviteMessage: "Invite anyone into a profile, or join with a code.",
        inviteSomeoneAction: "Invite someone",
        pendingInvitesCountFormat: "%d invites pending",
        collaborationOnlyYou: "Just you, for now",
        ageBracketLabel: "Age group",
        ageBracketChild: "Child",
        ageBracketTeen: "Teenager",
        ageBracketAdult: "Adult",
        ageBracketSenior: "Senior",
        favoriteCharacterLabel: "Favourite cartoon or character",
        favoriteCharacterPlaceholder: "e.g. Bluey, Spider-Man, Frozen",
        favoriteCharacterCaption: "Optional: helps pick a themed cake and gift.",
        messageGenerateAction: "Generate message",
        messageWriteMyselfAction: "Write it myself",
        messagePlaceholder: "Write your wishes here\u{2026}",
        messageEditorHint: "Edit the text however you like \u{2014} we send it exactly as it is.",
        messageSentBadge: "Sent",
        messageScheduleTitle: "Send schedule",
        messageScheduleToggle: "Remind me to send it",
        messageSendDateLabel: "Send on",
        messageScheduleReadyFormat: "We\u{2019}ll remind you on %@",
        messagePastDateLabel: "Pick a future date to get the reminder.",
        messageAlreadySentLabel: "Message already sent.",
        messageMarkSentShortAction: "Mark as sent",
        messageMarkSentAction: "Yes, I sent it",
        messageMarkUnsentAction: "Mark as not sent",
        messageNotYetAction: "Not yet",
        messageSentConfirmTitle: "Did you send your wishes?",
        messageSentConfirmMessage: "If you confirm, we\u{2019}ll stop reminding you about this message.",
        messageContactTitle: "Recipient contact",
        messageContactCaption: "Used to open WhatsApp or Messages with the text ready.",
        messageNoContactLabel: "No contact saved",
        messageNeedsPhoneHint: "Add a number to open the chat prefilled.",
        messageWhatsAppAction: "Open WhatsApp",
        messageMessagesAction: "Open Messages",
        messageOpenFailedTitle: "App unavailable",
        messageOpenFailedMessage: "We couldn\u{2019}t open that app on this device. The text has been copied to your clipboard.",
        notificationMessageTitle: "Wishes to send",
        notificationMessageBodyFormat: "It\u{2019}s time to wish %@ a happy birthday!",
        messageAutoRefreshToggle: "Update with new notes",
        messageAutoRefreshCaption: "When you add notes or keywords to the diary, we rewrite the draft of your wishes.",
        messageAutoRefreshPausedLabel: "You edited the text yourself, so automatic updates are paused.",
        messageAutoRefreshResumeAction: "Resume",
        messageAutoRefreshedFormat: "Updated with your latest notes \u{00B7} %@",
        galleryTab: "Gallery",
        gallerySectionTitle: "Party memories",
        galleryCountFormat: "%d memories",
        galleryAddAction: "Add memories",
        galleryFromLibraryAction: "Choose from library",
        galleryCaptureAction: "Take photo or video",
        galleryEmptyTitle: "No memories yet",
        galleryEmptyMessage: "Upload the party photos and videos: everyone with access to the profile will see them.",
        galleryLockedTitle: "Available from the party day",
        galleryLockedMessageFormat: "The shared gallery opens on %@, so you can collect the birthday photos and videos right away.",
        galleryUploadingTitle: "Uploading\u{2026}",
        galleryUploadingCountFormat: "%d left",
        galleryDeleteAction: "Delete memory",
        galleryDeleteConfirmTitle: "Delete this memory?",
        galleryDeleteConfirmMessage: "The photo or video will disappear for the other participants too.",
        galleryPrivacyNote: "Only people with access to the profile can see and add these memories.",
        galleryLoadingLabel: "Loading\u{2026}",
        galleryMediaUnavailable: "This content isn\u{2019}t available offline. Try again once you\u{2019}re back online.",
        galleryTooLargeMessage: "That file is too big: try a shorter video (25 MB max).",
        galleryPrepareFailedMessage: "We can\u{2019}t prepare this content. Try another file.",
        galleryRetryUnavailable: "The original file is gone: please upload it again.",
        cloudSectionTitle: "Backup & restore",
        cloudSectionCaption: "Keep profiles, diary, plans and messages safe.",
        cloudManageTitle: "Backup & restore",
        cloudOnLabel: "Backup is on",
        cloudOffLabel: "Backup is off",
        cloudOffCaption: "Right now your data only lives on this iPhone.",
        cloudNeverSynced: "Nothing has been saved yet.",
        cloudLastSyncFormat: "Last saved: %@",
        cloudEnableTitle: "Turn on backup",
        cloudEnableCaption: "Kudao keeps a copy of your profiles, diary notes, party plans and messages. You get a recovery code to bring them back on another iPhone.",
        cloudEnableAction: "Turn on backup",
        cloudCodeLabel: "Your recovery code",
        cloudCodeCaption: "Keep it somewhere safe: it is the only key to your data. Anyone with the code can restore it.",
        cloudCopyAction: "Copy code",
        cloudCopiedLabel: "Code copied",
        cloudActionsTitle: "Manage",
        cloudSyncNowAction: "Save now",
        cloudDisableAction: "Turn off backup",
        cloudDeleteRemoteAction: "Turn off and delete the copy",
        cloudDisableTitle: "Turn off backup?",
        cloudDisableMessage: "Your data stays on this iPhone. You can also delete the saved copy entirely.",
        cloudRestoreTitle: "Restore on this iPhone",
        cloudRestoreHint: "Already have a backup? Enter the recovery code to bring everything back.",
        cloudRestorePlaceholder: "CODE",
        cloudRestoreAction: "Restore",
        cloudRestoredFormat: "%d items restored",
        cloudBackedUpBanner: "Everything saved",
        cloudPrivacyNote: "Kudao asks for no email and no password: the copy is tied only to your recovery code, stored in the iOS keychain. Profiles shared with you by others are not saved here.",
        cloudUnavailableMessage: "Backup is not available in this build of the app.",
        cloudInvalidCodeMessage: "That code looks incomplete: please check it and try again.",
        cloudUnknownCodeMessage: "No backup was found for this code.",
        cloudGenericErrorMessage: "Cannot reach the backup right now: check your connection and try again.",
        gallerySortLabel: "Order",
        gallerySortNewest: "Newest first",
        gallerySortOldest: "Oldest first",
        myProfileTitle: "My profile",
        myProfileSubtitle: "The photo and name people see when you share a celebration.",
        notificationDefaultsTitle: "Notification settings",
        notificationDefaultsCaption: "Used for every new celebration. You can still change them profile by profile.",
        defaultReminderDaysLabel: "Birthday reminder",
        defaultGiftDaysLabel: "Gift reminder",
        defaultReminderTimeLabel: "Time",
        defaultsAppliedNote: "The time applies to every reminder already scheduled.",
        privacySectionTitle: "Privacy",
        privacyMovedCaption: "Face ID and discreet previews live in My profile.",
        accountSectionTitle: "Account",
        accountNoLoginTitle: "No sign-in needed",
        accountNoLoginCaption: "Kudao works with no email and no password: your data stays on this iPhone.",
        accountVaultCaption: "Recoverable with your recovery code.",
        accountSignOutAction: "Sign out of backup",
        accountSignOutTitle: "Sign out of backup?",
        accountSignOutMessage: "This iPhone stops saving to the cloud. Your data stays here and the saved copy is untouched: you can come back with your recovery code.",
        appInfoTitle: "App info",
        appVersionLabel: "Version",
        appSupportAction: "Contact support",
        appSupportCaption: "We usually reply within a couple of working days.",
        galleryPreparingTitle: "Getting the memories ready\u{2026}",
        galleryUploadAction: "Upload memories",
        galleryCaptionSheetTitle: "New memories",
        galleryCaptionSheetMessage: "Add a short caption to each memory. Leaving it empty is fine too.",
        galleryCaptionPlaceholder: "Write a caption\u{2026}",
        galleryCaptionAddAction: "Add caption",
        galleryCaptionEditAction: "Edit caption",
        galleryCaptionEditorTitle: "Caption",
        photoSourceCameraAction: "Take a photo",
        photoSourceLibraryAction: "Choose from library",
        photoCropTitle: "Frame the photo",
        photoCropHint: "Drag to move, pinch to zoom.",
        photoUseAction: "Use this photo",
        cameraDeniedTitle: "Camera not available",
        cameraDeniedMessage: "Kudao is not allowed to use the camera. Turn it on in iOS Settings to take a photo.",
        libraryDeniedTitle: "Photos not available",
        libraryDeniedMessage: "Kudao is not allowed to access your photos. Turn it on in iOS Settings to pick one.",
        notificationGalleryTitle: "Party memories",
        notificationGalleryBodyFormat: "Upload your memories from %@\u{2019}s party on Kudao!",

        occasionBirthday: "Birthday",
        occasionWedding: "Wedding",
        occasionRemembrance: "Remembrance",
        occasionOther: "Other",
        occasionBirthdayCaption: "Gift, cake, guests and wishes for the person celebrating.",
        occasionWeddingCaption: "Wedding anniversary: a present and something to live together.",
        occasionRemembranceCaption: "Keep the memory of someone who is no longer here.",
        occasionOtherCaption: "A free-form occasion, on your own terms.",
        occasionBirthdayPlural: "Birthdays",
        occasionWeddingPlural: "Weddings",
        occasionRemembrancePlural: "Remembrances",
        occasionOtherPlural: "Other",
        occasionStepTitle: "What kind of occasion?",
        occasionStepSubtitle: "Kudao adapts the questions, the ideas and the reminders to what you pick.",
        weddingDateLabel: "Wedding date",
        passingDateLabel: "Date of passing",
        eventDateLabel: "Date of the event",
        weddingDateHint: "The wedding day: the anniversary is counted from here.",
        passingDateHint: "The day to remember every year.",
        eventDateHint: "The date that comes back every year.",
        weddingStatLabel: "Wedding",
        passingStatLabel: "Passing",
        eventStatLabel: "Date",
        yearsTogetherLabel: "Years together",
        yearsSinceLabel: "Years ago",
        yearsElapsedLabel: "Years",
        daysToAnniversary: "to the anniversary",
        daysToRemembrance: "to the anniversary",
        daysToEvent: "to the event",
        todayAnniversaryTitle: "The anniversary is today!",
        todayRemembranceTitle: "Today is the day of remembrance",
        todayEventTitle: "It\u{2019}s today!",
        anniversaryYearsFormat: "%d years together",
        yearsAgoFormat: "%d years ago",
        editionYearsFormat: "Year %d",
        sendAnniversaryWishesAction: "Send your wishes",
        writeThoughtAction: "Write a thought",
        sendEventWishesAction: "Write a message",
        memoriesTab: "Memories",
        thoughtTab: "Thought",
        traitsTab: "Traits",
        reminderOnTheDayLabel: "On the day itself",
        rememberedNamePlaceholder: "Their name",
        bondLabel: "Bond",
        bondCaption: "It only helps Kudao find the right tone for the texts it prepares.",
        bondParent: "Parent",
        bondGrandparent: "Grandparent",
        bondSibling: "Sibling",
        bondSpouse: "Spouse or partner",
        bondChild: "Son or daughter",
        bondFriend: "Friend",
        bondOther: "Loved one",
        selfProfileToggleTitle: "This one is mine",
        selfProfileToggleCaption: "Turn it on for your own wedding or occasion: Kudao uses your name.",
        selfProfileNameCaption: "Taken from your profile. Change it in \u{201C}My profile\u{201D}.",
        selfProfileFallbackName: "Me",
        backAction: "Back",
        filterAllOccasions: "All",
        filterEmptyTitle: "Nothing here",
        filterEmptyMessageFormat: "You have no occasions under \u{201C}%@\u{201D} yet.",
        anniversaryGiftCardTitle: "Anniversary gift",
        experienceCardTitle: "Experience together",
        anniversaryVenueCardTitle: "Where to celebrate",
        toneIntimate: "Intimate",
        toneSober: "Restrained",
        notificationAnniversaryTitle: "Anniversary coming up",
        notificationAnniversaryBodyFormat: "Get ready for %@\u{2019}s anniversary.",
        notificationRemembranceTitle: "Day of remembrance",
        notificationRemembranceBodyFormat: "Today we remember %@.",
        notificationEventTitle: "Occasion coming up",
        notificationEventBodyFormat: "%@\u{2019}s occasion is getting close.",

        accountSignInTitle: "Sign in with email",
        accountSignInCaption: "Optional: get your data back even without the recovery code.",
        accountSignedInCaption: "Account linked to your backup.",
        authSignInTab: "Sign in",
        authSignUpTab: "Sign up",
        authSignInTitle: "Welcome back",
        authSignInSubtitle: "Sign in to bring your celebrations onto this iPhone.",
        authSignUpTitle: "Create your account",
        authSignUpSubtitle: "An email and a password \u{2014} enough to never lose anything again.",
        authEmailPlaceholder: "Your email",
        authPasswordPlaceholder: "Password",
        authPasswordHintFormat: "At least %d characters.",
        authSignInAction: "Sign in",
        authSignUpAction: "Create account",
        authForgotPasswordAction: "Forgot your password?",
        authResetSentMessage: "We sent you an email to reset your password.",
        authOptionalNote: "The account is optional. Kudao works fine without it, and the recovery code still counts.",
        authConfirmTitle: "Confirm your email",
        authConfirmMessageFormat: "We wrote to %@. Open the link in the email, then come back and sign in.",
        authResendAction: "Send the email again",
        authSignedInBadge: "Signed in",
        authVaultLinkedTitle: "Backup linked",
        authVaultLinkedCaption: "Your data comes back by signing in with this email, anywhere.",
        authVaultMissingTitle: "No backup linked",
        authVaultMissingCaption: "Turn the backup on: from then on it belongs to this account.",
        authRestoredFormat: "Recovered %d items from your account.",
        authSignOutAction: "Sign out",
        authSignOutNote: "Signing out keeps everything on this iPhone: only the quick way back disappears.",
        authUnavailableMessage: "This service is not available in this build of the app.",
        authInvalidEmailMessage: "Check the email address.",
        authMissingPasswordMessage: "Enter your password.",
        authWeakPasswordFormat: "The password needs at least %d characters.",
        authWrongCredentialsMessage: "Wrong email or password.",
        authNotConfirmedMessage: "You need to confirm your email first \u{2014} check your inbox.",
        authEmailTakenMessage: "An account already exists with this email. Try signing in.",
        authRateLimitMessage: "Too many attempts. Try again in a few minutes.",
        authOfflineMessage: "You seem offline. Check your connection and try again.",
        authGenericErrorMessage: "Something went wrong. Try again shortly.",

        notificationSettingsMenuTitle: "Notifications",
        notificationSettingsCaption: "Choose how early you want to be told, for every kind of occasion.",
        notificationsActiveLabel: "Notifications are on",
        enableNotificationsAction: "Turn notifications on",
        mainReminderLabel: "Main reminder",
        applyToExistingFormat: "Apply to %d existing profiles",
        appliedToExistingLabel: "Applied",
        resetToShippedAction: "Recommended values",
        noProfilesInCategoryLabel: "No profile of this kind yet.",
        galleryAutoOrderNote: "Sorted automatically: newest memories first.",
        diaryReminderSectionTitle: "Diary reminders",
        diaryReminderToggleTitle: "Diary reminders",
        diaryReminderCaption: "A gentle nudge to note something down, even when the date is far away.",
        diaryFrequencyLabel: "Frequency",
        diaryCadenceDaily: "Daily",
        diaryCadenceEveryThreeDays: "Every 3 days",
        diaryCadenceWeekly: "Weekly",
        diaryCadenceNever: "Never",
        diaryReminderTimeLabel: "Reminder time",
        diaryReminderNextFormat: "Next nudge: %@",
        diaryReminderPeopleFormat: "%d profiles included",
        diaryReminderRemembranceNote: "Remembrances are always left out of these nudges.",
        diaryReminderExcludeTitle: "Exclude from diary reminders",
        diaryReminderExcludeCaption: "This profile will no longer be mentioned in the nudges.",
        diaryReminderOffNote: "Diary reminders are switched off in the notification settings.",
        diaryNudgeTitle: "Kudao diary",
        diaryNudgeVariantOne: "Noticed something about someone special today? Write it in Kudao.",
        diaryNudgeVariantTwo: "A detail, a taste, an idea: note it now, thank yourself later.",
        diaryNudgeVariantThree: "Keep the profiles of the people who matter up to date.",
        diaryNudgePersonFormatOne: "Have you learned anything about %@ lately?",
        diaryNudgePersonFormatTwo: "Two lines about %@: future you will be grateful.",
        diaryNudgePairFormat: "Any news about %@ or %@? One more detail makes them special.",
        quickNoteTitle: "Quick note",
        quickNoteCaption: "Pick the person and write: a few words are enough.",
        quickNoteEmptyMessage: "No profile available for a note yet. Create one and come back.",
        quickNoteSaveAction: "Save",
        gridCategoriesTitle: "Categories",
        gridNextEventTitle: "Next up",
        gridNextEventEmpty: "No date yet",
        gridPendingCountFormat: "%d plans",
        gridPendingEmpty: "All clear",
        gridProfileCountFormat: "%d profiles",
        gridProfileCountOne: "1 profile",
        gridCategoryEmptyHint: "No profile yet, tap to add one",
        gridAnniversaryInFormat: "Anniversary in %d d",
        gridSharedCountFormat: "%d shared profiles",
        sharedListTitle: "Shared with you",
        pendingScopeEmptyMessage: "No party plan is waiting for you. All caught up.",
        sharedScopeEmptyMessage: "You are not planning anything together with others yet.",
        buyOnAmazonAction: "Buy on Amazon",
        affiliateSectionTitle: "Amazon affiliation",
        affiliateCaption: "Every Amazon marketplace needs its own tag: an amazon.it tag earns nothing on amazon.fr. The marketplace follows the app language, or the device one.",
        affiliateTagLabel: "Associates tag",
        affiliateActiveBadge: "In use",
        affiliateFallbackNote: "Without a tag the button still opens Amazon, it just earns no commission.",
        affiliateDisclosure: "As an Amazon Associate, Kudao earns from qualifying purchases, at no extra cost to you",
        linkPreviewTitle: "Link preview",
        linkPreviewBadgeLabel: "See the link before opening it",
        linkPreviewStoreLabel: "Store",
        linkPreviewQueryLabel: "Search",
        linkPreviewNoTag: "No tag for this marketplace",
        linkPreviewNoTagHint: "The link still opens Amazon, it just earns nothing. Add the tag in My profile \u{203A} Amazon affiliation.",
        linkPreviewUrlLabel: "Destination URL",
        linkPreviewOpenAction: "Open in Safari",
        linkPreviewCopyAction: "Copy link",
        linkPreviewCopiedLabel: "Copied",
        linkPreviewGoogleAction: "Search on Google Shopping instead",
        libraryTitle: "Library",
        libraryEmptyTitle: "The library is still empty",
        libraryEmptyMessage: "Once a date goes by, Kudao files it here: that year\u{2019}s plan, message and photos stay forever.",
        libraryProfileEmptyMessage: "The first year lands in the library right after the next date.",
        libraryFilterEmptyMessage: "No archived event matches these filters.",
        libraryAllProfiles: "All profiles",
        libraryCountFormat: "%d archived events",
        libraryYearsCountFormat: "%d years archived",
        libraryPlanSection: "That year\u{2019}s plan",
        libraryNoPlanLabel: "No plan was saved that year",
        librarySentBadge: "Sent",
        libraryNotSentBadge: "Never sent",
        libraryMemoriesSection: "Notes from that year",
        libraryMediaSection: "Photos and videos",
        libraryMediaCountFormat: "%d memories collected",
        libraryNotesCountFormat: "%d notes written that year",
        libraryKeywordsSection: "What we knew back then",
        libraryArchivedOnFormat: "Archived on %@"
    )

    static let french = Strings(
        homeTitle: "Anniversaires",
        homeSubtitle: "Notez toute l'année, fêtez à la perfection.",
        upNext: "Le prochain",
        othersSection: "À venir",
        emptyTitle: "Personne pour l'instant",
        emptyMessage: "Ajoutez les personnes qui comptent et commencez à réunir des idées pour leur anniversaire.",
        emptyAction: "Créer le premier profil",
        searchPlaceholder: "Rechercher un nom",
        searchClear: "Effacer la recherche",
        resultsSection: "Résultats",
        noResultsTitle: "Aucun résultat",
        noResultsMessageFormat: "Aucun profil ne correspond à « %@ ».",
        sortLabel: "Trier",
        sortNearest: "Anniversaire le plus proche",
        sortAlphabetical: "Nom (A-Z)",
        sortRecentlyAdded: "Ajoutés récemment",
        newProfileTitle: "Nouveau profil",
        editProfileTitle: "Modifier le profil",
        nameLabel: "Nom",
        namePlaceholder: "Quel est son nom ?",
        photoLabel: "Photo",
        addPhoto: "Ajouter une photo",
        changePhoto: "Changer la photo",
        removePhoto: "Retirer la photo",
        birthDateLabel: "Date de naissance",
        relationshipLabel: "Relation",
        surpriseTitle: "Mode surprise",
        surpriseDescription: "Le profil reste masqué : il ne sera ni visible ni partageable avec la personne fêtée.",
        surpriseBadge: "Surprise",
        saveAction: "Enregistrer",
        cancelAction: "Annuler",
        deleteAction: "Supprimer",
        createAction: "Créer le profil",
        retryAction: "Réessayer",
        relFriend: "Ami",
        relFamily: "Famille",
        relPartner: "Partenaire",
        relColleague: "Collègue",
        todayTitle: "C'est aujourd'hui !",
        tomorrowLabel: "Demain",
        todayLabel: "Aujourd'hui",
        yesterdayLabel: "Hier",
        dayUnit: "jour",
        daysUnit: "jours",
        daysToGo: "avant l'anniversaire",
        turnsFormat: "Fête ses %d ans",
        turnsTodayFormat: "Fête ses %d ans aujourd'hui",
        nextBirthdayLabel: "Prochain anniversaire",
        imminentBadge: "Cette semaine",
        imminentDaysFormat: "Dans %d jours",
        diaryTab: "Journal",
        preferencesTab: "Préférences",
        suggestionsTab: "Suggestions",
        diaryEmptyTitle: "Journal vide",
        diaryEmptyMessage: "Écrivez la première note : goûts, envies et détails repérés pendant l'année.",
        preferencesEmptyTitle: "Aucune préférence pour l'instant",
        preferencesEmptyMessage: "Les mots-clés sont extraits automatiquement des notes du journal.",
        suggestionsEmptyTitle: "Pas encore de suggestions",
        suggestionsEmptyMessage: "Cadeau, gâteau, lieu et nombre d'invités apparaîtront ici grâce au journal.",
        comingSoon: "Bientôt disponible",
        diaryComposerPlaceholderFormat: "Qu'avez-vous remarqué sur %@ aujourd'hui ?",
        diarySendNote: "Enregistrer la note",
        diaryNotesSection: "Notes",
        diaryNotesCountFormat: "%d notes",
        deleteNoteAction: "Supprimer la note",
        analyzingLabel: "Analyse en cours…",
        analysisFailedLabel: "Mots-clés non extraits",
        giftIdeaBadge: "Idée cadeau",
        giftIdeasSection: "Pistes cadeaux",
        tagsSection: "Mots-clés",
        removeTagHint: "Touchez × pour retirer un mot-clé mal extrait.",
        removeTagAction: "Retirer le mot-clé",
        planTitleFormat: "Plan de fête pour %@",
        suggestionsGeneratingTitle: "Je réfléchis…",
        suggestionsGeneratingMessage: "Je lis les préférences réunies et je prépare le plan.",
        suggestionsNoTagsTitle: "Il faut d'abord une note",
        suggestionsNoTagsMessage: "Écrivez quelques notes : les suggestions viennent des préférences extraites.",
        suggestionsErrorTitle: "Suggestions indisponibles",
        generateAction: "Générer les suggestions",
        regenerateAction: "Régénérer",
        regenerateAllAction: "Tout régénérer",
        giftCardTitle: "Cadeau",
        cakeCardTitle: "Gâteau",
        venueCardTitle: "Lieu",
        guestsCardTitle: "Invités",
        reasonLabel: "Pourquoi",
        priceBandLabel: "Budget",
        priceLow: "Petit budget",
        priceMedium: "Budget moyen",
        priceHigh: "Gros budget",
        confidenceLabel: "Confiance",
        confidenceLow: "faible",
        confidenceMedium: "moyenne",
        confidenceHigh: "élevée",
        lowConfidenceBanner: "Écrivez plus de notes pour des suggestions plus précises.",
        confirmAllAction: "Tout confirmer",
        confirmedAtFormat: "Plan confirmé le %@",
        unconfirmedChanges: "Modifications à confirmer",
        editSuggestionTitle: "Modifier la suggestion",
        editedBadge: "Modifié",
        guestsUnitFormat: "%d personnes",
        basedOnTagsFormat: "Basé sur %d mots-clés",
        doneAction: "Terminé",
        catFood: "Cuisine",
        catTravel: "Voyages",
        catShopping: "Shopping",
        catHobby: "Loisirs",
        catPlaces: "Lieux",
        catOther: "Autre",
        profileSettings: "Réglages du profil",
        editData: "Modifier les infos",
        deleteProfile: "Supprimer le profil",
        deleteConfirmTitle: "Supprimer ce profil ?",
        deleteConfirmMessageFormat: "Le profil de %@ et toutes les notes du journal seront supprimés.",
        languageLabel: "Langue",
        profilesCountFormat: "%d profils",
        ageNowFormat: "%d ans",
        remindersMenuTitle: "Rappels et notifications",
        remindersSectionTitle: "Rappels",
        reminderToggleTitle: "Rappel d'anniversaire",
        reminderToggleDescription: "Une alerte locale quand l'anniversaire approche, avec les suggestions prêtes.",
        reminderDaysTitle: "Me rappeler",
        dayBeforeFormat: "%d jour avant",
        daysBeforeFormat: "%d jours avant",
        giftReminderToggleTitle: "Rappel cadeau séparé",
        giftReminderDescription: "Une alerte supplémentaire, avant le rappel d'anniversaire, pour acheter le cadeau à temps.",
        giftReminderDaysTitle: "Rappel cadeau",
        reminderScheduledFormat: "Prochaine alerte : %@",
        reminderDisabledLabel: "Aucun rappel programmé",
        notificationsDeniedTitle: "Notifications désactivées",
        notificationsDeniedMessage: "Activez les notifications de Kudao dans les réglages iOS pour recevoir les rappels.",
        openSettingsAction: "Ouvrir les Réglages",
        notificationBirthdayTitle: "Anniversaire imminent",
        notificationBirthdayBodyFormat: "L'anniversaire de %@ approche ! Consultez les suggestions sur Kudao",
        notificationGiftTitle: "Rappel cadeau",
        notificationGiftBodyFormat: "N'oubliez pas le cadeau de %@ : %@",
        notificationGiftBodyFallbackFormat: "N'oubliez pas le cadeau de %@. Ouvrez Kudao pour choisir une idée.",
        exportSectionTitle: "Exporter le journal",
        exportSectionDescription: "Enregistrez les notes et mots-clés de ce profil dans un fichier à partager ou archiver.",
        exportPDFAction: "Exporter en PDF",
        exportJSONAction: "Exporter en JSON",
        exportPreparing: "Préparation du fichier…",
        exportFailedTitle: "Export impossible",
        exportFailedMessage: "Le fichier n'a pas pu être créé. Réessayez.",
        exportDocumentTitleFormat: "Journal de %@",
        exportGeneratedAtFormat: "Exporté le %@",
        exportProfileSection: "Profil",
        exportPlanSection: "Plan de fête",
        exportNotesSection: "Notes du journal",
        exportNoNotes: "Aucune note dans le journal.",
        exportNoPlan: "Aucun plan de fête enregistré.",
        reviewBannerTitle: "À confirmer",
        reviewBannerSubtitleFormat: "%d plans de fête attendent votre validation",
        planReviewTitle: "Tout est prêt ?",
        planReviewSubtitleFormat: "L'anniversaire de %@ est dans %d jours. Confirmez le plan ou modifiez-le.",
        planReviewTodayFormat: "C'est aujourd'hui l'anniversaire de %@. Confirmez le plan ou modifiez-le.",
        planReviewNoPlanTitle: "Pas encore de plan",
        planReviewNoPlanMessage: "Ouvrez les suggestions pour créer le plan de fête de ce profil.",
        confirmAction: "Confirmer",
        modifyAction: "Modifier",
        pendingBadgeLabel: "Plan à confirmer",
        appSettingsMenu: "Réglages de l’app",
        settingsTitle: "Réglages",
        settingsLanguageSection: "Langue",
        settingsSurpriseSection: "Mode surprise",
        settingsSurpriseFooter: "Ces protections s’appliquent à tous les profils en mode surprise.",
        faceIDToggleTitle: "Protéger les profils surprise avec Face ID",
        faceIDToggleDescription: "Demande Face ID, Touch ID ou le code de l’appareil avant d’ouvrir un profil surprise.",
        hidePreviewsToggleTitle: "Masquer l’aperçu des notifications des profils surprise",
        hidePreviewsToggleDescription: "Les notifications affichent seulement « Rappel Kudao », jamais le nom de la personne.",
        biometryUnavailableNote: "Aucune biométrie configurée : le code de l’appareil sera demandé.",
        unlockReasonFormat: "Déverrouiller le profil de %@",
        unlockAction: "Déverrouiller",
        unlockFailedTitle: "Déverrouillage échoué",
        unlockFailedMessage: "Nous n’avons pas pu vérifier votre identité. Veuillez réessayer.",
        lockedBadgeLabel: "Profil protégé",
        notificationGenericTitle: "Rappel Kudao",
        notificationGenericBody: "Ouvrez Kudao pour voir le rappel.",
        maskedProfileName: "Surprise",
        settingsWidgetSection: "Widget",
        settingsWidgetHint: "Appuyez longuement sur l’écran d’accueil, touchez Modifier, puis Ajouter un widget et choisissez Kudao.",
        settingsSharingNote: "Les profils surprise resteront exclus de tout partage avec la personne fêtée.",
        lastNameLabel: "Nom",
        lastNamePlaceholder: "Nom (facultatif)",
        noLastNameLabel: "Nom non renseign\u{00E9}",
        addressLabel: "Adresse",
        addressPlaceholder: "Rue, ville (facultatif)",
        phoneLabel: "T\u{00E9}l\u{00E9}phone",
        phonePlaceholder: "Num\u{00E9}ro de t\u{00E9}l\u{00E9}phone (facultatif)",
        emailLabel: "E-mail",
        emailPlaceholder: "Adresse e-mail (facultatif)",
        contactsSectionTitle: "Contact",
        birthLabel: "Naissance",
        ageLabel: "\u{00C2}ge",
        ageYearsFormat: "%d ans",
        notificationActiveLabel: "Rappel activ\u{00E9}",
        notificationOffLabel: "Rappel d\u{00E9}sactiv\u{00E9}",
        daysBeforeShortLabel: "jours avant :",
        hourShortLabel: "heure :",
        editAction: "Modifier",
        sendWishesAction: "Envoyer les v\u{0153}ux",
        messageTab: "Message",
        messageSectionTitle: "Message d'anniversaire",
        messageGeneratingTitle: "J'\u{00E9}cris les v\u{0153}ux\u{2026}",
        messageGeneratingMessage: "J'utilise vos notes du journal pour un message vraiment personnel.",
        messageEmptyTitle: "Aucun message",
        messageEmptyMessage: "G\u{00E9}n\u{00E9}rez un message d'anniversaire personnel \u{00E0} partir des mots-cl\u{00E9}s du journal.",
        messageToneLabel: "Ton",
        toneWarm: "Affectueux",
        toneFunny: "Amusant",
        toneElegant: "\u{00C9}l\u{00E9}gant",
        messageRegenerateAction: "R\u{00E9}g\u{00E9}n\u{00E9}rer",
        messageCopyAction: "Copier",
        messageCopiedLabel: "Copi\u{00E9}",
        messageShareAction: "Partager",
        messageSMSAction: "Messages",
        messageEmailAction: "E-mail",
        messageEmailSubjectFormat: "Joyeux anniversaire %@ !",
        messageBasedOnNote: "\u{00C9}crit \u{00E0} partir des mots-cl\u{00E9}s du journal",
        buyOnlineAction: "Acheter en ligne",
        findStoreAction: "Trouver une boutique pr\u{00E8}s de vous",
        noPlanAlertTitle: "Aucune id\u{00E9}e cadeau",
        noPlanAlertMessage: "G\u{00E9}n\u{00E9}rez d'abord les suggestions dans l'onglet Suggestions.",
        giftFromPlanFormat: "Id\u{00E9}e cadeau : %@",
        storesTitle: "Boutiques proches",
        storesSearchingLabel: "Je cherche des boutiques\u{2026}",
        storesEmptyTitle: "Aucune boutique trouv\u{00E9}e",
        storesEmptyMessage: "Il n'y a pas de boutique de ce type dans un rayon de 5 km.",
        storesPermissionTitle: "Localisation requise",
        storesPermissionMessage: "Kudao utilise votre position uniquement pour chercher des boutiques proches.",
        storesPermissionAction: "Autoriser la position",
        storesDeniedTitle: "Position indisponible",
        storesDeniedMessage: "Activez les services de localisation pour Kudao dans R\u{00E9}glages.",
        storesFailedTitle: "Recherche \u{00E9}chou\u{00E9}e",
        storesFailedMessage: "Impossible de chercher des boutiques maintenant. R\u{00E9}essayez bient\u{00F4}t.",
        storesRadiusNote: "Dans un rayon de 5 km",
        storesSearchingCategoryFormat: "Recherche : %@",
        openInMapsAction: "Ouvrir dans Plans",
        distanceKmFormat: "%.1f km",
        distanceMetersFormat: "%d m",
        shareProfileAction: "Partager le profil",
        shareProfileTitle: "Partager le profil",
        shareProfileSubtitleFormat: "Invitez quelqu'un \u{00E0} organiser l'anniversaire de %@ avec vous.",
        permissionSectionTitle: "Ce qu'il pourra faire",
        permissionViewTitle: "Lecture seule",
        permissionViewCaption: "Voit le profil, le journal et les suggestions sans les modifier.",
        permissionEditTitle: "Peut collaborer",
        permissionEditCaption: "Ajoute des notes au journal et vote pour les suggestions.",
        generateInviteAction: "G\u{00E9}n\u{00E9}rer un code d'invitation",
        inviteReadyTitle: "Invitation pr\u{00EA}te",
        inviteCodeLabel: "Code d'invitation",
        inviteHint: "La personne ouvre Kudao, touche l'ic\u{00F4}ne des r\u{00E9}glages et choisit \u{00AB} Rejoindre un profil \u{00BB}.",
        copyCodeAction: "Copier le code",
        copiedLabel: "Copi\u{00E9}",
        shareInviteAction: "Partager l'invitation",
        newInviteAction: "G\u{00E9}n\u{00E9}rer un autre code",
        discardInviteAction: "Annuler l'invitation",
        inviteMessageFormat: "Organisons ensemble l'anniversaire de %@ sur Kudao ! Ouvre l'app, va dans R\u{00E9}glages \u{2192} Rejoindre un profil et saisis le code : %@",
        shareBlockedSurpriseTitle: "Profil surprise prot\u{00E9}g\u{00E9}",
        shareBlockedSurpriseMessage: "D\u{00E9}sactivez la protection surprise dans les r\u{00E9}glages pour partager ce profil.",
        yourNameLabel: "Votre nom",
        yourNamePlaceholder: "Comment vous appelez-vous",
        yourNameCaption: "Il permet aux autres participants de reconna\u{00EE}tre vos notes.",
        participantsTitle: "Participants",
        participantsMenuTitle: "Participants",
        participantsCountFormat: "%d participants",
        participantOwnerBadge: "Propri\u{00E9}taire",
        participantYou: "Vous",
        participantUnknown: "Participant",
        participantPendingTitle: "Invitations en attente",
        removeParticipantAction: "Retirer",
        removeParticipantConfirmFormat: "%@ perdra l'acc\u{00E8}s \u{00E0} ce profil. Les notes d\u{00E9}j\u{00E0} \u{00E9}crites restent dans le journal.",
        ownerCannotBeRemoved: "Le propri\u{00E9}taire ne peut pas \u{00EA}tre retir\u{00E9} : supprimez le profil pour mettre fin au partage.",
        guestLeaveHint: "Seul le propri\u{00E9}taire du profil g\u{00E8}re les acc\u{00E8}s.",
        participantsEmptyTitle: "Aucun participant",
        participantsEmptyMessage: "Partagez le profil pour organiser la f\u{00EA}te avec quelqu'un d'autre.",
        joinedAtFormat: "Depuis le %@",
        joinShareMenuTitle: "Rejoindre un profil",
        joinShareTitle: "Rejoindre un profil",
        joinShareSubtitle: "Saisissez le code d'invitation re\u{00E7}u.",
        joinCodePlaceholder: "CODE",
        joinAction: "Rejoindre",
        pasteCodeAction: "Coller depuis le presse-papiers",
        joinSuccessFormat: "Vous participez \u{00E0} l'anniversaire de %@",
        joinSuccessCaption: "Le profil appara\u{00EE}t dans votre liste, avec les notes et suggestions partag\u{00E9}es.",
        sharedProfileFallbackName: "Profil partag\u{00E9}",
        shareErrorGeneric: "Une erreur est survenue. R\u{00E9}essayez.",
        shareErrorInvalidCode: "Code invalide. V\u{00E9}rifiez-le et r\u{00E9}essayez.",
        shareErrorCodeUsed: "Ce code a d\u{00E9}j\u{00E0} \u{00E9}t\u{00E9} utilis\u{00E9} par quelqu'un d'autre.",
        shareErrorOwnProfile: "Ce profil est d\u{00E9}j\u{00E0} le v\u{00F4}tre.",
        shareErrorNoAccess: "Vous n'avez plus acc\u{00E8}s \u{00E0} ce profil partag\u{00E9}.",
        shareErrorReadOnly: "Vous avez un acc\u{00E8}s en lecture seule \u{00E0} ce profil.",
        shareErrorNotOwner: "Seul le propri\u{00E9}taire du profil peut le faire.",
        shareErrorOffline: "Aucune connexion. R\u{00E9}essayez une fois en ligne.",
        sharedBadge: "Partag\u{00E9}",
        sharedByFormat: "Partag\u{00E9} par %@",
        readOnlyBadge: "Lecture seule",
        readOnlyDiaryMessage: "Acc\u{00E8}s en lecture seule : vous pouvez lire les notes mais pas en ajouter.",
        readOnlyPlanMessage: "Le plan est g\u{00E9}r\u{00E9} par le propri\u{00E9}taire du profil.",
        voteUpLabel: "J'adore",
        voteDownLabel: "Pas convaincu",
        voteTallyFormat: "%1$d pour \u{00B7} %2$d contre",
        votesEmptyLabel: "Aucun vote pour l'instant",
        syncingLabel: "Actualisation\u{2026}",
        collaborationSectionTitle: "Partage",
        collaborationHubTitle: "\u{00C0} plusieurs",
        collaborationHubCountFormat: "%d profils partag\u{00E9}s",
        collaborationInviteTitle: "Organisez \u{00E0} plusieurs",
        collaborationInviteMessage: "Invitez qui vous voulez dans un profil, ou rejoignez avec un code.",
        inviteSomeoneAction: "Inviter quelqu\u{2019}un",
        pendingInvitesCountFormat: "%d invitations en attente",
        collaborationOnlyYou: "Vous seul, pour l\u{2019}instant",
        ageBracketLabel: "Tranche d\u{2019}\u{00E2}ge",
        ageBracketChild: "Enfant",
        ageBracketTeen: "Adolescent",
        ageBracketAdult: "Adulte",
        ageBracketSenior: "Senior",
        favoriteCharacterLabel: "Dessin anim\u{00E9} ou personnage pr\u{00E9}f\u{00E9}r\u{00E9}",
        favoriteCharacterPlaceholder: "Ex. Bluey, Spider-Man, La Reine des neiges",
        favoriteCharacterCaption: "Facultatif : aide \u{00E0} choisir un g\u{00E2}teau et un cadeau \u{00E0} th\u{00E8}me.",
        messageGenerateAction: "G\u{00E9}n\u{00E9}rer le message",
        messageWriteMyselfAction: "L\u{2019}\u{00E9}crire moi-m\u{00EA}me",
        messagePlaceholder: "\u{00C9}crivez vos v\u{0153}ux ici\u{2026}",
        messageEditorHint: "Modifiez le texte comme vous voulez : nous l\u{2019}envoyons tel quel.",
        messageSentBadge: "Envoy\u{00E9}",
        messageScheduleTitle: "Programmation de l\u{2019}envoi",
        messageScheduleToggle: "Me rappeler de l\u{2019}envoyer",
        messageSendDateLabel: "Envoyer le",
        messageScheduleReadyFormat: "Rappel le %@",
        messagePastDateLabel: "Choisissez une date future pour recevoir le rappel.",
        messageAlreadySentLabel: "Message d\u{00E9}j\u{00E0} envoy\u{00E9}.",
        messageMarkSentShortAction: "Marquer comme envoy\u{00E9}",
        messageMarkSentAction: "Oui, je l\u{2019}ai envoy\u{00E9}",
        messageMarkUnsentAction: "Marquer comme \u{00E0} envoyer",
        messageNotYetAction: "Pas encore",
        messageSentConfirmTitle: "Avez-vous envoy\u{00E9} vos v\u{0153}ux ?",
        messageSentConfirmMessage: "Si vous confirmez, nous ne vous rappellerons plus ce message.",
        messageContactTitle: "Contact du destinataire",
        messageContactCaption: "Sert \u{00E0} ouvrir WhatsApp ou Messages avec le texte pr\u{00EA}t.",
        messageNoContactLabel: "Aucun contact enregistr\u{00E9}",
        messageNeedsPhoneHint: "Ajoutez un num\u{00E9}ro pour ouvrir la conversation pr\u{00E9}remplie.",
        messageWhatsAppAction: "Ouvrir WhatsApp",
        messageMessagesAction: "Ouvrir Messages",
        messageOpenFailedTitle: "Application indisponible",
        messageOpenFailedMessage: "Impossible d\u{2019}ouvrir cette application sur cet appareil. Le texte a \u{00E9}t\u{00E9} copi\u{00E9}.",
        notificationMessageTitle: "V\u{0153}ux \u{00E0} envoyer",
        notificationMessageBodyFormat: "C\u{2019}est le moment de souhaiter un joyeux anniversaire \u{00E0} %@ !",
        messageAutoRefreshToggle: "Mettre \u{00E0} jour avec les nouvelles notes",
        messageAutoRefreshCaption: "Quand tu ajoutes des notes ou des mots-cl\u{00E9}s au journal, nous r\u{00E9}\u{00E9}crivons le brouillon des v\u{0153}ux.",
        messageAutoRefreshPausedLabel: "Tu as modifi\u{00E9} le texte toi-m\u{00EA}me : la mise \u{00E0} jour automatique est en pause.",
        messageAutoRefreshResumeAction: "Reprendre",
        messageAutoRefreshedFormat: "Mis \u{00E0} jour avec tes derni\u{00E8}res notes \u{00B7} %@",
        galleryTab: "Galerie",
        gallerySectionTitle: "Souvenirs de la f\u{00EA}te",
        galleryCountFormat: "%d souvenirs",
        galleryAddAction: "Ajouter des souvenirs",
        galleryFromLibraryAction: "Choisir dans la biblioth\u{00E8}que",
        galleryCaptureAction: "Photo ou vid\u{00E9}o",
        galleryEmptyTitle: "Aucun souvenir pour l\u{2019}instant",
        galleryEmptyMessage: "Ajoute les photos et vid\u{00E9}os de la f\u{00EA}te : toutes les personnes ayant acc\u{00E8}s au profil les verront.",
        galleryLockedTitle: "Disponible le jour de la f\u{00EA}te",
        galleryLockedMessageFormat: "La galerie partag\u{00E9}e s\u{2019}ouvre le %@, pour rassembler tout de suite les photos et vid\u{00E9}os de l\u{2019}anniversaire.",
        galleryUploadingTitle: "Envoi en cours\u{2026}",
        galleryUploadingCountFormat: "%d en attente",
        galleryDeleteAction: "Supprimer le souvenir",
        galleryDeleteConfirmTitle: "Supprimer ce souvenir ?",
        galleryDeleteConfirmMessage: "La photo ou la vid\u{00E9}o dispara\u{00EE}tra aussi pour les autres participants.",
        galleryPrivacyNote: "Seules les personnes ayant acc\u{00E8}s au profil voient et ajoutent ces souvenirs.",
        galleryLoadingLabel: "Chargement\u{2026}",
        galleryMediaUnavailable: "Contenu indisponible hors ligne. R\u{00E9}essaie une fois reconnect\u{00E9}.",
        galleryTooLargeMessage: "Le fichier est trop lourd : essaie une vid\u{00E9}o plus courte (25 Mo max).",
        galleryPrepareFailedMessage: "Impossible de pr\u{00E9}parer ce contenu. Essaie un autre fichier.",
        galleryRetryUnavailable: "Le fichier d\u{2019}origine n\u{2019}est plus disponible : envoie-le \u{00E0} nouveau.",
        cloudSectionTitle: "Sauvegarde et restauration",
        cloudSectionCaption: "Garde profils, journal, plans et messages en s\u{00E9}curit\u{00E9}.",
        cloudManageTitle: "Sauvegarde",
        cloudOnLabel: "Sauvegarde activ\u{00E9}e",
        cloudOffLabel: "Sauvegarde d\u{00E9}sactiv\u{00E9}e",
        cloudOffCaption: "Pour l\u{2019}instant tes donn\u{00E9}es vivent seulement sur cet iPhone.",
        cloudNeverSynced: "Aucune sauvegarde effectu\u{00E9}e pour le moment.",
        cloudLastSyncFormat: "Derni\u{00E8}re sauvegarde : %@",
        cloudEnableTitle: "Activer la sauvegarde",
        cloudEnableCaption: "Kudao conserve une copie de tes profils, notes du journal, plans de f\u{00EA}te et messages. Tu re\u{00E7}ois un code de restauration pour tout retrouver sur un autre iPhone.",
        cloudEnableAction: "Activer la sauvegarde",
        cloudCodeLabel: "Ton code de restauration",
        cloudCodeCaption: "Garde-le en lieu s\u{00FB}r : c\u{2019}est la seule cl\u{00E9} vers tes donn\u{00E9}es. Qui poss\u{00E8}de le code peut les restaurer.",
        cloudCopyAction: "Copier le code",
        cloudCopiedLabel: "Code copi\u{00E9}",
        cloudActionsTitle: "G\u{00E9}rer",
        cloudSyncNowAction: "Sauvegarder maintenant",
        cloudDisableAction: "D\u{00E9}sactiver la sauvegarde",
        cloudDeleteRemoteAction: "D\u{00E9}sactiver et supprimer la copie",
        cloudDisableTitle: "D\u{00E9}sactiver la sauvegarde ?",
        cloudDisableMessage: "Tes donn\u{00E9}es restent sur cet iPhone. Tu peux aussi supprimer compl\u{00E8}tement la copie enregistr\u{00E9}e.",
        cloudRestoreTitle: "Restaurer sur cet iPhone",
        cloudRestoreHint: "Tu as d\u{00E9}j\u{00E0} une sauvegarde ? Saisis le code de restauration pour tout r\u{00E9}cup\u{00E9}rer.",
        cloudRestorePlaceholder: "CODE",
        cloudRestoreAction: "Restaurer",
        cloudRestoredFormat: "%d \u{00E9}l\u{00E9}ments restaur\u{00E9}s",
        cloudBackedUpBanner: "Tout est sauvegard\u{00E9}",
        cloudPrivacyNote: "Kudao ne demande ni e-mail ni mot de passe : la copie est li\u{00E9}e uniquement \u{00E0} ton code de restauration, conserv\u{00E9} dans le trousseau iOS. Les profils partag\u{00E9}s par d\u{2019}autres ne sont pas sauvegard\u{00E9}s ici.",
        cloudUnavailableMessage: "La sauvegarde n\u{2019}est pas disponible dans cette version de l\u{2019}app.",
        cloudInvalidCodeMessage: "Code incomplet : v\u{00E9}rifie-le et r\u{00E9}essaie.",
        cloudUnknownCodeMessage: "Aucune sauvegarde trouv\u{00E9}e pour ce code.",
        cloudGenericErrorMessage: "Impossible de joindre la sauvegarde : v\u{00E9}rifie ta connexion et r\u{00E9}essaie.",
        gallerySortLabel: "Ordre",
        gallerySortNewest: "Les plus r\u{00E9}cents d\u{2019}abord",
        gallerySortOldest: "Les plus anciens d\u{2019}abord",
        myProfileTitle: "Mon profil",
        myProfileSubtitle: "La photo et le nom que voient les personnes avec qui tu partages un anniversaire.",
        notificationDefaultsTitle: "R\u{00E9}glages des notifications",
        notificationDefaultsCaption: "Utilis\u{00E9}s pour chaque nouvel anniversaire. Tu peux toujours les changer profil par profil.",
        defaultReminderDaysLabel: "Rappel anniversaire",
        defaultGiftDaysLabel: "Rappel cadeau",
        defaultReminderTimeLabel: "Heure",
        defaultsAppliedNote: "L\u{2019}heure s\u{2019}applique \u{00E0} tous les rappels d\u{00E9}j\u{00E0} programm\u{00E9}s.",
        privacySectionTitle: "Confidentialit\u{00E9}",
        privacyMovedCaption: "Face ID et aper\u{00E7}us discrets se g\u{00E8}rent dans Mon profil.",
        accountSectionTitle: "Compte",
        accountNoLoginTitle: "Aucune connexion requise",
        accountNoLoginCaption: "Kudao fonctionne sans e-mail ni mot de passe : tes donn\u{00E9}es restent sur cet iPhone.",
        accountVaultCaption: "R\u{00E9}cup\u{00E9}rable avec ton code de restauration.",
        accountSignOutAction: "Se d\u{00E9}connecter de la sauvegarde",
        accountSignOutTitle: "Se d\u{00E9}connecter de la sauvegarde ?",
        accountSignOutMessage: "Cet iPhone cesse d\u{2019}enregistrer dans le cloud. Tes donn\u{00E9}es restent ici et la copie enregistr\u{00E9}e n\u{2019}est pas touch\u{00E9}e : tu peux revenir avec ton code de restauration.",
        appInfoTitle: "\u{00C0} propos",
        appVersionLabel: "Version",
        appSupportAction: "Contacter le support",
        appSupportCaption: "Nous r\u{00E9}pondons g\u{00E9}n\u{00E9}ralement sous deux jours ouvr\u{00E9}s.",
        galleryPreparingTitle: "Pr\u{00E9}paration des souvenirs\u{2026}",
        galleryUploadAction: "Envoyer les souvenirs",
        galleryCaptionSheetTitle: "Nouveaux souvenirs",
        galleryCaptionSheetMessage: "Ajoute une l\u{00E9}g\u{00E8}re description \u{00E0} chaque souvenir. Tu peux aussi la laisser vide.",
        galleryCaptionPlaceholder: "\u{00C9}cris une l\u{00E9}gende\u{2026}",
        galleryCaptionAddAction: "Ajouter une l\u{00E9}gende",
        galleryCaptionEditAction: "Modifier la l\u{00E9}gende",
        galleryCaptionEditorTitle: "L\u{00E9}gende",
        photoSourceCameraAction: "Prendre une photo",
        photoSourceLibraryAction: "Choisir dans la biblioth\u{00E8}que",
        photoCropTitle: "Cadrer la photo",
        photoCropHint: "Fais glisser pour d\u{00E9}placer, pince pour zoomer.",
        photoUseAction: "Utiliser cette photo",
        cameraDeniedTitle: "Appareil photo indisponible",
        cameraDeniedMessage: "Kudao n\u{2019}a pas l\u{2019}autorisation d\u{2019}utiliser l\u{2019}appareil photo. Active-la dans les R\u{00E9}glages iOS pour prendre une photo.",
        libraryDeniedTitle: "Photos indisponibles",
        libraryDeniedMessage: "Kudao n\u{2019}a pas acc\u{00E8}s \u{00E0} tes photos. Active l\u{2019}autorisation dans les R\u{00E9}glages iOS pour en choisir une.",
        notificationGalleryTitle: "Souvenirs de la f\u{00EA}te",
        notificationGalleryBodyFormat: "Ajoute tes souvenirs de la f\u{00EA}te de %@ sur Kudao !",

        occasionBirthday: "Anniversaire",
        occasionWedding: "Mariage",
        occasionRemembrance: "Comm\u{00E9}moration",
        occasionOther: "Autre",
        occasionBirthdayCaption: "Cadeau, g\u{00E2}teau, invit\u{00E9}s et v\u{0153}ux pour la personne f\u{00EA}t\u{00E9}e.",
        occasionWeddingCaption: "Anniversaire de mariage : un cadeau et une exp\u{00E9}rience \u{00E0} deux.",
        occasionRemembranceCaption: "Garder la m\u{00E9}moire d\u{2019}une personne qui n\u{2019}est plus l\u{00E0}.",
        occasionOtherCaption: "Une occasion libre, \u{00E0} ta fa\u{00E7}on.",
        occasionBirthdayPlural: "Anniversaires",
        occasionWeddingPlural: "Mariages",
        occasionRemembrancePlural: "Comm\u{00E9}morations",
        occasionOtherPlural: "Autre",
        occasionStepTitle: "Quel type d\u{2019}occasion ?",
        occasionStepSubtitle: "Kudao adapte les questions, les id\u{00E9}es et les rappels \u{00E0} ton choix.",
        weddingDateLabel: "Date du mariage",
        passingDateLabel: "Date du d\u{00E9}c\u{00E8}s",
        eventDateLabel: "Date de l\u{2019}\u{00E9}v\u{00E9}nement",
        weddingDateHint: "Le jour du mariage : l\u{2019}anniversaire se compte \u{00E0} partir de l\u{00E0}.",
        passingDateHint: "Le jour \u{00E0} se rappeler chaque ann\u{00E9}e.",
        eventDateHint: "La date qui revient chaque ann\u{00E9}e.",
        weddingStatLabel: "Mariage",
        passingStatLabel: "D\u{00E9}part",
        eventStatLabel: "Date",
        yearsTogetherLabel: "Ann\u{00E9}es ensemble",
        yearsSinceLabel: "Il y a",
        yearsElapsedLabel: "Ann\u{00E9}es",
        daysToAnniversary: "avant l\u{2019}anniversaire",
        daysToRemembrance: "avant la date",
        daysToEvent: "avant l\u{2019}\u{00E9}v\u{00E9}nement",
        todayAnniversaryTitle: "C\u{2019}est l\u{2019}anniversaire aujourd\u{2019}hui !",
        todayRemembranceTitle: "Aujourd\u{2019}hui est le jour du souvenir",
        todayEventTitle: "C\u{2019}est aujourd\u{2019}hui !",
        anniversaryYearsFormat: "%d ans ensemble",
        yearsAgoFormat: "Il y a %d ans",
        editionYearsFormat: "%de ann\u{00E9}e",
        sendAnniversaryWishesAction: "Envoyer les v\u{0153}ux",
        writeThoughtAction: "\u{00C9}crire une pens\u{00E9}e",
        sendEventWishesAction: "\u{00C9}crire un message",
        memoriesTab: "Souvenirs",
        thoughtTab: "Pens\u{00E9}e",
        traitsTab: "Traits",
        reminderOnTheDayLabel: "Le jour m\u{00EA}me",
        rememberedNamePlaceholder: "Son pr\u{00E9}nom",
        bondLabel: "Lien",
        bondCaption: "Cela sert seulement \u{00E0} donner le bon ton aux textes que Kudao pr\u{00E9}pare.",
        bondParent: "Parent",
        bondGrandparent: "Grand-parent",
        bondSibling: "Fr\u{00E8}re ou s\u{0153}ur",
        bondSpouse: "Conjoint ou compagnon",
        bondChild: "Fils ou fille",
        bondFriend: "Ami",
        bondOther: "Proche",
        selfProfileToggleTitle: "C\u{2019}est mon occasion",
        selfProfileToggleCaption: "Active-le pour ton propre mariage ou ta propre date : Kudao utilise ton nom.",
        selfProfileNameCaption: "Repris de ton profil. Modifie-le dans \u{00AB} Mon profil \u{00BB}.",
        selfProfileFallbackName: "Moi",
        backAction: "Retour",
        filterAllOccasions: "Tout",
        filterEmptyTitle: "Rien ici",
        filterEmptyMessageFormat: "Tu n\u{2019}as encore aucune occasion dans \u{00AB} %@ \u{00BB}.",
        anniversaryGiftCardTitle: "Cadeau d\u{2019}anniversaire",
        experienceCardTitle: "Exp\u{00E9}rience \u{00E0} deux",
        anniversaryVenueCardTitle: "O\u{00F9} f\u{00EA}ter",
        toneIntimate: "Intime",
        toneSober: "Sobre",
        notificationAnniversaryTitle: "Anniversaire de mariage",
        notificationAnniversaryBodyFormat: "Pr\u{00E9}pare-toi pour l\u{2019}anniversaire de %@.",
        notificationRemembranceTitle: "Jour du souvenir",
        notificationRemembranceBodyFormat: "Aujourd\u{2019}hui, nous nous souvenons de %@.",
        notificationEventTitle: "Occasion \u{00E0} venir",
        notificationEventBodyFormat: "L\u{2019}occasion de %@ approche.",

        accountSignInTitle: "Se connecter par e-mail",
        accountSignInCaption: "Facultatif : retrouve tes donn\u{00E9}es m\u{00EA}me sans le code de r\u{00E9}cup\u{00E9}ration.",
        accountSignedInCaption: "Compte reli\u{00E9} \u{00E0} ta sauvegarde.",
        authSignInTab: "Connexion",
        authSignUpTab: "Inscription",
        authSignInTitle: "Content de te revoir",
        authSignInSubtitle: "Connecte-toi pour retrouver tes profils sur cet iPhone.",
        authSignUpTitle: "Cr\u{00E9}e ton compte",
        authSignUpSubtitle: "Un e-mail et un mot de passe : de quoi ne plus rien perdre.",
        authEmailPlaceholder: "Ton e-mail",
        authPasswordPlaceholder: "Mot de passe",
        authPasswordHintFormat: "Au moins %d caract\u{00E8}res.",
        authSignInAction: "Se connecter",
        authSignUpAction: "Cr\u{00E9}er le compte",
        authForgotPasswordAction: "Mot de passe oubli\u{00E9} ?",
        authResetSentMessage: "Nous t\u{2019}avons envoy\u{00E9} un e-mail pour r\u{00E9}initialiser ton mot de passe.",
        authOptionalNote: "Le compte est facultatif. Kudao fonctionne tr\u{00E8}s bien sans, et le code de r\u{00E9}cup\u{00E9}ration reste valable.",
        authConfirmTitle: "Confirme ton e-mail",
        authConfirmMessageFormat: "Nous avons \u{00E9}crit \u{00E0} %@. Ouvre le lien dans l\u{2019}e-mail, puis reviens ici pour te connecter.",
        authResendAction: "Renvoyer l\u{2019}e-mail",
        authSignedInBadge: "Connect\u{00E9}",
        authVaultLinkedTitle: "Sauvegarde reli\u{00E9}e",
        authVaultLinkedCaption: "Tes donn\u{00E9}es reviennent en te connectant avec cet e-mail, partout.",
        authVaultMissingTitle: "Aucune sauvegarde reli\u{00E9}e",
        authVaultMissingCaption: "Active la sauvegarde : elle appartiendra alors \u{00E0} ce compte.",
        authRestoredFormat: "%d \u{00E9}l\u{00E9}ments r\u{00E9}cup\u{00E9}r\u{00E9}s depuis ton compte.",
        authSignOutAction: "Se d\u{00E9}connecter",
        authSignOutNote: "En te d\u{00E9}connectant, tout reste sur cet iPhone : seul l\u{2019}acc\u{00E8}s rapide dispara\u{00EE}t.",
        authUnavailableMessage: "Ce service n\u{2019}est pas disponible dans cette version de l\u{2019}app.",
        authInvalidEmailMessage: "V\u{00E9}rifie l\u{2019}adresse e-mail.",
        authMissingPasswordMessage: "Saisis ton mot de passe.",
        authWeakPasswordFormat: "Le mot de passe doit faire au moins %d caract\u{00E8}res.",
        authWrongCredentialsMessage: "E-mail ou mot de passe incorrect.",
        authNotConfirmedMessage: "Tu dois d\u{2019}abord confirmer ton e-mail : regarde ta bo\u{00EE}te de r\u{00E9}ception.",
        authEmailTakenMessage: "Un compte existe d\u{00E9}j\u{00E0} avec cet e-mail. Essaie de te connecter.",
        authRateLimitMessage: "Trop de tentatives. R\u{00E9}essaie dans quelques minutes.",
        authOfflineMessage: "Tu sembles hors ligne. V\u{00E9}rifie ta connexion et r\u{00E9}essaie.",
        authGenericErrorMessage: "Un probl\u{00E8}me est survenu. R\u{00E9}essaie dans un instant.",

        notificationSettingsMenuTitle: "Notifications",
        notificationSettingsCaption: "Choisis combien de temps \u{00E0} l\u{2019}avance tu veux \u{00EA}tre pr\u{00E9}venu, pour chaque type d\u{2019}occasion.",
        notificationsActiveLabel: "Notifications activ\u{00E9}es",
        enableNotificationsAction: "Activer les notifications",
        mainReminderLabel: "Rappel principal",
        applyToExistingFormat: "Appliquer aux %d profils existants",
        appliedToExistingLabel: "Appliqu\u{00E9}",
        resetToShippedAction: "Valeurs recommand\u{00E9}es",
        noProfilesInCategoryLabel: "Aucun profil de ce type pour l\u{2019}instant.",
        galleryAutoOrderNote: "Tri automatique : les souvenirs les plus r\u{00E9}cents en haut.",
        diaryReminderSectionTitle: "Rappels du journal",
        diaryReminderToggleTitle: "Rappels du journal",
        diaryReminderCaption: "Une invitation discr\u{00E8}te \u{00E0} noter quelque chose, m\u{00EA}me loin de la date.",
        diaryFrequencyLabel: "Fr\u{00E9}quence",
        diaryCadenceDaily: "Quotidienne",
        diaryCadenceEveryThreeDays: "Tous les 3 jours",
        diaryCadenceWeekly: "Hebdomadaire",
        diaryCadenceNever: "Jamais",
        diaryReminderTimeLabel: "Heure du rappel",
        diaryReminderNextFormat: "Prochain rappel : %@",
        diaryReminderPeopleFormat: "%d profils concern\u{00E9}s",
        diaryReminderRemembranceNote: "Les comm\u{00E9}morations restent toujours en dehors de ces rappels.",
        diaryReminderExcludeTitle: "Exclure des rappels du journal",
        diaryReminderExcludeCaption: "Ce profil ne sera plus mentionn\u{00E9} dans les rappels.",
        diaryReminderOffNote: "Les rappels du journal sont d\u{00E9}sactiv\u{00E9}s dans les r\u{00E9}glages de notification.",
        diaryNudgeTitle: "Journal Kudao",
        diaryNudgeVariantOne: "Vous avez remarqu\u{00E9} quelque chose sur quelqu\u{2019}un aujourd\u{2019}hui ? Notez-le dans Kudao.",
        diaryNudgeVariantTwo: "Un d\u{00E9}tail, un go\u{00FB}t, une id\u{00E9}e : notez-le maintenant, \u{00E7}a servira plus tard.",
        diaryNudgeVariantThree: "Gardez \u{00E0} jour les profils des personnes qui comptent.",
        diaryNudgePersonFormatOne: "Vous avez appris quelque chose sur %@ derni\u{00E8}rement ?",
        diaryNudgePersonFormatTwo: "Deux lignes sur %@ : votre futur vous dira merci.",
        diaryNudgePairFormat: "Du nouveau sur %@ ou %@ ? Un d\u{00E9}tail de plus les rend uniques.",
        quickNoteTitle: "Note rapide",
        quickNoteCaption: "Choisissez la personne et \u{00E9}crivez : quelques mots suffisent.",
        quickNoteEmptyMessage: "Aucun profil disponible pour une note. Cr\u{00E9}ez-en un et revenez.",
        quickNoteSaveAction: "Enregistrer",
        gridCategoriesTitle: "Cat\u{00E9}gories",
        gridNextEventTitle: "Prochain \u{00E9}v\u{00E9}nement",
        gridNextEventEmpty: "Aucune date",
        gridPendingCountFormat: "%d plans",
        gridPendingEmpty: "Tout est bon",
        gridProfileCountFormat: "%d profils",
        gridProfileCountOne: "1 profil",
        gridCategoryEmptyHint: "Aucun profil, touchez pour ajouter",
        gridAnniversaryInFormat: "Anniversaire dans %d j",
        gridSharedCountFormat: "%d profils partag\u{00E9}s",
        sharedListTitle: "Partag\u{00E9}s avec vous",
        pendingScopeEmptyMessage: "Aucun plan de f\u{00EA}te en attente : tout est \u{00E0} jour.",
        sharedScopeEmptyMessage: "Vous n\u{2019}organisez encore rien \u{00E0} plusieurs.",
        buyOnAmazonAction: "Acheter sur Amazon",
        affiliateSectionTitle: "Affiliation Amazon",
        affiliateCaption: "Chaque march\u{00E9} Amazon a son propre tag : celui d\u{2019}amazon.fr ne rapporte rien sur amazon.it. Le march\u{00E9} suit la langue de l\u{2019}app, ou celle de l\u{2019}appareil.",
        affiliateTagLabel: "Tag partenaire",
        affiliateActiveBadge: "Utilis\u{00E9}",
        affiliateFallbackNote: "Sans tag, le bouton ouvre quand m\u{00EA}me Amazon, mais sans commission.",
        affiliateDisclosure: "En tant que Partenaire Amazon, Kudao r\u{00E9}alise un b\u{00E9}n\u{00E9}fice sur les achats remplissant les conditions requises, sans co\u{00FB}t suppl\u{00E9}mentaire pour vous",
        linkPreviewTitle: "Aper\u{00E7}u du lien",
        linkPreviewBadgeLabel: "Voir le lien avant de l\u{2019}ouvrir",
        linkPreviewStoreLabel: "Boutique",
        linkPreviewQueryLabel: "Recherche",
        linkPreviewNoTag: "Aucun tag pour ce march\u{00E9}",
        linkPreviewNoTagHint: "Le lien ouvre quand m\u{00EA}me Amazon, mais ne rapporte rien. Ajoutez le tag dans Mon profil \u{203A} Affiliation Amazon.",
        linkPreviewUrlLabel: "URL de destination",
        linkPreviewOpenAction: "Ouvrir dans Safari",
        linkPreviewCopyAction: "Copier le lien",
        linkPreviewCopiedLabel: "Copi\u{00E9}",
        linkPreviewGoogleAction: "Chercher plut\u{00F4}t sur Google Shopping",
        libraryTitle: "Biblioth\u{00E8}que",
        libraryEmptyTitle: "La biblioth\u{00E8}que est encore vide",
        libraryEmptyMessage: "Une fois la date pass\u{00E9}e, Kudao l\u{2019}archive ici : le plan, le message et les photos de cette ann\u{00E9}e restent pour toujours.",
        libraryProfileEmptyMessage: "La premi\u{00E8}re ann\u{00E9}e arrivera dans la biblioth\u{00E8}que juste apr\u{00E8}s la prochaine date.",
        libraryFilterEmptyMessage: "Aucun \u{00E9}v\u{00E9}nement archiv\u{00E9} avec ces filtres.",
        libraryAllProfiles: "Tous les profils",
        libraryCountFormat: "%d \u{00E9}v\u{00E9}nements archiv\u{00E9}s",
        libraryYearsCountFormat: "%d ann\u{00E9}es archiv\u{00E9}es",
        libraryPlanSection: "Le plan de cette ann\u{00E9}e-l\u{00E0}",
        libraryNoPlanLabel: "Aucun plan enregistr\u{00E9} cette ann\u{00E9}e-l\u{00E0}",
        librarySentBadge: "Envoy\u{00E9}",
        libraryNotSentBadge: "Jamais envoy\u{00E9}",
        libraryMemoriesSection: "Notes de l\u{2019}ann\u{00E9}e",
        libraryMediaSection: "Photos et vid\u{00E9}os",
        libraryMediaCountFormat: "%d souvenirs collect\u{00E9}s",
        libraryNotesCountFormat: "%d notes \u{00E9}crites cette ann\u{00E9}e-l\u{00E0}",
        libraryKeywordsSection: "Ce que l\u{2019}on savait alors",
        libraryArchivedOnFormat: "Archiv\u{00E9} le %@"
    )

    static let spanish = Strings(
        homeTitle: "Cumpleaños",
        homeSubtitle: "Toma notas todo el año, celebra a la perfección.",
        upNext: "El próximo",
        othersSection: "Próximamente",
        emptyTitle: "Aún no hay nadie",
        emptyMessage: "Añade a las personas que te importan y empieza a reunir ideas para su cumpleaños.",
        emptyAction: "Crear el primer perfil",
        searchPlaceholder: "Buscar un nombre",
        searchClear: "Borrar la búsqueda",
        resultsSection: "Resultados",
        noResultsTitle: "Sin resultados",
        noResultsMessageFormat: "Ningún perfil coincide con «%@».",
        sortLabel: "Ordenar",
        sortNearest: "Cumpleaños más cercano",
        sortAlphabetical: "Nombre (A-Z)",
        sortRecentlyAdded: "Añadidos recientemente",
        newProfileTitle: "Nuevo perfil",
        editProfileTitle: "Editar perfil",
        nameLabel: "Nombre",
        namePlaceholder: "¿Cómo se llama?",
        photoLabel: "Foto",
        addPhoto: "Añadir foto",
        changePhoto: "Cambiar foto",
        removePhoto: "Quitar foto",
        birthDateLabel: "Fecha de nacimiento",
        relationshipLabel: "Relación",
        surpriseTitle: "Modo sorpresa",
        surpriseDescription: "El perfil permanece oculto: no será visible ni se podrá compartir con la persona homenajeada.",
        surpriseBadge: "Sorpresa",
        saveAction: "Guardar",
        cancelAction: "Cancelar",
        deleteAction: "Eliminar",
        createAction: "Crear perfil",
        retryAction: "Reintentar",
        relFriend: "Amigo",
        relFamily: "Familia",
        relPartner: "Pareja",
        relColleague: "Colega",
        todayTitle: "¡Es hoy!",
        tomorrowLabel: "Mañana",
        todayLabel: "Hoy",
        yesterdayLabel: "Ayer",
        dayUnit: "día",
        daysUnit: "días",
        daysToGo: "para el cumpleaños",
        turnsFormat: "Cumple %d años",
        turnsTodayFormat: "Cumple %d años hoy",
        nextBirthdayLabel: "Próximo cumpleaños",
        imminentBadge: "Esta semana",
        imminentDaysFormat: "En %d días",
        diaryTab: "Diario",
        preferencesTab: "Preferencias",
        suggestionsTab: "Sugerencias",
        diaryEmptyTitle: "Diario vacío",
        diaryEmptyMessage: "Escribe la primera nota: gustos, deseos y detalles que descubras durante el año.",
        preferencesEmptyTitle: "Todavía no hay preferencias",
        preferencesEmptyMessage: "Las palabras clave se extraen automáticamente de las notas del diario.",
        suggestionsEmptyTitle: "Todavía no hay sugerencias",
        suggestionsEmptyMessage: "Regalo, tarta, local y número de invitados aparecerán aquí según tu diario.",
        comingSoon: "Muy pronto",
        diaryComposerPlaceholderFormat: "¿Qué has notado hoy sobre %@?",
        diarySendNote: "Guardar nota",
        diaryNotesSection: "Notas",
        diaryNotesCountFormat: "%d notas",
        deleteNoteAction: "Eliminar nota",
        analyzingLabel: "Analizando…",
        analysisFailedLabel: "Palabras clave no extraídas",
        giftIdeaBadge: "Idea de regalo",
        giftIdeasSection: "Pistas de regalo",
        tagsSection: "Palabras clave",
        removeTagHint: "Toca × para quitar una palabra clave equivocada.",
        removeTagAction: "Quitar palabra clave",
        planTitleFormat: "Plan de fiesta para %@",
        suggestionsGeneratingTitle: "Estoy pensando…",
        suggestionsGeneratingMessage: "Leo las preferencias recogidas y preparo el plan.",
        suggestionsNoTagsTitle: "Hace falta una nota",
        suggestionsNoTagsMessage: "Escribe algunas notas: las sugerencias nacen de las preferencias extraídas.",
        suggestionsErrorTitle: "Sugerencias no disponibles",
        generateAction: "Generar sugerencias",
        regenerateAction: "Regenerar",
        regenerateAllAction: "Regenerar todo",
        giftCardTitle: "Regalo",
        cakeCardTitle: "Tarta",
        venueCardTitle: "Local",
        guestsCardTitle: "Invitados",
        reasonLabel: "Por qué",
        priceBandLabel: "Rango de precio",
        priceLow: "Rango bajo",
        priceMedium: "Rango medio",
        priceHigh: "Rango alto",
        confidenceLabel: "Confianza",
        confidenceLow: "baja",
        confidenceMedium: "media",
        confidenceHigh: "alta",
        lowConfidenceBanner: "Escribe más notas en el diario para sugerencias más precisas.",
        confirmAllAction: "Confirmar todo",
        confirmedAtFormat: "Plan confirmado el %@",
        unconfirmedChanges: "Cambios sin confirmar",
        editSuggestionTitle: "Editar sugerencia",
        editedBadge: "Editado",
        guestsUnitFormat: "%d personas",
        basedOnTagsFormat: "Basado en %d palabras clave",
        doneAction: "Hecho",
        catFood: "Comida",
        catTravel: "Viajes",
        catShopping: "Compras",
        catHobby: "Aficiones",
        catPlaces: "Lugares",
        catOther: "Otro",
        profileSettings: "Ajustes del perfil",
        editData: "Editar datos",
        deleteProfile: "Eliminar perfil",
        deleteConfirmTitle: "¿Eliminar este perfil?",
        deleteConfirmMessageFormat: "Se eliminarán el perfil de %@ y todas las notas del diario.",
        languageLabel: "Idioma",
        profilesCountFormat: "%d perfiles",
        ageNowFormat: "%d años",
        remindersMenuTitle: "Recordatorios y notificaciones",
        remindersSectionTitle: "Recordatorios",
        reminderToggleTitle: "Recordatorio de cumpleaños",
        reminderToggleDescription: "Un aviso local cuando el cumpleaños se acerca, con las sugerencias listas.",
        reminderDaysTitle: "Recordarme",
        dayBeforeFormat: "%d día antes",
        daysBeforeFormat: "%d días antes",
        giftReminderToggleTitle: "Recordatorio de regalo aparte",
        giftReminderDescription: "Un aviso extra, antes del recordatorio de cumpleaños, para comprar el regalo a tiempo.",
        giftReminderDaysTitle: "Recordatorio de regalo",
        reminderScheduledFormat: "Próximo aviso: %@",
        reminderDisabledLabel: "Ningún recordatorio programado",
        notificationsDeniedTitle: "Notificaciones desactivadas",
        notificationsDeniedMessage: "Activa las notificaciones de Kudao en los ajustes de iOS para recibir los recordatorios.",
        openSettingsAction: "Abrir Ajustes",
        notificationBirthdayTitle: "Cumpleaños a la vista",
        notificationBirthdayBodyFormat: "¡El cumpleaños de %@ se acerca! Revisa las sugerencias en Kudao",
        notificationGiftTitle: "Recordatorio de regalo",
        notificationGiftBodyFormat: "No olvides el regalo para %@: %@",
        notificationGiftBodyFallbackFormat: "No olvides el regalo para %@. Abre Kudao para elegir una idea.",
        exportSectionTitle: "Exportar diario",
        exportSectionDescription: "Guarda las notas y palabras clave de este perfil en un archivo para compartir o archivar.",
        exportPDFAction: "Exportar en PDF",
        exportJSONAction: "Exportar en JSON",
        exportPreparing: "Preparando el archivo…",
        exportFailedTitle: "Error al exportar",
        exportFailedMessage: "No se pudo crear el archivo. Inténtalo de nuevo.",
        exportDocumentTitleFormat: "Diario de %@",
        exportGeneratedAtFormat: "Exportado el %@",
        exportProfileSection: "Perfil",
        exportPlanSection: "Plan de fiesta",
        exportNotesSection: "Notas del diario",
        exportNoNotes: "Todavía no hay notas en el diario.",
        exportNoPlan: "No hay plan de fiesta guardado.",
        reviewBannerTitle: "Por confirmar",
        reviewBannerSubtitleFormat: "%d planes de fiesta esperan tu confirmación",
        planReviewTitle: "¿Todo listo?",
        planReviewSubtitleFormat: "El cumpleaños de %@ es en %d días. Confirma el plan o modifícalo.",
        planReviewTodayFormat: "Hoy es el cumpleaños de %@. Confirma el plan o modifícalo.",
        planReviewNoPlanTitle: "Todavía no hay plan",
        planReviewNoPlanMessage: "Abre las sugerencias para crear el plan de fiesta de este perfil.",
        confirmAction: "Confirmar",
        modifyAction: "Editar",
        pendingBadgeLabel: "Plan por confirmar",
        appSettingsMenu: "Ajustes de la app",
        settingsTitle: "Ajustes",
        settingsLanguageSection: "Idioma",
        settingsSurpriseSection: "Modo sorpresa",
        settingsSurpriseFooter: "Estas protecciones se aplican a todos los perfiles con el modo sorpresa activo.",
        faceIDToggleTitle: "Proteger perfiles sorpresa con Face ID",
        faceIDToggleDescription: "Pide Face ID, Touch ID o el código del dispositivo antes de abrir un perfil sorpresa.",
        hidePreviewsToggleTitle: "Ocultar la vista previa de notificaciones de perfiles sorpresa",
        hidePreviewsToggleDescription: "Las notificaciones muestran solo “Recordatorio Kudao”, nunca el nombre de la persona.",
        biometryUnavailableNote: "Sin biometría configurada: se pedirá el código del dispositivo.",
        unlockReasonFormat: "Desbloquear el perfil de %@",
        unlockAction: "Desbloquear",
        unlockFailedTitle: "No se pudo desbloquear",
        unlockFailedMessage: "No hemos podido verificar tu identidad. Inténtalo de nuevo.",
        lockedBadgeLabel: "Perfil protegido",
        notificationGenericTitle: "Recordatorio Kudao",
        notificationGenericBody: "Abre Kudao para ver el recordatorio.",
        maskedProfileName: "Sorpresa",
        settingsWidgetSection: "Widget",
        settingsWidgetHint: "Mantén pulsada la pantalla de inicio, toca Editar, luego Añadir widget y elige Kudao.",
        settingsSharingNote: "Los perfiles sorpresa quedarán fuera de cualquier compartición con la persona homenajeada.",
        lastNameLabel: "Apellido",
        lastNamePlaceholder: "Apellido (opcional)",
        noLastNameLabel: "Apellido no indicado",
        addressLabel: "Direcci\u{00F3}n",
        addressPlaceholder: "Calle, ciudad (opcional)",
        phoneLabel: "Tel\u{00E9}fono",
        phonePlaceholder: "N\u{00FA}mero de tel\u{00E9}fono (opcional)",
        emailLabel: "Correo",
        emailPlaceholder: "Correo electr\u{00F3}nico (opcional)",
        contactsSectionTitle: "Contacto",
        birthLabel: "Nacimiento",
        ageLabel: "Edad",
        ageYearsFormat: "%d a\u{00F1}os",
        notificationActiveLabel: "Aviso activo",
        notificationOffLabel: "Aviso desactivado",
        daysBeforeShortLabel: "d\u{00ED}as antes:",
        hourShortLabel: "hora:",
        editAction: "Editar",
        sendWishesAction: "Enviar felicitaci\u{00F3}n",
        messageTab: "Mensaje",
        messageSectionTitle: "Mensaje de cumplea\u{00F1}os",
        messageGeneratingTitle: "Escribiendo la felicitaci\u{00F3}n\u{2026}",
        messageGeneratingMessage: "Uso las notas del diario para que sea realmente personal.",
        messageEmptyTitle: "Sin mensaje",
        messageEmptyMessage: "Genera un mensaje de cumplea\u{00F1}os personal a partir de las palabras clave del diario.",
        messageToneLabel: "Tono",
        toneWarm: "Cari\u{00F1}oso",
        toneFunny: "Divertido",
        toneElegant: "Elegante",
        messageRegenerateAction: "Regenerar",
        messageCopyAction: "Copiar",
        messageCopiedLabel: "Copiado",
        messageShareAction: "Compartir",
        messageSMSAction: "Mensajes",
        messageEmailAction: "Correo",
        messageEmailSubjectFormat: "\u{00A1}Feliz cumplea\u{00F1}os %@!",
        messageBasedOnNote: "Escrito con las palabras clave del diario",
        buyOnlineAction: "Comprar online",
        findStoreAction: "Buscar una tienda cerca de ti",
        noPlanAlertTitle: "Sin idea de regalo",
        noPlanAlertMessage: "Genera primero las sugerencias en la pesta\u{00F1}a Sugerencias.",
        giftFromPlanFormat: "Idea de regalo: %@",
        storesTitle: "Tiendas cercanas",
        storesSearchingLabel: "Buscando tiendas\u{2026}",
        storesEmptyTitle: "Ninguna tienda encontrada",
        storesEmptyMessage: "No hay tiendas de este tipo a menos de 5 km de ti.",
        storesPermissionTitle: "Se necesita la ubicaci\u{00F3}n",
        storesPermissionMessage: "Kudao usa tu ubicaci\u{00F3}n solo para buscar tiendas cercanas.",
        storesPermissionAction: "Permitir la ubicaci\u{00F3}n",
        storesDeniedTitle: "Ubicaci\u{00F3}n no disponible",
        storesDeniedMessage: "Activa los servicios de localizaci\u{00F3}n para Kudao en Ajustes.",
        storesFailedTitle: "B\u{00FA}squeda fallida",
        storesFailedMessage: "Ahora no puedo buscar tiendas. Int\u{00E9}ntalo en un momento.",
        storesRadiusNote: "A menos de 5 km de ti",
        storesSearchingCategoryFormat: "Buscando: %@",
        openInMapsAction: "Abrir en Mapas",
        distanceKmFormat: "%.1f km",
        distanceMetersFormat: "%d m",
        shareProfileAction: "Compartir perfil",
        shareProfileTitle: "Compartir perfil",
        shareProfileSubtitleFormat: "Invita a alguien a organizar el cumplea\u{00F1}os de %@ contigo.",
        permissionSectionTitle: "Qu\u{00E9} podr\u{00E1} hacer",
        permissionViewTitle: "Solo lectura",
        permissionViewCaption: "Ve el perfil, el diario y las sugerencias sin modificarlos.",
        permissionEditTitle: "Puede colaborar",
        permissionEditCaption: "A\u{00F1}ade notas al diario y vota las sugerencias.",
        generateInviteAction: "Generar c\u{00F3}digo de invitaci\u{00F3}n",
        inviteReadyTitle: "Invitaci\u{00F3}n lista",
        inviteCodeLabel: "C\u{00F3}digo de invitaci\u{00F3}n",
        inviteHint: "Quien lo reciba abre Kudao, toca el icono de ajustes y elige \u{00AB}Unirse a un perfil\u{00BB}.",
        copyCodeAction: "Copiar c\u{00F3}digo",
        copiedLabel: "Copiado",
        shareInviteAction: "Compartir invitaci\u{00F3}n",
        newInviteAction: "Generar otro c\u{00F3}digo",
        discardInviteAction: "Cancelar invitaci\u{00F3}n",
        inviteMessageFormat: "\u{00A1}Organicemos juntos el cumplea\u{00F1}os de %@ en Kudao! Abre la app, ve a Ajustes \u{2192} Unirse a un perfil e introduce el c\u{00F3}digo: %@",
        shareBlockedSurpriseTitle: "Perfil sorpresa protegido",
        shareBlockedSurpriseMessage: "Desactiva la protecci\u{00F3}n sorpresa en los ajustes para compartir este perfil.",
        yourNameLabel: "Tu nombre",
        yourNamePlaceholder: "C\u{00F3}mo te llamas",
        yourNameCaption: "Los dem\u{00E1}s participantes lo usan para reconocer tus notas.",
        participantsTitle: "Participantes",
        participantsMenuTitle: "Participantes",
        participantsCountFormat: "%d participantes",
        participantOwnerBadge: "Propietario",
        participantYou: "T\u{00FA}",
        participantUnknown: "Participante",
        participantPendingTitle: "Invitaciones pendientes",
        removeParticipantAction: "Quitar",
        removeParticipantConfirmFormat: "%@ perder\u{00E1} el acceso a este perfil. Las notas ya escritas se quedan en el diario.",
        ownerCannotBeRemoved: "El propietario no se puede quitar: elimina el perfil para terminar el uso compartido.",
        guestLeaveHint: "Solo el propietario del perfil gestiona los accesos.",
        participantsEmptyTitle: "Sin participantes",
        participantsEmptyMessage: "Comparte el perfil para organizar la fiesta junto a otra persona.",
        joinedAtFormat: "Desde el %@",
        joinShareMenuTitle: "Unirse a un perfil",
        joinShareTitle: "Unirse a un perfil",
        joinShareSubtitle: "Introduce el c\u{00F3}digo de invitaci\u{00F3}n que has recibido.",
        joinCodePlaceholder: "C\u{00D3}DIGO",
        joinAction: "Unirse",
        pasteCodeAction: "Pegar del portapapeles",
        joinSuccessFormat: "Ya colaboras en el cumplea\u{00F1}os de %@",
        joinSuccessCaption: "El perfil est\u{00E1} en tu lista, con las notas y sugerencias compartidas.",
        sharedProfileFallbackName: "Perfil compartido",
        shareErrorGeneric: "Algo ha ido mal. Int\u{00E9}ntalo de nuevo.",
        shareErrorInvalidCode: "C\u{00F3}digo no v\u{00E1}lido. Compru\u{00E9}balo e int\u{00E9}ntalo otra vez.",
        shareErrorCodeUsed: "Este c\u{00F3}digo ya lo ha usado otra persona.",
        shareErrorOwnProfile: "Este perfil ya es tuyo.",
        shareErrorNoAccess: "Ya no tienes acceso a este perfil compartido.",
        shareErrorReadOnly: "Tienes acceso de solo lectura a este perfil.",
        shareErrorNotOwner: "Solo el propietario del perfil puede hacerlo.",
        shareErrorOffline: "Sin conexi\u{00F3}n. Int\u{00E9}ntalo cuando vuelvas a estar online.",
        sharedBadge: "Compartido",
        sharedByFormat: "Compartido por %@",
        readOnlyBadge: "Solo lectura",
        readOnlyDiaryMessage: "Tienes acceso de solo lectura: puedes leer las notas pero no a\u{00F1}adirlas.",
        readOnlyPlanMessage: "El plan lo gestiona el propietario del perfil.",
        voteUpLabel: "Me encanta",
        voteDownLabel: "No me convence",
        voteTallyFormat: "%1$d a favor \u{00B7} %2$d en contra",
        votesEmptyLabel: "A\u{00FA}n sin votos",
        syncingLabel: "Actualizando\u{2026}",
        collaborationSectionTitle: "Compartir",
        collaborationHubTitle: "Junto a otras personas",
        collaborationHubCountFormat: "%d perfiles compartidos",
        collaborationInviteTitle: "Organiza en grupo",
        collaborationInviteMessage: "Invita a quien quieras a un perfil, o \u{00FA}nete con un c\u{00F3}digo.",
        inviteSomeoneAction: "Invitar a alguien",
        pendingInvitesCountFormat: "%d invitaciones pendientes",
        collaborationOnlyYou: "Solo t\u{00FA}, por ahora",
        ageBracketLabel: "Franja de edad",
        ageBracketChild: "Ni\u{00F1}o",
        ageBracketTeen: "Adolescente",
        ageBracketAdult: "Adulto",
        ageBracketSenior: "Mayor",
        favoriteCharacterLabel: "Dibujo o personaje favorito",
        favoriteCharacterPlaceholder: "Ej. Bluey, Spider-Man, Frozen",
        favoriteCharacterCaption: "Opcional: ayuda a elegir tarta y regalo tem\u{00E1}ticos.",
        messageGenerateAction: "Generar mensaje",
        messageWriteMyselfAction: "Escribirlo yo",
        messagePlaceholder: "Escribe aqu\u{00ED} tu felicitaci\u{00F3}n\u{2026}",
        messageEditorHint: "Edita el texto como quieras: lo enviamos tal cual.",
        messageSentBadge: "Enviado",
        messageScheduleTitle: "Programaci\u{00F3}n del env\u{00ED}o",
        messageScheduleToggle: "Recu\u{00E9}rdame enviarlo",
        messageSendDateLabel: "Enviar el",
        messageScheduleReadyFormat: "Te avisamos el %@",
        messagePastDateLabel: "Elige una fecha futura para recibir el recordatorio.",
        messageAlreadySentLabel: "Mensaje ya enviado.",
        messageMarkSentShortAction: "Marcar como enviado",
        messageMarkSentAction: "S\u{00ED}, ya lo envi\u{00E9}",
        messageMarkUnsentAction: "Marcar como pendiente",
        messageNotYetAction: "Todav\u{00ED}a no",
        messageSentConfirmTitle: "\u{00BF}Has enviado la felicitaci\u{00F3}n?",
        messageSentConfirmMessage: "Si lo confirmas, no volveremos a recordarte este mensaje.",
        messageContactTitle: "Contacto del destinatario",
        messageContactCaption: "Sirve para abrir WhatsApp o Mensajes con el texto listo.",
        messageNoContactLabel: "Sin contacto guardado",
        messageNeedsPhoneHint: "A\u{00F1}ade un n\u{00FA}mero para abrir el chat ya escrito.",
        messageWhatsAppAction: "Abrir WhatsApp",
        messageMessagesAction: "Abrir Mensajes",
        messageOpenFailedTitle: "App no disponible",
        messageOpenFailedMessage: "No hemos podido abrir esa app en este dispositivo. El texto se ha copiado al portapapeles.",
        notificationMessageTitle: "Felicitaci\u{00F3}n pendiente",
        notificationMessageBodyFormat: "\u{00A1}Es el momento de felicitar a %@ por su cumplea\u{00F1}os!",
        messageAutoRefreshToggle: "Actualizar con las notas nuevas",
        messageAutoRefreshCaption: "Cuando a\u{00F1}ades notas o palabras clave al diario, reescribimos el borrador de la felicitaci\u{00F3}n.",
        messageAutoRefreshPausedLabel: "Has editado el texto a mano: la actualizaci\u{00F3}n autom\u{00E1}tica est\u{00E1} en pausa.",
        messageAutoRefreshResumeAction: "Reanudar",
        messageAutoRefreshedFormat: "Actualizado con tus \u{00FA}ltimas notas \u{00B7} %@",
        galleryTab: "Galer\u{00ED}a",
        gallerySectionTitle: "Recuerdos de la fiesta",
        galleryCountFormat: "%d recuerdos",
        galleryAddAction: "A\u{00F1}adir recuerdos",
        galleryFromLibraryAction: "Elegir de la biblioteca",
        galleryCaptureAction: "Hacer foto o v\u{00ED}deo",
        galleryEmptyTitle: "A\u{00FA}n no hay recuerdos",
        galleryEmptyMessage: "Sube las fotos y los v\u{00ED}deos de la fiesta: los ver\u{00E1} todo el que tenga acceso al perfil.",
        galleryLockedTitle: "Disponible desde el d\u{00ED}a de la fiesta",
        galleryLockedMessageFormat: "La galer\u{00ED}a compartida se abre el %@, para reunir enseguida las fotos y los v\u{00ED}deos del cumplea\u{00F1}os.",
        galleryUploadingTitle: "Subiendo\u{2026}",
        galleryUploadingCountFormat: "%d pendientes",
        galleryDeleteAction: "Eliminar recuerdo",
        galleryDeleteConfirmTitle: "\u{00BF}Eliminar este recuerdo?",
        galleryDeleteConfirmMessage: "La foto o el v\u{00ED}deo desaparecer\u{00E1} tambi\u{00E9}n para los dem\u{00E1}s participantes.",
        galleryPrivacyNote: "Solo quien tiene acceso al perfil puede ver y subir estos recuerdos.",
        galleryLoadingLabel: "Cargando\u{2026}",
        galleryMediaUnavailable: "Este contenido no est\u{00E1} disponible sin conexi\u{00F3}n. Int\u{00E9}ntalo cuando vuelvas a estar en l\u{00ED}nea.",
        galleryTooLargeMessage: "El archivo es demasiado grande: prueba con un v\u{00ED}deo m\u{00E1}s corto (m\u{00E1}x. 25 MB).",
        galleryPrepareFailedMessage: "No podemos preparar este contenido. Prueba con otro archivo.",
        galleryRetryUnavailable: "El archivo original ya no est\u{00E1} disponible: vuelve a subirlo.",
        cloudSectionTitle: "Copia y restauraci\u{00F3}n",
        cloudSectionCaption: "Mant\u{00E9}n a salvo perfiles, diario, planes y mensajes.",
        cloudManageTitle: "Copia de seguridad",
        cloudOnLabel: "Copia activada",
        cloudOffLabel: "Copia desactivada",
        cloudOffCaption: "Ahora mismo tus datos solo viven en este iPhone.",
        cloudNeverSynced: "Todav\u{00ED}a no se ha guardado nada.",
        cloudLastSyncFormat: "\u{00DA}ltima copia: %@",
        cloudEnableTitle: "Activar la copia",
        cloudEnableCaption: "Kudao guarda una copia de tus perfiles, notas del diario, planes de fiesta y mensajes. Recibir\u{00E1}s un c\u{00F3}digo de recuperaci\u{00F3}n para recuperarlos en otro iPhone.",
        cloudEnableAction: "Activar la copia",
        cloudCodeLabel: "Tu c\u{00F3}digo de recuperaci\u{00F3}n",
        cloudCodeCaption: "Gu\u{00E1}rdalo en un lugar seguro: es la \u{00FA}nica llave de tus datos. Quien tenga el c\u{00F3}digo puede restaurarlos.",
        cloudCopyAction: "Copiar c\u{00F3}digo",
        cloudCopiedLabel: "C\u{00F3}digo copiado",
        cloudActionsTitle: "Gestionar",
        cloudSyncNowAction: "Guardar ahora",
        cloudDisableAction: "Desactivar la copia",
        cloudDeleteRemoteAction: "Desactivar y borrar la copia",
        cloudDisableTitle: "\u{00BF}Desactivar la copia?",
        cloudDisableMessage: "Tus datos siguen en este iPhone. Tambi\u{00E9}n puedes borrar por completo la copia guardada.",
        cloudRestoreTitle: "Restaurar en este iPhone",
        cloudRestoreHint: "\u{00BF}Ya tienes una copia? Escribe el c\u{00F3}digo de recuperaci\u{00F3}n para traerlo todo de vuelta.",
        cloudRestorePlaceholder: "C\u{00D3}DIGO",
        cloudRestoreAction: "Restaurar",
        cloudRestoredFormat: "%d elementos restaurados",
        cloudBackedUpBanner: "Todo guardado",
        cloudPrivacyNote: "Kudao no pide correo ni contrase\u{00F1}a: la copia est\u{00E1} ligada solo a tu c\u{00F3}digo de recuperaci\u{00F3}n, guardado en el llavero de iOS. Los perfiles que otros comparten contigo no se guardan aqu\u{00ED}.",
        cloudUnavailableMessage: "La copia de seguridad no est\u{00E1} disponible en esta versi\u{00F3}n de la app.",
        cloudInvalidCodeMessage: "El c\u{00F3}digo parece incompleto: rev\u{00ED}salo e int\u{00E9}ntalo de nuevo.",
        cloudUnknownCodeMessage: "No se ha encontrado ninguna copia con este c\u{00F3}digo.",
        cloudGenericErrorMessage: "No puedo conectar con la copia: revisa la conexi\u{00F3}n e int\u{00E9}ntalo de nuevo.",
        gallerySortLabel: "Orden",
        gallerySortNewest: "M\u{00E1}s recientes primero",
        gallerySortOldest: "M\u{00E1}s antiguos primero",
        myProfileTitle: "Mi perfil",
        myProfileSubtitle: "La foto y el nombre que ven las personas con quienes compartes un cumplea\u{00F1}os.",
        notificationDefaultsTitle: "Ajustes de notificaciones",
        notificationDefaultsCaption: "Se usan en cada nuevo cumplea\u{00F1}os. Siempre puedes cambiarlos perfil por perfil.",
        defaultReminderDaysLabel: "Aviso de cumplea\u{00F1}os",
        defaultGiftDaysLabel: "Aviso de regalo",
        defaultReminderTimeLabel: "Hora",
        defaultsAppliedNote: "La hora se aplica a todos los avisos ya programados.",
        privacySectionTitle: "Privacidad",
        privacyMovedCaption: "Face ID y las vistas discretas se gestionan en Mi perfil.",
        accountSectionTitle: "Cuenta",
        accountNoLoginTitle: "No hace falta iniciar sesi\u{00F3}n",
        accountNoLoginCaption: "Kudao funciona sin correo ni contrase\u{00F1}a: tus datos se quedan en este iPhone.",
        accountVaultCaption: "Recuperable con tu c\u{00F3}digo de recuperaci\u{00F3}n.",
        accountSignOutAction: "Salir de la copia",
        accountSignOutTitle: "\u{00BF}Salir de la copia?",
        accountSignOutMessage: "Este iPhone dejar\u{00E1} de guardar en la nube. Tus datos siguen aqu\u{00ED} y la copia guardada no se toca: puedes volver con tu c\u{00F3}digo de recuperaci\u{00F3}n.",
        appInfoTitle: "Informaci\u{00F3}n",
        appVersionLabel: "Versi\u{00F3}n",
        appSupportAction: "Escribir al soporte",
        appSupportCaption: "Solemos responder en un par de d\u{00ED}as laborables.",
        galleryPreparingTitle: "Preparando los recuerdos\u{2026}",
        galleryUploadAction: "Subir recuerdos",
        galleryCaptionSheetTitle: "Nuevos recuerdos",
        galleryCaptionSheetMessage: "A\u{00F1}ade una descripci\u{00F3}n breve a cada recuerdo. Tambi\u{00E9}n puedes dejarla vac\u{00ED}a.",
        galleryCaptionPlaceholder: "Escribe una descripci\u{00F3}n\u{2026}",
        galleryCaptionAddAction: "A\u{00F1}adir descripci\u{00F3}n",
        galleryCaptionEditAction: "Editar descripci\u{00F3}n",
        galleryCaptionEditorTitle: "Descripci\u{00F3}n",
        photoSourceCameraAction: "Hacer una foto",
        photoSourceLibraryAction: "Elegir de la biblioteca",
        photoCropTitle: "Encuadra la foto",
        photoCropHint: "Arrastra para mover, pellizca para acercar.",
        photoUseAction: "Usar esta foto",
        cameraDeniedTitle: "C\u{00E1}mara no disponible",
        cameraDeniedMessage: "Kudao no tiene permiso para usar la c\u{00E1}mara. Act\u{00ED}valo en los Ajustes de iOS para hacer una foto.",
        libraryDeniedTitle: "Fotos no disponibles",
        libraryDeniedMessage: "Kudao no tiene permiso para acceder a tus fotos. Act\u{00ED}valo en los Ajustes de iOS para elegir una.",
        notificationGalleryTitle: "Recuerdos de la fiesta",
        notificationGalleryBodyFormat: "\u{00A1}Sube tus recuerdos de la fiesta de %@ en Kudao!",

        occasionBirthday: "Cumplea\u{00F1}os",
        occasionWedding: "Boda",
        occasionRemembrance: "Conmemoraci\u{00F3}n",
        occasionOther: "Otro",
        occasionBirthdayCaption: "Regalo, tarta, invitados y felicitaci\u{00F3}n para quien celebra.",
        occasionWeddingCaption: "Aniversario de boda: un regalo y una experiencia en pareja.",
        occasionRemembranceCaption: "Guarda el recuerdo de alguien que ya no est\u{00E1}.",
        occasionOtherCaption: "Una ocasi\u{00F3}n libre, a tu manera.",
        occasionBirthdayPlural: "Cumplea\u{00F1}os",
        occasionWeddingPlural: "Bodas",
        occasionRemembrancePlural: "Conmemoraciones",
        occasionOtherPlural: "Otro",
        occasionStepTitle: "\u{00BF}Qu\u{00E9} tipo de ocasi\u{00F3}n es?",
        occasionStepSubtitle: "Kudao adapta las preguntas, las ideas y los recordatorios a lo que elijas.",
        weddingDateLabel: "Fecha de la boda",
        passingDateLabel: "Fecha del fallecimiento",
        eventDateLabel: "Fecha del evento",
        weddingDateHint: "El d\u{00ED}a de la boda: el aniversario se cuenta desde aqu\u{00ED}.",
        passingDateHint: "El d\u{00ED}a que recordar cada a\u{00F1}o.",
        eventDateHint: "La fecha que vuelve cada a\u{00F1}o.",
        weddingStatLabel: "Boda",
        passingStatLabel: "Partida",
        eventStatLabel: "Fecha",
        yearsTogetherLabel: "A\u{00F1}os juntos",
        yearsSinceLabel: "Hace",
        yearsElapsedLabel: "A\u{00F1}os",
        daysToAnniversary: "para el aniversario",
        daysToRemembrance: "para la fecha",
        daysToEvent: "para el evento",
        todayAnniversaryTitle: "\u{00A1}El aniversario es hoy!",
        todayRemembranceTitle: "Hoy es el d\u{00ED}a del recuerdo",
        todayEventTitle: "\u{00A1}Es hoy!",
        anniversaryYearsFormat: "%d a\u{00F1}os juntos",
        yearsAgoFormat: "Hace %d a\u{00F1}os",
        editionYearsFormat: "A\u{00F1}o %d",
        sendAnniversaryWishesAction: "Felicitar",
        writeThoughtAction: "Escribir un pensamiento",
        sendEventWishesAction: "Escribir un mensaje",
        memoriesTab: "Recuerdos",
        thoughtTab: "Pensamiento",
        traitsTab: "Rasgos",
        reminderOnTheDayLabel: "El mismo d\u{00ED}a",
        rememberedNamePlaceholder: "Su nombre",
        bondLabel: "V\u{00ED}nculo",
        bondCaption: "Solo sirve para dar el tono correcto a los textos que prepara Kudao.",
        bondParent: "Padre o madre",
        bondGrandparent: "Abuelo o abuela",
        bondSibling: "Hermano o hermana",
        bondSpouse: "C\u{00F3}nyuge o pareja",
        bondChild: "Hijo o hija",
        bondFriend: "Amigo",
        bondOther: "Ser querido",
        selfProfileToggleTitle: "Es una ocasi\u{00F3}n m\u{00ED}a",
        selfProfileToggleCaption: "Act\u{00ED}valo para tu propia boda o tu fecha: Kudao usa tu nombre.",
        selfProfileNameCaption: "Tomado de tu perfil. C\u{00E1}mbialo en \u{201C}Mi perfil\u{201D}.",
        selfProfileFallbackName: "Yo",
        backAction: "Atr\u{00E1}s",
        filterAllOccasions: "Todo",
        filterEmptyTitle: "Nada por aqu\u{00ED}",
        filterEmptyMessageFormat: "A\u{00FA}n no tienes ocasiones en \u{201C}%@\u{201D}.",
        anniversaryGiftCardTitle: "Regalo de aniversario",
        experienceCardTitle: "Experiencia en pareja",
        anniversaryVenueCardTitle: "D\u{00F3}nde celebrarlo",
        toneIntimate: "\u{00CD}ntimo",
        toneSober: "Sobrio",
        notificationAnniversaryTitle: "Aniversario cercano",
        notificationAnniversaryBodyFormat: "Prep\u{00E1}rate para el aniversario de %@.",
        notificationRemembranceTitle: "D\u{00ED}a del recuerdo",
        notificationRemembranceBodyFormat: "Hoy recordamos a %@.",
        notificationEventTitle: "Ocasi\u{00F3}n cercana",
        notificationEventBodyFormat: "Se acerca la ocasi\u{00F3}n de %@.",

        accountSignInTitle: "Entrar con correo",
        accountSignInCaption: "Opcional: recupera tus datos aunque pierdas el c\u{00F3}digo.",
        accountSignedInCaption: "Cuenta vinculada a tu copia de seguridad.",
        authSignInTab: "Entrar",
        authSignUpTab: "Registrarse",
        authSignInTitle: "Bienvenido de nuevo",
        authSignInSubtitle: "Entra para recuperar tus perfiles en este iPhone.",
        authSignUpTitle: "Crea tu cuenta",
        authSignUpSubtitle: "Un correo y una contrase\u{00F1}a: suficiente para no perder nada m\u{00E1}s.",
        authEmailPlaceholder: "Tu correo",
        authPasswordPlaceholder: "Contrase\u{00F1}a",
        authPasswordHintFormat: "Al menos %d caracteres.",
        authSignInAction: "Entrar",
        authSignUpAction: "Crear cuenta",
        authForgotPasswordAction: "\u{00BF}Olvidaste la contrase\u{00F1}a?",
        authResetSentMessage: "Te hemos enviado un correo para restablecer la contrase\u{00F1}a.",
        authOptionalNote: "La cuenta es opcional. Kudao funciona igual sin ella, y el c\u{00F3}digo de recuperaci\u{00F3}n sigue valiendo.",
        authConfirmTitle: "Confirma tu correo",
        authConfirmMessageFormat: "Hemos escrito a %@. Abre el enlace del correo y vuelve aqu\u{00ED} para entrar.",
        authResendAction: "Enviar el correo otra vez",
        authSignedInBadge: "Sesi\u{00F3}n iniciada",
        authVaultLinkedTitle: "Copia vinculada",
        authVaultLinkedCaption: "Tus datos vuelven al entrar con este correo, en cualquier sitio.",
        authVaultMissingTitle: "Sin copia vinculada",
        authVaultMissingCaption: "Activa la copia de seguridad: a partir de ah\u{00ED} ser\u{00E1} de esta cuenta.",
        authRestoredFormat: "Recuperados %d elementos de tu cuenta.",
        authSignOutAction: "Cerrar sesi\u{00F3}n",
        authSignOutNote: "Al salir todo sigue en este iPhone: solo desaparece el acceso r\u{00E1}pido.",
        authUnavailableMessage: "Este servicio no est\u{00E1} disponible en esta versi\u{00F3}n de la app.",
        authInvalidEmailMessage: "Revisa la direcci\u{00F3}n de correo.",
        authMissingPasswordMessage: "Escribe tu contrase\u{00F1}a.",
        authWeakPasswordFormat: "La contrase\u{00F1}a debe tener al menos %d caracteres.",
        authWrongCredentialsMessage: "Correo o contrase\u{00F1}a incorrectos.",
        authNotConfirmedMessage: "Primero debes confirmar tu correo: revisa tu bandeja.",
        authEmailTakenMessage: "Ya existe una cuenta con este correo. Prueba a entrar.",
        authRateLimitMessage: "Demasiados intentos. Prueba dentro de unos minutos.",
        authOfflineMessage: "Pareces estar sin conexi\u{00F3}n. Comprueba la red y vuelve a intentarlo.",
        authGenericErrorMessage: "Algo ha ido mal. Int\u{00E9}ntalo dentro de un momento.",

        notificationSettingsMenuTitle: "Notificaciones",
        notificationSettingsCaption: "Elige con cu\u{00E1}nta antelaci\u{00F3}n quieres el aviso, para cada tipo de ocasi\u{00F3}n.",
        notificationsActiveLabel: "Notificaciones activas",
        enableNotificationsAction: "Activar las notificaciones",
        mainReminderLabel: "Aviso principal",
        applyToExistingFormat: "Aplicar a %d perfiles existentes",
        appliedToExistingLabel: "Aplicado",
        resetToShippedAction: "Valores recomendados",
        noProfilesInCategoryLabel: "Todav\u{00ED}a no hay perfiles de este tipo.",
        galleryAutoOrderNote: "Orden autom\u{00E1}tico: los recuerdos m\u{00E1}s recientes arriba.",
        diaryReminderSectionTitle: "Recordatorios del diario",
        diaryReminderToggleTitle: "Recordatorios del diario",
        diaryReminderCaption: "Una invitaci\u{00F3}n amable a anotar algo, aunque la fecha est\u{00E9} lejos.",
        diaryFrequencyLabel: "Frecuencia",
        diaryCadenceDaily: "Diaria",
        diaryCadenceEveryThreeDays: "Cada 3 d\u{00ED}as",
        diaryCadenceWeekly: "Semanal",
        diaryCadenceNever: "Nunca",
        diaryReminderTimeLabel: "Hora del recordatorio",
        diaryReminderNextFormat: "Pr\u{00F3}ximo aviso: %@",
        diaryReminderPeopleFormat: "%d perfiles incluidos",
        diaryReminderRemembranceNote: "Las conmemoraciones siempre quedan fuera de estos avisos.",
        diaryReminderExcludeTitle: "Excluir de los recordatorios del diario",
        diaryReminderExcludeCaption: "Este perfil ya no se mencionar\u{00E1} en los avisos.",
        diaryReminderOffNote: "Los recordatorios del diario est\u{00E1}n desactivados en los ajustes de notificaciones.",
        diaryNudgeTitle: "Diario Kudao",
        diaryNudgeVariantOne: "\u{00BF}Has notado algo sobre alguien especial hoy? Escr\u{00ED}belo en Kudao.",
        diaryNudgeVariantTwo: "Un detalle, un gusto, una idea: an\u{00F3}talo ahora, te servir\u{00E1} despu\u{00E9}s.",
        diaryNudgeVariantThree: "Mant\u{00E9}n al d\u{00ED}a los perfiles de las personas que importan.",
        diaryNudgePersonFormatOne: "\u{00BF}Has descubierto algo sobre %@ \u{00FA}ltimamente?",
        diaryNudgePersonFormatTwo: "Dos l\u{00ED}neas sobre %@: tu yo del futuro lo agradecer\u{00E1}.",
        diaryNudgePairFormat: "\u{00BF}Alguna novedad sobre %@ o %@? Un detalle m\u{00E1}s los hace especiales.",
        quickNoteTitle: "Nota r\u{00E1}pida",
        quickNoteCaption: "Elige a la persona y escribe: bastan unas pocas palabras.",
        quickNoteEmptyMessage: "Todav\u{00ED}a no hay perfiles para una nota. Crea uno y vuelve.",
        quickNoteSaveAction: "Guardar",
        gridCategoriesTitle: "Categor\u{00ED}as",
        gridNextEventTitle: "Pr\u{00F3}ximo evento",
        gridNextEventEmpty: "Sin fechas",
        gridPendingCountFormat: "%d planes",
        gridPendingEmpty: "Todo listo",
        gridProfileCountFormat: "%d perfiles",
        gridProfileCountOne: "1 perfil",
        gridCategoryEmptyHint: "Sin perfiles, toca para a\u{00F1}adir",
        gridAnniversaryInFormat: "Aniversario en %d d",
        gridSharedCountFormat: "%d perfiles compartidos",
        sharedListTitle: "Compartidos contigo",
        pendingScopeEmptyMessage: "No hay ning\u{00FA}n plan de fiesta pendiente: est\u{00E1}s al d\u{00ED}a.",
        sharedScopeEmptyMessage: "Todav\u{00ED}a no est\u{00E1}s organizando nada con otras personas.",
        buyOnAmazonAction: "Comprar en Amazon",
        affiliateSectionTitle: "Afiliaci\u{00F3}n de Amazon",
        affiliateCaption: "Cada mercado de Amazon tiene su propio tag: el de amazon.es no gana nada en amazon.fr. El mercado sigue el idioma de la app, o el del dispositivo.",
        affiliateTagLabel: "Tag de afiliado",
        affiliateActiveBadge: "En uso",
        affiliateFallbackNote: "Sin tag el bot\u{00F3}n abre igualmente Amazon, pero sin comisi\u{00F3}n.",
        affiliateDisclosure: "Como Afiliado de Amazon, Kudao obtiene ingresos por las compras adscritas que cumplen los requisitos aplicables, sin coste adicional para ti",
        linkPreviewTitle: "Vista previa del enlace",
        linkPreviewBadgeLabel: "Ver el enlace antes de abrirlo",
        linkPreviewStoreLabel: "Tienda",
        linkPreviewQueryLabel: "B\u{00FA}squeda",
        linkPreviewNoTag: "Sin tag para este mercado",
        linkPreviewNoTagHint: "El enlace abre igualmente Amazon, pero no genera comisiones. A\u{00F1}ade el tag en Mi perfil \u{203A} Afiliaci\u{00F3}n de Amazon.",
        linkPreviewUrlLabel: "URL de destino",
        linkPreviewOpenAction: "Abrir en Safari",
        linkPreviewCopyAction: "Copiar enlace",
        linkPreviewCopiedLabel: "Copiado",
        linkPreviewGoogleAction: "Buscar en Google Shopping",
        libraryTitle: "Biblioteca",
        libraryEmptyTitle: "La biblioteca todav\u{00ED}a est\u{00E1} vac\u{00ED}a",
        libraryEmptyMessage: "Cuando una fecha pasa, Kudao la archiva aqu\u{00ED}: el plan, el mensaje y las fotos de ese a\u{00F1}o se quedan para siempre.",
        libraryProfileEmptyMessage: "El primer a\u{00F1}o llegar\u{00E1} a la biblioteca justo despu\u{00E9}s de la pr\u{00F3}xima fecha.",
        libraryFilterEmptyMessage: "Ning\u{00FA}n evento archivado con estos filtros.",
        libraryAllProfiles: "Todos los perfiles",
        libraryCountFormat: "%d eventos archivados",
        libraryYearsCountFormat: "%d a\u{00F1}os archivados",
        libraryPlanSection: "El plan de aquel a\u{00F1}o",
        libraryNoPlanLabel: "No se guard\u{00F3} ning\u{00FA}n plan ese a\u{00F1}o",
        librarySentBadge: "Enviado",
        libraryNotSentBadge: "Nunca enviado",
        libraryMemoriesSection: "Notas del a\u{00F1}o",
        libraryMediaSection: "Fotos y v\u{00ED}deos",
        libraryMediaCountFormat: "%d recuerdos recogidos",
        libraryNotesCountFormat: "%d notas escritas ese a\u{00F1}o",
        libraryKeywordsSection: "Lo que sab\u{00ED}amos entonces",
        libraryArchivedOnFormat: "Archivado el %@"
    )
}
