//
//  KudaoApp.swift
//  Kudao
//

import SwiftUI
import SwiftData

@main
struct KudaoApp: App {
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .environment(\.locale, settings.locale)
        }
        .modelContainer(for: [BirthdayProfile.self, DiaryEntry.self])
    }
}
