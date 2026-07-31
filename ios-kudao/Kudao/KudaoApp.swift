//
//  KudaoApp.swift
//  Kudao
//

import SwiftUI
import SwiftData

@main
struct KudaoApp: App {
    @State private var settings = AppSettings()
    @State private var notifications = NotificationService.shared
    private let container: ModelContainer = KudaoModelContainer.make()

    init() {
        NotificationService.shared.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .environment(notifications)
                .environment(\.locale, settings.locale)
        }
        .modelContainer(container)
    }
}
