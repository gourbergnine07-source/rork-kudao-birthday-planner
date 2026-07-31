//
//  ShareSheet.swift
//  Kudao
//

import SwiftUI
import UIKit

/// Wraps a generated file so it can drive an `item:` presentation.
nonisolated struct ExportedFile: Identifiable, Equatable, Sendable {
    let id: UUID = UUID()
    let url: URL
}

/// Native share sheet used to hand the exported diary file to the system.
struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
