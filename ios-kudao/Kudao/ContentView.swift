//
//  ContentView.swift
//  Kudao
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environment(AppSettings())
        .modelContainer(for: [BirthdayProfile.self, DiaryEntry.self, DiaryTag.self], inMemory: true)
}
