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
    @State private var ads = AdsService()
    private let container: ModelContainer = KudaoModelContainer.make()

    @Environment(\.scenePhase) private var scenePhase

    init() {
        Self.logAdMobIdentifier()
        NotificationService.shared.bootstrap()
        // The service reads its state from a configured SDK, so the SDK has to
        // come first: a stored-property initializer would run too early.
        SubscriptionService.configure()
        _subscriptions = State(initialValue: SubscriptionService())
    }

    /// The Google Mobile Ads SDK checks `GADApplicationIdentifier` as soon as its
    /// framework loads and terminates the process when the key is absent, so a
    /// bundle that lost it must be obvious in the very first log line.
    private static func logAdMobIdentifier() {
        let identifier = Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String
        print("[Kudao] GADApplicationIdentifier: \(identifier ?? "MISSING")")
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
                .environment(ads)
                .environment(\.locale, settings.locale)
                .task {
                    // Consent first, then the SDK. Subscribers never get here.
                    guard !subscriptions.isPremium else { return }
                    await ads.start()
                }
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, phase in
            // An expiry or a renewal can happen while Kudao is in the
            // background, including from the App Store's own subscription page.
            switch phase {
            case .active:
                Task {
                    await subscriptions.refresh()
                    // At most one full-screen ad per session, and only on a
                    // real return — never mid-task, never for subscribers.
                    ads.noteBecameActive(isPremium: subscriptions.isPremium)
                }
            case .background:
                ads.noteEnteredBackground()
            default:
                break
            }
        }
    }
}
