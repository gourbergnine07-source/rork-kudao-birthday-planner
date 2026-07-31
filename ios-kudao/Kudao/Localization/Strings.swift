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
        distanceMetersFormat: "%d m"
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
        distanceMetersFormat: "%d m"
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
        distanceMetersFormat: "%d m"
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
        distanceMetersFormat: "%d m"
    )
}
