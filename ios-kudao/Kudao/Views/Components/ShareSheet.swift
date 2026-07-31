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

/// Native share sheet used to hand a file or a piece of text to the system.
struct ShareSheet: UIViewControllerRepresentable {
    private let items: [Any]

    init(url: URL) {
        items = [url]
    }

    init(text: String) {
        items = [text]
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
