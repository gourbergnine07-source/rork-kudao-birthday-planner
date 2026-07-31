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
        .environment(NotificationService.shared)
        .modelContainer(KudaoModelContainer.preview())
}
