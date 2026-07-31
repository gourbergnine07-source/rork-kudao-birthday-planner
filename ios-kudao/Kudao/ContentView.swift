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
        .environment(BiometricGate.shared)
        .environment(KudaoIdentity.shared)
        .environment(CollaborationService())
        .modelContainer(KudaoModelContainer.preview())
}
