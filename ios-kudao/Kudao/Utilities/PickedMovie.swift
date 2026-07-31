//
//  PickedMovie.swift
//  Kudao
//

import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// Lets `PhotosPicker` hand a video over as a file Kudao can transcode.
///
/// Photos vends movies as files, never as in-memory data, so the import step
/// copies the clip into the temporary directory and passes the copy along.
nonisolated struct PickedMovie: Transferable, Sendable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = FileManager.default.temporaryDirectory
                .appendingPathComponent("kudao-pick-\(UUID().uuidString).mov")
            try? FileManager.default.removeItem(at: copy)
            try FileManager.default.copyItem(at: received.file, to: copy)
            return PickedMovie(url: copy)
        }
    }
}
