//
//  WidgetStrings.swift
//  KudaoWidget
//
//  Minimal string table for the widget, keyed by the language code stored in the
//  snapshot so the widget follows the language picked inside the app.
//

import Foundation

nonisolated struct WidgetStrings: Sendable {
    let dayUnit: String
    let daysUnit: String
    let toGo: String
    let today: String
    let tomorrow: String
    let nextUp: String
    let emptyTitle: String
    let emptyMessage: String
    let turnsFormat: String
    let displayName: String
    let description: String

    static func table(for code: String) -> WidgetStrings {
        switch code {
        case "en": english
        case "fr": french
        case "es": spanish
        default: italian
        }
    }

    static let italian = WidgetStrings(
        dayUnit: "giorno",
        daysUnit: "giorni",
        toGo: "al compleanno",
        today: "È oggi!",
        tomorrow: "Domani",
        nextUp: "Il prossimo",
        emptyTitle: "Nessun festeggiato",
        emptyMessage: "Aggiungi un profilo in Kudao",
        turnsFormat: "compie %d",
        displayName: "Conto alla rovescia",
        description: "Il compleanno più vicino, sempre sotto controllo."
    )

    static let english = WidgetStrings(
        dayUnit: "day",
        daysUnit: "days",
        toGo: "to the birthday",
        today: "It's today!",
        tomorrow: "Tomorrow",
        nextUp: "Up next",
        emptyTitle: "No birthdays yet",
        emptyMessage: "Add a profile in Kudao",
        turnsFormat: "turns %d",
        displayName: "Countdown",
        description: "The closest birthday, always in sight."
    )

    static let french = WidgetStrings(
        dayUnit: "jour",
        daysUnit: "jours",
        toGo: "avant l'anniversaire",
        today: "C'est aujourd'hui !",
        tomorrow: "Demain",
        nextUp: "Le prochain",
        emptyTitle: "Aucun anniversaire",
        emptyMessage: "Ajoutez un profil dans Kudao",
        turnsFormat: "fête ses %d ans",
        displayName: "Compte à rebours",
        description: "L'anniversaire le plus proche, toujours visible."
    )

    static let spanish = WidgetStrings(
        dayUnit: "día",
        daysUnit: "días",
        toGo: "para el cumpleaños",
        today: "¡Es hoy!",
        tomorrow: "Mañana",
        nextUp: "El próximo",
        emptyTitle: "Sin cumpleaños",
        emptyMessage: "Añade un perfil en Kudao",
        turnsFormat: "cumple %d",
        displayName: "Cuenta atrás",
        description: "El cumpleaños más cercano, siempre a la vista."
    )
}
