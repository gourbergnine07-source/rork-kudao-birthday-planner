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
    @State private var identity = KudaoIdentity.shared
    @State private var collaboration = CollaborationService()
    @State private var backup = CloudBackupService()
    @State private var auth = AuthService()
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
                .environment(identity)
                .environment(collaboration)
                .environment(backup)
                .environment(auth)
                .environment(\.locale, settings.locale)
        }
        .modelContainer(container)
    }
}
