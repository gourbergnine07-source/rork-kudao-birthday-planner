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

    let relFriend: String
    let relFamily: String
    let relPartner: String
    let relColleague: String

    let todayTitle: String
    let tomorrowLabel: String
    let dayUnit: String
    let daysUnit: String
    let daysToGo: String
    let turnsFormat: String
    let turnsTodayFormat: String
    let nextBirthdayLabel: String

    let diaryTab: String
    let suggestionsTab: String
    let diaryEmptyTitle: String
    let diaryEmptyMessage: String
    let suggestionsEmptyTitle: String
    let suggestionsEmptyMessage: String
    let comingSoon: String

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
        relFriend: "Amico",
        relFamily: "Famiglia",
        relPartner: "Partner",
        relColleague: "Collega",
        todayTitle: "È oggi!",
        tomorrowLabel: "Domani",
        dayUnit: "giorno",
        daysUnit: "giorni",
        daysToGo: "al compleanno",
        turnsFormat: "Compie %d anni",
        turnsTodayFormat: "Compie %d anni oggi",
        nextBirthdayLabel: "Prossimo compleanno",
        diaryTab: "Diario",
        suggestionsTab: "Suggerimenti",
        diaryEmptyTitle: "Diario vuoto",
        diaryEmptyMessage: "Qui annoterai i gusti, i desideri e i dettagli che noti durante l'anno.",
        suggestionsEmptyTitle: "Ancora nessun suggerimento",
        suggestionsEmptyMessage: "Regalo, torta, locale e numero di invitati appariranno qui in base al diario.",
        comingSoon: "Presto disponibile",
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
        relFriend: "Friend",
        relFamily: "Family",
        relPartner: "Partner",
        relColleague: "Colleague",
        todayTitle: "It's today!",
        tomorrowLabel: "Tomorrow",
        dayUnit: "day",
        daysUnit: "days",
        daysToGo: "to the birthday",
        turnsFormat: "Turning %d",
        turnsTodayFormat: "Turning %d today",
        nextBirthdayLabel: "Next birthday",
        diaryTab: "Diary",
        suggestionsTab: "Suggestions",
        diaryEmptyTitle: "Empty diary",
        diaryEmptyMessage: "This is where you'll note tastes, wishes and details you spot during the year.",
        suggestionsEmptyTitle: "No suggestions yet",
        suggestionsEmptyMessage: "Gift, cake, venue and guest count will show up here based on your diary.",
        comingSoon: "Coming soon",
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
        relFriend: "Ami",
        relFamily: "Famille",
        relPartner: "Partenaire",
        relColleague: "Collègue",
        todayTitle: "C'est aujourd'hui !",
        tomorrowLabel: "Demain",
        dayUnit: "jour",
        daysUnit: "jours",
        daysToGo: "avant l'anniversaire",
        turnsFormat: "Fête ses %d ans",
        turnsTodayFormat: "Fête ses %d ans aujourd'hui",
        nextBirthdayLabel: "Prochain anniversaire",
        diaryTab: "Journal",
        suggestionsTab: "Suggestions",
        diaryEmptyTitle: "Journal vide",
        diaryEmptyMessage: "Vous noterez ici les goûts, les envies et les détails repérés pendant l'année.",
        suggestionsEmptyTitle: "Pas encore de suggestions",
        suggestionsEmptyMessage: "Cadeau, gâteau, lieu et nombre d'invités apparaîtront ici grâce au journal.",
        comingSoon: "Bientôt disponible",
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
        relFriend: "Amigo",
        relFamily: "Familia",
        relPartner: "Pareja",
        relColleague: "Colega",
        todayTitle: "¡Es hoy!",
        tomorrowLabel: "Mañana",
        dayUnit: "día",
        daysUnit: "días",
        daysToGo: "para el cumpleaños",
        turnsFormat: "Cumple %d años",
        turnsTodayFormat: "Cumple %d años hoy",
        nextBirthdayLabel: "Próximo cumpleaños",
        diaryTab: "Diario",
        suggestionsTab: "Sugerencias",
        diaryEmptyTitle: "Diario vacío",
        diaryEmptyMessage: "Aquí anotarás los gustos, los deseos y los detalles que descubras durante el año.",
        suggestionsEmptyTitle: "Todavía no hay sugerencias",
        suggestionsEmptyMessage: "Regalo, tarta, local y número de invitados aparecerán aquí según tu diario.",
        comingSoon: "Muy pronto",
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
