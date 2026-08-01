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
    @State private var subscriptions: SubscriptionService
    private let container: ModelContainer = KudaoModelContainer.make()

    @Environment(\.scenePhase) private var scenePhase

    init() {
        NotificationService.shared.bootstrap()
        // The service reads its state from a configured SDK, so the SDK has to
        // come first: a stored-property initializer would run too early.
        SubscriptionService.configure()
        _subscriptions = State(initialValue: SubscriptionService())
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
                .environment(subscriptions)
                .environment(\.locale, settings.locale)
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, phase in
            // An expiry or a renewal can happen while Kudao is in the
            // background, including from the App Store's own subscription page.
            if phase == .active {
                Task { await subscriptions.refresh() }
            }
        }
    }
}
