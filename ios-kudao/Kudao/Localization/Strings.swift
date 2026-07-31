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
        ageNowFormat: "%d anni"
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
        ageNowFormat: "%d years old"
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
        ageNowFormat: "%d ans"
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
        ageNowFormat: "%d años"
    )
}
