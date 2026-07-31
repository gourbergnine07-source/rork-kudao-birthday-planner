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
        notificationMessageBodyFormat: "\u{00C8} il momento di augurare buon compleanno a %@!"
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
        notificationMessageBodyFormat: "It\u{2019}s time to wish %@ a happy birthday!"
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
        notificationMessageBodyFormat: "C\u{2019}est le moment de souhaiter un joyeux anniversaire \u{00E0} %@ !"
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
        notificationMessageBodyFormat: "\u{00A1}Es el momento de felicitar a %@ por su cumplea\u{00F1}os!"
    )
}
