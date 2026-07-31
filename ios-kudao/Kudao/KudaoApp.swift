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
    @State private var biometricGate = BiometricGate.shared
    private let container: ModelContainer = KudaoModelContainer.make()

    init() {
        NotificationService.shared.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .environment(notifications)
                .environment(biometricGate)
                .environment(\.locale, settings.locale)
        }
        .modelContainer(container)
    }
}
