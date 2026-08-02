//
//  FAQCatalog.swift
//  Kudao
//

import Foundation

/// One question and the answer to it.
nonisolated struct FAQEntry: Identifiable, Sendable, Equatable {
    let id: String
    let question: String
    let answer: String

    /// True when the text typed in the search field appears anywhere in the entry.
    func matches(_ query: String) -> Bool {
        question.localizedStandardContains(query) || answer.localizedStandardContains(query)
    }
}

/// A themed group of questions, in the order they are shown.
nonisolated struct FAQSection: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let entries: [FAQEntry]
}

/// The help content behind Settings › Frequently asked questions.
///
/// Kept out of `Strings` on purpose: these are long paragraphs that change on
/// their own schedule, and folding a hundred more fields into the main table
/// would make every language harder to proofread. Answers describe what the app
/// actually does — when one of them stops being true, the feature or the answer
/// has to change.
nonisolated enum FAQCatalog {
    static func sections(for language: AppLanguage) -> [FAQSection] {
        switch language {
        case .italian: italian
        case .english: english
        case .french: french
        case .spanish: spanish
        }
    }

    /// Total number of questions, shown as a hint under the title.
    static func count(for language: AppLanguage) -> Int {
        sections(for: language).reduce(0) { $0 + $1.entries.count }
    }

    // MARK: - Italiano

    private static let italian: [FAQSection] = [
        FAQSection(
            id: "start",
            title: "Per iniziare",
            entries: [
                FAQEntry(
                    id: "start.create",
                    question: "Come creo la mia prima occasione?",
                    answer: "Tocca il + in alto a destra nella schermata principale e scegli il tipo di occasione. Servono solo un nome e una data: foto, indirizzo, numero di telefono e note puoi aggiungerli quando vuoi, anche mesi dopo."
                ),
                FAQEntry(
                    id: "start.occasions",
                    question: "Che differenza c'e' tra i quattro tipi di occasione?",
                    answer: "Compleanno e Commemorazione seguono una data che torna ogni anno. Matrimonio e Altro seguono una data singola, con il conto alla rovescia che scorre in tempo reale. Cambiano anche i promemoria, i suggerimenti regalo e il tono dei messaggi proposti."
                ),
                FAQEntry(
                    id: "start.import",
                    question: "Posso importare i compleanni dalla rubrica?",
                    answer: "Si'. Dalla schermata principale apri il menu e scegli Importa dai contatti. Kudao mostra solo le persone che hanno una data di nascita in rubrica, tu spunti quelle che ti interessano e crei tutti i profili in un tocco solo."
                ),
                FAQEntry(
                    id: "start.duplicate",
                    question: "Rischio di importare due volte la stessa persona?",
                    answer: "No. Chi e' gia' in Kudao compare in grigio, con il segno di spunta chiuso, e non puo' essere selezionato. La lista resta completa per farti capire cosa manca davvero."
                ),
                FAQEntry(
                    id: "start.search",
                    question: "Come trovo qualcuno in una rubrica lunga?",
                    answer: "Nella schermata di importazione c'e' una barra di ricerca: scrivi il nome, il cognome, il mese oppure la data e la lista si riduce subito. Funzionano sia 'giugno' che '12/06' che l'anno di nascita."
                ),
                FAQEntry(
                    id: "start.noyear",
                    question: "E se non conosco l'anno di nascita?",
                    answer: "Nessun problema. Se in rubrica ci sono solo giorno e mese, Kudao importa comunque la persona e semplicemente non mostra l'eta'. Il promemoria arriva ogni anno come per tutti gli altri."
                ),
                FAQEntry(
                    id: "start.language",
                    question: "Come cambio la lingua dell'app?",
                    answer: "Tocca il mappamondo in alto nella schermata principale: italiano, inglese, francese e spagnolo. La scelta vale ovunque, promemoria e messaggi proposti compresi."
                ),
                FAQEntry(
                    id: "start.widget",
                    question: "Come aggiungo il widget alla schermata Home?",
                    answer: "Tieni premuto su un punto vuoto della schermata Home dell'iPhone, tocca il + in alto a sinistra, cerca Kudao e scegli la dimensione. Il widget mostra la prossima occasione e i giorni che mancano, e si aggiorna da solo."
                )
            ]
        ),
        FAQSection(
            id: "reminders",
            title: "Promemoria e notifiche",
            entries: [
                FAQEntry(
                    id: "reminders.when",
                    question: "Quando arrivano i promemoria?",
                    answer: "Nel giorno e all'ora che decidi tu. In Impostazioni, dentro Promemoria, scegli quanti giorni prima essere avvisato per ogni tipo di occasione, piu' un secondo avviso dedicato al regalo, che di solito conviene tenere piu' distante."
                ),
                FAQEntry(
                    id: "reminders.none",
                    question: "Non ricevo nessuna notifica, cosa controllo?",
                    answer: "Apri Impostazioni iPhone, poi Notifiche, poi Kudao, e verifica che siano attive. Controlla anche che non sia in corso una Full Immersion. Se al primo avvio hai negato il permesso, si riattiva solo da li'."
                ),
                FAQEntry(
                    id: "reminders.time",
                    question: "Posso avere orari diversi per persone diverse?",
                    answer: "L'orario e' uno solo e vale per tutti i promemoria: e' una scelta voluta, per non ritrovarti con avvisi sparsi in tutta la giornata. Quello che cambia per ogni occasione e' con quanti giorni di anticipo arrivano."
                ),
                FAQEntry(
                    id: "reminders.surprise",
                    question: "Cos'e' la modalita' sorpresa?",
                    answer: "Nasconde nome e dettagli di un profilo dietro Face ID e sostituisce il testo delle notifiche con una frase neutra. Serve quando stai organizzando qualcosa proprio per la persona che potrebbe guardare il tuo schermo."
                ),
                FAQEntry(
                    id: "reminders.diary",
                    question: "Cos'e' il promemoria del diario?",
                    answer: "Un invito leggero a scrivere due righe su un momento passato con quella persona, cosi' quando arriva l'occasione hai gia' qualcosa di vero da cui partire invece di una pagina bianca."
                )
            ]
        ),
        FAQSection(
            id: "sharing",
            title: "Condividere con altri",
            entries: [
                FAQEntry(
                    id: "sharing.how",
                    question: "Come organizzo qualcosa insieme ad altre persone?",
                    answer: "Apri l'occasione, tocca Condividi e manda il link a chi vuoi. Chi lo riceve entra nella stessa stanza e vede il piano, i partecipanti e la galleria. Non serve che scarichi nulla prima ne' che si registri."
                ),
                FAQEntry(
                    id: "sharing.join",
                    question: "Ho ricevuto un codice, dove lo inserisco?",
                    answer: "In Impostazioni, dentro Collaborazione, tocca Unisciti a un piano e digita il codice. Da quel momento vedi la stanza come tutti gli altri partecipanti."
                ),
                FAQEntry(
                    id: "sharing.gallery",
                    question: "Chi puo' vedere le foto della galleria?",
                    answer: "Solo chi ha il codice di quella stanza. I file stanno in uno spazio privato e vengono aperti con collegamenti che scadono dopo pochi minuti: non sono pubblici e non finiscono nei motori di ricerca."
                ),
                FAQEntry(
                    id: "sharing.remove",
                    question: "Posso togliere una foto che ho caricato?",
                    answer: "Si'. Aprila e tocca Elimina: sparisce per tutti i partecipanti, non solo per te."
                ),
                FAQEntry(
                    id: "sharing.surprise",
                    question: "Se condivido, la persona festeggiata puo' vedere il piano?",
                    answer: "Solo se le mandi tu il link. Il piano non e' pubblico e non e' collegato al suo numero o alla sua email: entra unicamente chi riceve il codice da te."
                )
            ]
        ),
        FAQSection(
            id: "premium",
            title: "Abbonamento",
            entries: [
                FAQEntry(
                    id: "premium.free",
                    question: "Cosa posso fare senza abbonamento?",
                    answer: "Compleanni e commemorazioni sono gratuiti per sempre e senza limite di numero, con promemoria, diario, galleria, messaggi e suggerimenti regalo. L'abbonamento serve per le occasioni di tipo Matrimonio e Altro."
                ),
                FAQEntry(
                    id: "premium.price",
                    question: "Quanto costa?",
                    answer: "4,99 euro al mese oppure 29,99 euro all'anno. Il pagamento passa interamente da Apple: Kudao non vede mai i dati della tua carta."
                ),
                FAQEntry(
                    id: "premium.cancel",
                    question: "Come disdico l'abbonamento?",
                    answer: "Apri Impostazioni iPhone, tocca il tuo nome in cima, poi Abbonamenti, poi Kudao, e scegli Annulla. Continui ad avere tutto fino alla fine del periodo che hai gia' pagato."
                ),
                FAQEntry(
                    id: "premium.expire",
                    question: "Se l'abbonamento scade perdo i miei dati?",
                    answer: "No, non viene cancellato niente. Le occasioni Matrimonio e Altro restano nell'app in sola lettura: le rivedi, non le modifichi. Appena rinnovi tornano attive esattamente come le avevi lasciate."
                ),
                FAQEntry(
                    id: "premium.restore",
                    question: "Ho cambiato telefono, come recupero l'abbonamento?",
                    answer: "Apri la schermata dell'abbonamento e tocca Ripristina acquisti, usando lo stesso ID Apple con cui avevi sottoscritto. Non paghi due volte."
                ),
                FAQEntry(
                    id: "premium.ads",
                    question: "Posso togliere la pubblicita'?",
                    answer: "Si', l'abbonamento la rimuove ovunque. Anche nella versione gratuita non vedrai mai pubblicita' mentre crei un profilo, scrivi nel diario o mandi un messaggio, e mai dentro una commemorazione."
                )
            ]
        ),
        FAQSection(
            id: "privacy",
            title: "Privacy e dati",
            entries: [
                FAQEntry(
                    id: "privacy.where",
                    question: "Dove finiscono le cose che scrivo?",
                    answer: "Profili, date, note e diario restano sul telefono. Escono solo in due casi: se accendi il backup o se condividi un'occasione con qualcuno. In entrambi i casi viaggiano cifrati."
                ),
                FAQEntry(
                    id: "privacy.contacts",
                    question: "Kudao carica la mia rubrica da qualche parte?",
                    answer: "No, mai. La rubrica viene letta sul telefono e solo mentre la schermata di importazione e' aperta. Restano in Kudao unicamente le persone che hai scelto tu."
                ),
                FAQEntry(
                    id: "privacy.location",
                    question: "Perche' mi viene chiesta la posizione?",
                    answer: "Solo se apri Negozi vicini, per mostrarti fioristi, pasticcerie e negozi di regali intorno a te. La posizione non viene salvata ne' inviata a nessuno, e puoi rifiutare senza perdere altro."
                ),
                FAQEntry(
                    id: "privacy.ads",
                    question: "La pubblicita' mi profila?",
                    answer: "In Europa te lo chiediamo prima, e la risposta la puoi cambiare quando vuoi da Impostazioni, nella scheda Premium. Se scegli la pubblicita' non personalizzata la vedrai lo stesso, ma senza tracciamento."
                ),
                FAQEntry(
                    id: "privacy.delete",
                    question: "Come cancello tutto quanto?",
                    answer: "Per i dati locali basta eliminare l'app. Per l'account e il backup apri Documenti e poi Le tue scelte: da li' chiedi la cancellazione definitiva e ti rispondiamo in pochi giorni lavorativi."
                )
            ]
        ),
        FAQSection(
            id: "backup",
            title: "Account e backup",
            entries: [
                FAQEntry(
                    id: "backup.why",
                    question: "Mi serve davvero un account?",
                    answer: "No. Kudao funziona per intero senza registrarsi. L'account serve a una cosa sola: ritrovare il tuo backup quando cambi telefono."
                ),
                FAQEntry(
                    id: "backup.confirm",
                    question: "Devo confermare l'email dopo la registrazione?",
                    answer: "No. L'account e' attivo subito e resti dentro l'app: nessun link da cercare nella posta, nessuna pagina da aprire nel browser."
                ),
                FAQEntry(
                    id: "backup.code",
                    question: "Cos'e' il codice di ripristino?",
                    answer: "E' la chiave che apre il tuo backup cifrato. Senza quel codice il backup e' illeggibile per chiunque, noi compresi. Conservalo dove tieni le cose importanti, non dentro l'app stessa."
                ),
                FAQEntry(
                    id: "backup.lost",
                    question: "Ho perso il codice di ripristino.",
                    answer: "Purtroppo quel backup non e' piu' recuperabile, ed e' esattamente cio' che lo rende sicuro. Se hai ancora il telefono con i dati, disattiva il backup e creane uno nuovo con un codice che questa volta metti al sicuro."
                ),
                FAQEntry(
                    id: "backup.restore",
                    question: "Come rimetto tutto su un telefono nuovo?",
                    answer: "Installa Kudao, accedi con la stessa email e inserisci il codice di ripristino. Profili, date e note tornano al loro posto."
                )
            ]
        )
    ]

    // MARK: - English

    private static let english: [FAQSection] = [
        FAQSection(
            id: "start",
            title: "Getting started",
            entries: [
                FAQEntry(
                    id: "start.create",
                    question: "How do I create my first occasion?",
                    answer: "Tap the + at the top right of the main screen and pick the kind of occasion. All you need is a name and a date: photo, address, phone number and notes can come later, even months later."
                ),
                FAQEntry(
                    id: "start.occasions",
                    question: "What is the difference between the four kinds of occasion?",
                    answer: "Birthdays and remembrances follow a date that returns every year. Weddings and Other follow a single date, with a countdown running in real time. Reminders, gift suggestions and the tone of the suggested messages change with the kind."
                ),
                FAQEntry(
                    id: "start.import",
                    question: "Can I import birthdays from my address book?",
                    answer: "Yes. Open the menu on the main screen and choose Import from contacts. Kudao only shows people who have a birthday saved, you tick the ones you want, and every profile is created in a single tap."
                ),
                FAQEntry(
                    id: "start.duplicate",
                    question: "Could I import the same person twice?",
                    answer: "No. Anyone already in Kudao appears greyed out with a sealed checkmark and cannot be selected. They stay on the list so you can see at a glance what is genuinely missing."
                ),
                FAQEntry(
                    id: "start.search",
                    question: "How do I find someone in a long address book?",
                    answer: "The import screen has a search bar: type a first name, a surname, a month or a date and the list narrows instantly. 'June', '12/06' and the birth year all work."
                ),
                FAQEntry(
                    id: "start.noyear",
                    question: "What if I do not know the birth year?",
                    answer: "That is fine. If the contact only has a day and a month, Kudao imports them anyway and simply never shows an age. The reminder still arrives every year, like everyone else's."
                ),
                FAQEntry(
                    id: "start.language",
                    question: "How do I change the language?",
                    answer: "Tap the globe at the top of the main screen: Italian, English, French and Spanish. The choice applies everywhere, including reminders and suggested messages."
                ),
                FAQEntry(
                    id: "start.widget",
                    question: "How do I add the widget to my Home Screen?",
                    answer: "Touch and hold an empty spot on your iPhone Home Screen, tap the + at the top left, search for Kudao and pick a size. The widget shows the next occasion and the days left, and refreshes on its own."
                )
            ]
        ),
        FAQSection(
            id: "reminders",
            title: "Reminders and notifications",
            entries: [
                FAQEntry(
                    id: "reminders.when",
                    question: "When do reminders arrive?",
                    answer: "On the day and at the hour you choose. Under Settings, in Reminders, you set how many days ahead to be warned for each kind of occasion, plus a separate gift reminder that usually works better further out."
                ),
                FAQEntry(
                    id: "reminders.none",
                    question: "I am not getting any notifications, what should I check?",
                    answer: "Open iPhone Settings, then Notifications, then Kudao, and make sure they are switched on. Check that no Focus is running either. If you declined the prompt on first launch, that is the only place to turn it back on."
                ),
                FAQEntry(
                    id: "reminders.time",
                    question: "Can different people have different times?",
                    answer: "There is a single time for every reminder, and that is deliberate: it keeps alerts from scattering across your whole day. What does change per occasion is how many days ahead they arrive."
                ),
                FAQEntry(
                    id: "reminders.surprise",
                    question: "What is surprise mode?",
                    answer: "It hides a profile's name and details behind Face ID and replaces the notification text with a neutral line. It is there for when you are planning something for the very person who might glance at your screen."
                ),
                FAQEntry(
                    id: "reminders.diary",
                    question: "What is the diary reminder for?",
                    answer: "A gentle nudge to write two lines about a moment you shared with that person, so that when the occasion arrives you start from something true instead of a blank page."
                )
            ]
        ),
        FAQSection(
            id: "sharing",
            title: "Sharing with others",
            entries: [
                FAQEntry(
                    id: "sharing.how",
                    question: "How do I organise something with other people?",
                    answer: "Open the occasion, tap Share and send the link to whoever you like. They land in the same room and see the plan, the participants and the gallery. They do not need to install anything first, or sign up."
                ),
                FAQEntry(
                    id: "sharing.join",
                    question: "I was given a code, where do I type it?",
                    answer: "Under Settings, in Collaboration, tap Join a plan and enter the code. From then on you see the room exactly like everyone else in it."
                ),
                FAQEntry(
                    id: "sharing.gallery",
                    question: "Who can see the photos in the gallery?",
                    answer: "Only people with that room's code. The files live in private storage and are opened through links that expire after a few minutes: nothing is public and nothing reaches search engines."
                ),
                FAQEntry(
                    id: "sharing.remove",
                    question: "Can I remove a photo I uploaded?",
                    answer: "Yes. Open it and tap Delete: it disappears for every participant, not just for you."
                ),
                FAQEntry(
                    id: "sharing.surprise",
                    question: "If I share a plan, can the guest of honour see it?",
                    answer: "Only if you send them the link yourself. The plan is not public and it is not tied to their number or their email: the only way in is the code you hand out."
                )
            ]
        ),
        FAQSection(
            id: "premium",
            title: "Subscription",
            entries: [
                FAQEntry(
                    id: "premium.free",
                    question: "What can I do without subscribing?",
                    answer: "Birthdays and remembrances are free forever, with no limit on how many, including reminders, diary, gallery, messages and gift suggestions. The subscription covers Wedding and Other occasions."
                ),
                FAQEntry(
                    id: "premium.price",
                    question: "How much does it cost?",
                    answer: "4.99 euro a month or 29.99 euro a year. Payment goes entirely through Apple: Kudao never sees your card details."
                ),
                FAQEntry(
                    id: "premium.cancel",
                    question: "How do I cancel?",
                    answer: "Open iPhone Settings, tap your name at the top, then Subscriptions, then Kudao, then Cancel. You keep everything until the end of the period you have already paid for."
                ),
                FAQEntry(
                    id: "premium.expire",
                    question: "Do I lose my data if the subscription lapses?",
                    answer: "Nothing is ever deleted. Wedding and Other occasions stay in the app, read-only: you can still look at them, you just cannot edit them. Renew and they are active again exactly as you left them."
                ),
                FAQEntry(
                    id: "premium.restore",
                    question: "I changed phone, how do I get my subscription back?",
                    answer: "Open the subscription screen and tap Restore purchases, using the same Apple ID you subscribed with. You will not be charged twice."
                ),
                FAQEntry(
                    id: "premium.ads",
                    question: "Can I remove the ads?",
                    answer: "Yes, subscribing removes them everywhere. Even on the free version you will never see an ad while creating a profile, writing in the diary or sending a message, and never inside a remembrance."
                )
            ]
        ),
        FAQSection(
            id: "privacy",
            title: "Privacy and data",
            entries: [
                FAQEntry(
                    id: "privacy.where",
                    question: "Where does everything I write end up?",
                    answer: "Profiles, dates, notes and the diary stay on your phone. They leave in two cases only: if you turn on backup, or if you share an occasion with someone. In both cases they travel encrypted."
                ),
                FAQEntry(
                    id: "privacy.contacts",
                    question: "Does Kudao upload my address book?",
                    answer: "Never. Your contacts are read on the phone and only while the import screen is open. The only people who stay in Kudao are the ones you picked."
                ),
                FAQEntry(
                    id: "privacy.location",
                    question: "Why am I asked for my location?",
                    answer: "Only if you open Nearby shops, to show florists, bakeries and gift shops around you. Your location is neither stored nor sent anywhere, and you can refuse without losing anything else."
                ),
                FAQEntry(
                    id: "privacy.ads",
                    question: "Do the ads profile me?",
                    answer: "In Europe we ask you first, and you can change your answer whenever you like from Settings, in the Premium card. Choose non-personalised ads and you still see ads, just without the tracking."
                ),
                FAQEntry(
                    id: "privacy.delete",
                    question: "How do I delete everything?",
                    answer: "For local data, deleting the app is enough. For the account and the backup, open Legal and then Your choices: ask for permanent deletion there and we answer within a few working days."
                )
            ]
        ),
        FAQSection(
            id: "backup",
            title: "Account and backup",
            entries: [
                FAQEntry(
                    id: "backup.why",
                    question: "Do I actually need an account?",
                    answer: "No. Kudao works in full without signing up. The account does one thing: it lets you find your backup again when you change phone."
                ),
                FAQEntry(
                    id: "backup.confirm",
                    question: "Do I have to confirm my email after signing up?",
                    answer: "No. The account is active straight away and you stay inside the app: no link to hunt for in your inbox, no page to open in a browser."
                ),
                FAQEntry(
                    id: "backup.code",
                    question: "What is the recovery code?",
                    answer: "It is the key that opens your encrypted backup. Without it the backup is unreadable to anyone, us included. Keep it where you keep important things, not inside the app itself."
                ),
                FAQEntry(
                    id: "backup.lost",
                    question: "I lost my recovery code.",
                    answer: "That backup cannot be recovered, and that is precisely what makes it safe. If you still have the phone holding the data, turn backup off and create a fresh one with a code you store somewhere safe this time."
                ),
                FAQEntry(
                    id: "backup.restore",
                    question: "How do I put everything back on a new phone?",
                    answer: "Install Kudao, sign in with the same email and enter your recovery code. Profiles, dates and notes return to where they were."
                )
            ]
        )
    ]

    // MARK: - Français

    private static let french: [FAQSection] = [
        FAQSection(
            id: "start",
            title: "Pour commencer",
            entries: [
                FAQEntry(
                    id: "start.create",
                    question: "Comment créer ma première occasion ?",
                    answer: "Touchez le + en haut à droite de l'écran principal et choisissez le type d'occasion. Un nom et une date suffisent : la photo, l'adresse, le téléphone et les notes peuvent venir plus tard, même des mois après."
                ),
                FAQEntry(
                    id: "start.occasions",
                    question: "Quelle différence entre les quatre types d'occasion ?",
                    answer: "Anniversaire et Commémoration suivent une date qui revient chaque année. Mariage et Autre suivent une date unique, avec un compte à rebours qui défile en temps réel. Les rappels, les idées cadeaux et le ton des messages proposés changent avec le type."
                ),
                FAQEntry(
                    id: "start.import",
                    question: "Puis-je importer les anniversaires de mes contacts ?",
                    answer: "Oui. Depuis l'écran principal, ouvrez le menu et choisissez Importer depuis les contacts. Kudao n'affiche que les personnes dont la date de naissance est enregistrée, vous cochez celles qui vous intéressent et tout est créé en un seul geste."
                ),
                FAQEntry(
                    id: "start.duplicate",
                    question: "Risque-t-on d'importer deux fois la même personne ?",
                    answer: "Non. Les personnes déjà présentes dans Kudao apparaissent en gris, avec une coche scellée, et ne peuvent pas être sélectionnées. Elles restent dans la liste pour que vous voyiez d'un coup d'œil ce qui manque vraiment."
                ),
                FAQEntry(
                    id: "start.search",
                    question: "Comment retrouver quelqu'un dans un long répertoire ?",
                    answer: "L'écran d'importation contient une barre de recherche : tapez un prénom, un nom, un mois ou une date et la liste se réduit aussitôt. « juin », « 12/06 » et l'année de naissance fonctionnent tous."
                ),
                FAQEntry(
                    id: "start.noyear",
                    question: "Et si je ne connais pas l'année de naissance ?",
                    answer: "Aucun problème. Si le contact n'a qu'un jour et un mois, Kudao l'importe quand même et n'affiche simplement jamais d'âge. Le rappel arrive chaque année, comme pour les autres."
                ),
                FAQEntry(
                    id: "start.language",
                    question: "Comment changer la langue ?",
                    answer: "Touchez le globe en haut de l'écran principal : italien, anglais, français et espagnol. Le choix s'applique partout, rappels et messages proposés compris."
                ),
                FAQEntry(
                    id: "start.widget",
                    question: "Comment ajouter le widget à l'écran d'accueil ?",
                    answer: "Appuyez longuement sur une zone vide de l'écran d'accueil de l'iPhone, touchez le + en haut à gauche, cherchez Kudao et choisissez une taille. Le widget affiche la prochaine occasion et les jours restants, et se met à jour tout seul."
                )
            ]
        ),
        FAQSection(
            id: "reminders",
            title: "Rappels et notifications",
            entries: [
                FAQEntry(
                    id: "reminders.when",
                    question: "Quand les rappels arrivent-ils ?",
                    answer: "Le jour et à l'heure que vous décidez. Dans Réglages, dans Rappels, vous choisissez combien de jours à l'avance être prévenu pour chaque type d'occasion, plus un second rappel dédié au cadeau, qu'il vaut mieux placer plus tôt."
                ),
                FAQEntry(
                    id: "reminders.none",
                    question: "Je ne reçois aucune notification, que vérifier ?",
                    answer: "Ouvrez Réglages de l'iPhone, puis Notifications, puis Kudao, et vérifiez qu'elles sont activées. Vérifiez aussi qu'aucun mode de concentration n'est actif. Si vous avez refusé au premier lancement, c'est le seul endroit pour réactiver."
                ),
                FAQEntry(
                    id: "reminders.time",
                    question: "Puis-je avoir des horaires différents selon les personnes ?",
                    answer: "L'heure est unique pour tous les rappels, et c'est volontaire : cela évite des alertes dispersées sur toute la journée. Ce qui change selon l'occasion, c'est le nombre de jours d'avance."
                ),
                FAQEntry(
                    id: "reminders.surprise",
                    question: "Qu'est-ce que le mode surprise ?",
                    answer: "Il masque le nom et les détails d'un profil derrière Face ID et remplace le texte des notifications par une phrase neutre. Utile quand vous préparez quelque chose pour la personne même qui pourrait regarder votre écran."
                ),
                FAQEntry(
                    id: "reminders.diary",
                    question: "À quoi sert le rappel du journal ?",
                    answer: "C'est une invitation discrète à écrire deux lignes sur un moment partagé avec cette personne, pour que le jour venu vous partiez de quelque chose de vrai plutôt que d'une page blanche."
                )
            ]
        ),
        FAQSection(
            id: "sharing",
            title: "Partager à plusieurs",
            entries: [
                FAQEntry(
                    id: "sharing.how",
                    question: "Comment organiser quelque chose avec d'autres ?",
                    answer: "Ouvrez l'occasion, touchez Partager et envoyez le lien à qui vous voulez. Ces personnes arrivent dans la même salle et voient le plan, les participants et la galerie. Elles n'ont rien à installer ni à créer comme compte."
                ),
                FAQEntry(
                    id: "sharing.join",
                    question: "On m'a donné un code, où le saisir ?",
                    answer: "Dans Réglages, dans Collaboration, touchez Rejoindre un plan et saisissez le code. Vous voyez ensuite la salle exactement comme les autres participants."
                ),
                FAQEntry(
                    id: "sharing.gallery",
                    question: "Qui peut voir les photos de la galerie ?",
                    answer: "Uniquement les personnes qui ont le code de cette salle. Les fichiers sont dans un espace privé et s'ouvrent via des liens qui expirent après quelques minutes : rien n'est public, rien n'atteint les moteurs de recherche."
                ),
                FAQEntry(
                    id: "sharing.remove",
                    question: "Puis-je retirer une photo que j'ai envoyée ?",
                    answer: "Oui. Ouvrez-la et touchez Supprimer : elle disparaît pour tous les participants, pas seulement pour vous."
                ),
                FAQEntry(
                    id: "sharing.surprise",
                    question: "Si je partage, la personne fêtée peut-elle voir le plan ?",
                    answer: "Seulement si vous lui envoyez le lien vous-même. Le plan n'est pas public et n'est lié ni à son numéro ni à son e-mail : la seule entrée est le code que vous distribuez."
                )
            ]
        ),
        FAQSection(
            id: "premium",
            title: "Abonnement",
            entries: [
                FAQEntry(
                    id: "premium.free",
                    question: "Que puis-je faire sans abonnement ?",
                    answer: "Les anniversaires et les commémorations sont gratuits pour toujours et sans limite de nombre, avec rappels, journal, galerie, messages et idées cadeaux. L'abonnement couvre les occasions Mariage et Autre."
                ),
                FAQEntry(
                    id: "premium.price",
                    question: "Combien ça coûte ?",
                    answer: "4,99 euros par mois ou 29,99 euros par an. Le paiement passe entièrement par Apple : Kudao ne voit jamais les données de votre carte."
                ),
                FAQEntry(
                    id: "premium.cancel",
                    question: "Comment résilier ?",
                    answer: "Ouvrez Réglages de l'iPhone, touchez votre nom en haut, puis Abonnements, puis Kudao, puis Annuler. Vous gardez tout jusqu'à la fin de la période déjà payée."
                ),
                FAQEntry(
                    id: "premium.expire",
                    question: "Si l'abonnement expire, je perds mes données ?",
                    answer: "Rien n'est supprimé. Les occasions Mariage et Autre restent dans l'application en lecture seule : vous les consultez, vous ne les modifiez plus. Dès le renouvellement, elles redeviennent actives telles quelles."
                ),
                FAQEntry(
                    id: "premium.restore",
                    question: "J'ai changé de téléphone, comment récupérer l'abonnement ?",
                    answer: "Ouvrez l'écran de l'abonnement et touchez Restaurer les achats, avec l'identifiant Apple utilisé lors de la souscription. Vous ne payez pas deux fois."
                ),
                FAQEntry(
                    id: "premium.ads",
                    question: "Puis-je supprimer la publicité ?",
                    answer: "Oui, l'abonnement la retire partout. Même sans abonnement, aucune publicité n'apparaît pendant la création d'un profil, l'écriture dans le journal ou l'envoi d'un message, ni jamais dans une commémoration."
                )
            ]
        ),
        FAQSection(
            id: "privacy",
            title: "Confidentialité et données",
            entries: [
                FAQEntry(
                    id: "privacy.where",
                    question: "Où vont les choses que j'écris ?",
                    answer: "Les profils, les dates, les notes et le journal restent sur votre téléphone. Ils ne sortent que dans deux cas : si vous activez la sauvegarde, ou si vous partagez une occasion. Dans les deux cas, ils circulent chiffrés."
                ),
                FAQEntry(
                    id: "privacy.contacts",
                    question: "Kudao envoie-t-il mon répertoire quelque part ?",
                    answer: "Jamais. Le répertoire est lu sur le téléphone, et uniquement pendant que l'écran d'importation est ouvert. Seules restent dans Kudao les personnes que vous avez choisies."
                ),
                FAQEntry(
                    id: "privacy.location",
                    question: "Pourquoi me demande-t-on ma position ?",
                    answer: "Uniquement si vous ouvrez Boutiques à proximité, pour afficher fleuristes, pâtisseries et boutiques de cadeaux autour de vous. La position n'est ni conservée ni transmise, et vous pouvez refuser sans rien perdre d'autre."
                ),
                FAQEntry(
                    id: "privacy.ads",
                    question: "La publicité me profile-t-elle ?",
                    answer: "En Europe, nous vous le demandons d'abord, et vous pouvez changer d'avis quand vous voulez depuis Réglages, dans la carte Premium. En choisissant la publicité non personnalisée, vous en voyez toujours, mais sans suivi."
                ),
                FAQEntry(
                    id: "privacy.delete",
                    question: "Comment tout supprimer ?",
                    answer: "Pour les données locales, supprimer l'application suffit. Pour le compte et la sauvegarde, ouvrez Documents puis Vos choix : demandez-y la suppression définitive, nous répondons en quelques jours ouvrés."
                )
            ]
        ),
        FAQSection(
            id: "backup",
            title: "Compte et sauvegarde",
            entries: [
                FAQEntry(
                    id: "backup.why",
                    question: "Ai-je vraiment besoin d'un compte ?",
                    answer: "Non. Kudao fonctionne entièrement sans inscription. Le compte sert à une seule chose : retrouver votre sauvegarde quand vous changez de téléphone."
                ),
                FAQEntry(
                    id: "backup.confirm",
                    question: "Dois-je confirmer mon e-mail après l'inscription ?",
                    answer: "Non. Le compte est actif immédiatement et vous restez dans l'application : aucun lien à chercher dans votre boîte, aucune page à ouvrir dans le navigateur."
                ),
                FAQEntry(
                    id: "backup.code",
                    question: "Qu'est-ce que le code de récupération ?",
                    answer: "C'est la clé qui ouvre votre sauvegarde chiffrée. Sans lui, la sauvegarde est illisible pour tout le monde, nous compris. Rangez-le là où vous rangez les choses importantes, pas dans l'application."
                ),
                FAQEntry(
                    id: "backup.lost",
                    question: "J'ai perdu mon code de récupération.",
                    answer: "Cette sauvegarde n'est plus récupérable, et c'est précisément ce qui la rend sûre. Si vous avez encore le téléphone contenant les données, désactivez la sauvegarde et recréez-en une avec un code mis à l'abri cette fois."
                ),
                FAQEntry(
                    id: "backup.restore",
                    question: "Comment tout remettre sur un nouveau téléphone ?",
                    answer: "Installez Kudao, connectez-vous avec la même adresse e-mail et saisissez le code de récupération. Profils, dates et notes reprennent leur place."
                )
            ]
        )
    ]

    // MARK: - Español

    private static let spanish: [FAQSection] = [
        FAQSection(
            id: "start",
            title: "Para empezar",
            entries: [
                FAQEntry(
                    id: "start.create",
                    question: "¿Cómo creo mi primera ocasión?",
                    answer: "Toca el + arriba a la derecha en la pantalla principal y elige el tipo de ocasión. Bastan un nombre y una fecha: la foto, la dirección, el teléfono y las notas puedes añadirlos cuando quieras, incluso meses después."
                ),
                FAQEntry(
                    id: "start.occasions",
                    question: "¿Qué diferencia hay entre los cuatro tipos de ocasión?",
                    answer: "Cumpleaños y Conmemoración siguen una fecha que vuelve cada año. Boda y Otro siguen una fecha única, con la cuenta atrás corriendo en tiempo real. También cambian los recordatorios, las ideas de regalo y el tono de los mensajes propuestos."
                ),
                FAQEntry(
                    id: "start.import",
                    question: "¿Puedo importar los cumpleaños de mi agenda?",
                    answer: "Sí. En la pantalla principal abre el menú y elige Importar de contactos. Kudao solo muestra a las personas que tienen fecha de nacimiento guardada, marcas las que te interesan y se crean todos los perfiles de una vez."
                ),
                FAQEntry(
                    id: "start.duplicate",
                    question: "¿Puedo importar dos veces a la misma persona?",
                    answer: "No. Quien ya está en Kudao aparece en gris, con la marca cerrada, y no se puede seleccionar. Sigue en la lista para que veas de un vistazo lo que falta de verdad."
                ),
                FAQEntry(
                    id: "start.search",
                    question: "¿Cómo encuentro a alguien en una agenda larga?",
                    answer: "La pantalla de importación tiene una barra de búsqueda: escribe un nombre, un apellido, un mes o una fecha y la lista se reduce al instante. Funcionan «junio», «12/06» y el año de nacimiento."
                ),
                FAQEntry(
                    id: "start.noyear",
                    question: "¿Y si no sé el año de nacimiento?",
                    answer: "No pasa nada. Si el contacto solo tiene día y mes, Kudao lo importa igualmente y sencillamente nunca muestra la edad. El recordatorio llega cada año, como con los demás."
                ),
                FAQEntry(
                    id: "start.language",
                    question: "¿Cómo cambio el idioma?",
                    answer: "Toca el globo terráqueo en la parte superior de la pantalla principal: italiano, inglés, francés y español. La elección vale para todo, recordatorios y mensajes propuestos incluidos."
                ),
                FAQEntry(
                    id: "start.widget",
                    question: "¿Cómo añado el widget a la pantalla de inicio?",
                    answer: "Mantén pulsado un hueco vacío de la pantalla de inicio del iPhone, toca el + arriba a la izquierda, busca Kudao y elige el tamaño. El widget muestra la próxima ocasión y los días que faltan, y se actualiza solo."
                )
            ]
        ),
        FAQSection(
            id: "reminders",
            title: "Recordatorios y avisos",
            entries: [
                FAQEntry(
                    id: "reminders.when",
                    question: "¿Cuándo llegan los recordatorios?",
                    answer: "El día y a la hora que decidas tú. En Ajustes, dentro de Recordatorios, eliges con cuántos días de antelación quieres el aviso para cada tipo de ocasión, más un segundo aviso dedicado al regalo, que conviene poner antes."
                ),
                FAQEntry(
                    id: "reminders.none",
                    question: "No recibo ninguna notificación, ¿qué reviso?",
                    answer: "Abre Ajustes del iPhone, luego Notificaciones, luego Kudao, y comprueba que estén activadas. Mira también que no haya un modo de concentración en marcha. Si lo rechazaste al principio, solo se reactiva desde ahí."
                ),
                FAQEntry(
                    id: "reminders.time",
                    question: "¿Puedo tener horas distintas para personas distintas?",
                    answer: "La hora es única para todos los recordatorios, y es a propósito: evita que los avisos se dispersen por todo el día. Lo que sí cambia según la ocasión es con cuántos días de antelación llegan."
                ),
                FAQEntry(
                    id: "reminders.surprise",
                    question: "¿Qué es el modo sorpresa?",
                    answer: "Oculta el nombre y los detalles de un perfil tras Face ID y sustituye el texto de las notificaciones por una frase neutra. Sirve cuando preparas algo justo para la persona que podría mirar tu pantalla."
                ),
                FAQEntry(
                    id: "reminders.diary",
                    question: "¿Para qué sirve el recordatorio del diario?",
                    answer: "Es una invitación suave a escribir dos líneas sobre un momento compartido con esa persona, para que cuando llegue la ocasión partas de algo verdadero y no de una página en blanco."
                )
            ]
        ),
        FAQSection(
            id: "sharing",
            title: "Compartir con otros",
            entries: [
                FAQEntry(
                    id: "sharing.how",
                    question: "¿Cómo organizo algo con otras personas?",
                    answer: "Abre la ocasión, toca Compartir y envía el enlace a quien quieras. Entran en la misma sala y ven el plan, los participantes y la galería. No necesitan instalar nada antes ni registrarse."
                ),
                FAQEntry(
                    id: "sharing.join",
                    question: "Me han dado un código, ¿dónde lo escribo?",
                    answer: "En Ajustes, dentro de Colaboración, toca Unirse a un plan y escribe el código. A partir de ese momento ves la sala igual que el resto de participantes."
                ),
                FAQEntry(
                    id: "sharing.gallery",
                    question: "¿Quién puede ver las fotos de la galería?",
                    answer: "Solo quien tenga el código de esa sala. Los archivos están en un espacio privado y se abren con enlaces que caducan a los pocos minutos: nada es público ni llega a los buscadores."
                ),
                FAQEntry(
                    id: "sharing.remove",
                    question: "¿Puedo quitar una foto que he subido?",
                    answer: "Sí. Ábrela y toca Eliminar: desaparece para todos los participantes, no solo para ti."
                ),
                FAQEntry(
                    id: "sharing.surprise",
                    question: "Si comparto, ¿puede ver el plan la persona homenajeada?",
                    answer: "Solo si le envías tú el enlace. El plan no es público ni está vinculado a su número o su correo: la única entrada es el código que repartes."
                )
            ]
        ),
        FAQSection(
            id: "premium",
            title: "Suscripción",
            entries: [
                FAQEntry(
                    id: "premium.free",
                    question: "¿Qué puedo hacer sin suscripción?",
                    answer: "Los cumpleaños y las conmemoraciones son gratis para siempre y sin límite de cantidad, con recordatorios, diario, galería, mensajes e ideas de regalo. La suscripción cubre las ocasiones de tipo Boda y Otro."
                ),
                FAQEntry(
                    id: "premium.price",
                    question: "¿Cuánto cuesta?",
                    answer: "4,99 euros al mes o 29,99 euros al año. El pago pasa íntegramente por Apple: Kudao nunca ve los datos de tu tarjeta."
                ),
                FAQEntry(
                    id: "premium.cancel",
                    question: "¿Cómo cancelo la suscripción?",
                    answer: "Abre Ajustes del iPhone, toca tu nombre arriba, luego Suscripciones, luego Kudao, y elige Cancelar. Conservas todo hasta el final del periodo que ya has pagado."
                ),
                FAQEntry(
                    id: "premium.expire",
                    question: "Si la suscripción caduca, ¿pierdo mis datos?",
                    answer: "No se borra nada. Las ocasiones de Boda y Otro siguen en la app en modo solo lectura: las consultas, pero no las editas. En cuanto renueves vuelven a estar activas tal y como las dejaste."
                ),
                FAQEntry(
                    id: "premium.restore",
                    question: "He cambiado de teléfono, ¿cómo recupero la suscripción?",
                    answer: "Abre la pantalla de la suscripción y toca Restaurar compras, con el mismo ID de Apple con el que te suscribiste. No pagas dos veces."
                ),
                FAQEntry(
                    id: "premium.ads",
                    question: "¿Puedo quitar la publicidad?",
                    answer: "Sí, la suscripción la retira en todas partes. Incluso en la versión gratuita nunca verás publicidad mientras creas un perfil, escribes en el diario o envías un mensaje, ni nunca dentro de una conmemoración."
                )
            ]
        ),
        FAQSection(
            id: "privacy",
            title: "Privacidad y datos",
            entries: [
                FAQEntry(
                    id: "privacy.where",
                    question: "¿Dónde acaban las cosas que escribo?",
                    answer: "Los perfiles, las fechas, las notas y el diario se quedan en tu teléfono. Solo salen en dos casos: si activas la copia de seguridad o si compartes una ocasión. En ambos viajan cifrados."
                ),
                FAQEntry(
                    id: "privacy.contacts",
                    question: "¿Kudao sube mi agenda a algún sitio?",
                    answer: "Nunca. La agenda se lee en el teléfono y solo mientras la pantalla de importación está abierta. En Kudao se quedan únicamente las personas que has elegido tú."
                ),
                FAQEntry(
                    id: "privacy.location",
                    question: "¿Por qué se me pide la ubicación?",
                    answer: "Solo si abres Tiendas cercanas, para mostrarte floristerías, pastelerías y tiendas de regalos a tu alrededor. La ubicación no se guarda ni se envía a nadie, y puedes negarte sin perder nada más."
                ),
                FAQEntry(
                    id: "privacy.ads",
                    question: "¿La publicidad me perfila?",
                    answer: "En Europa te lo preguntamos antes, y puedes cambiar la respuesta cuando quieras desde Ajustes, en la tarjeta Premium. Si eliges publicidad no personalizada la seguirás viendo, pero sin seguimiento."
                ),
                FAQEntry(
                    id: "privacy.delete",
                    question: "¿Cómo lo borro todo?",
                    answer: "Para los datos locales basta con eliminar la app. Para la cuenta y la copia de seguridad abre Documentos y luego Tus opciones: pide allí la eliminación definitiva y respondemos en pocos días laborables."
                )
            ]
        ),
        FAQSection(
            id: "backup",
            title: "Cuenta y copia de seguridad",
            entries: [
                FAQEntry(
                    id: "backup.why",
                    question: "¿Necesito de verdad una cuenta?",
                    answer: "No. Kudao funciona por completo sin registrarse. La cuenta sirve para una sola cosa: recuperar tu copia de seguridad cuando cambies de teléfono."
                ),
                FAQEntry(
                    id: "backup.confirm",
                    question: "¿Tengo que confirmar el correo después de registrarme?",
                    answer: "No. La cuenta queda activa al momento y te quedas dentro de la app: ningún enlace que buscar en el buzón, ninguna página que abrir en el navegador."
                ),
                FAQEntry(
                    id: "backup.code",
                    question: "¿Qué es el código de recuperación?",
                    answer: "Es la llave que abre tu copia cifrada. Sin él la copia es ilegible para cualquiera, nosotros incluidos. Guárdalo donde guardas las cosas importantes, no dentro de la propia app."
                ),
                FAQEntry(
                    id: "backup.lost",
                    question: "He perdido el código de recuperación.",
                    answer: "Esa copia ya no se puede recuperar, y eso es justamente lo que la hace segura. Si aún tienes el teléfono con los datos, desactiva la copia y crea una nueva con un código que esta vez pongas a salvo."
                ),
                FAQEntry(
                    id: "backup.restore",
                    question: "¿Cómo lo devuelvo todo a un teléfono nuevo?",
                    answer: "Instala Kudao, inicia sesión con el mismo correo e introduce el código de recuperación. Perfiles, fechas y notas vuelven a su sitio."
                )
            ]
        )
    ]
}
