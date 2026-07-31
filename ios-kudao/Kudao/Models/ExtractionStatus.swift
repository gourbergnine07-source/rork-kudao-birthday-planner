//
//  ExtractionStatus.swift
//  Kudao
//

import Foundation

/// Lifecycle of the background AI extraction attached to a diary note.
nonisolated enum ExtractionStatus: String, Codable, Sendable {
    case pending
    case ready
    case failed
}
