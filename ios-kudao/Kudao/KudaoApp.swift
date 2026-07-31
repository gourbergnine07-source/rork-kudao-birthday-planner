//
//  KudaoApp.swift
//  Kudao
//

import SwiftUI
import SwiftData

@main
struct KudaoApp: App {
    @State private var settings = AppSettings()
    private let container: ModelContainer = KudaoModelContainer.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .environment(\.locale, settings.locale)
        }
        .modelContainer(container)
    }
}
