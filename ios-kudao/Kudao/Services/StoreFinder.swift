//
//  StoreFinder.swift
//  Kudao
//

import CoreLocation
import Foundation
import MapKit
import Observation
import OSLog
import UIKit

/// One shop returned by the map search, already measured against the user.
struct NearbyStore: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    /// Straight-line metres between the user and the shop.
    let distance: CLLocationDistance
    let street: String?
    let mapItem: MKMapItem

    static func == (lhs: NearbyStore, rhs: NearbyStore) -> Bool { lhs.id == rhs.id }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// "1,2 km" or "480 m", localized by the caller's format strings.
    func distanceLabel(_ strings: Strings) -> String {
        if distance < 1_000 {
            return String(format: strings.distanceMetersFormat, Int(distance.rounded()))
        }
        return String(format: strings.distanceKmFormat, distance / 1_000)
    }
}

/// Finds shops that sell the AI-suggested gift category around the user.
@Observable
final class StoreFinder {
    /// Search radius requested by the product spec.
    static let radius: CLLocationDistance = 5_000

    enum Phase: Equatable {
        case idle
        case locating
        case searching
        case results
        case empty
        case denied
        case failed
    }

    private let logger = Logger(subsystem: "com.kudao.app", category: "store-finder")
    private let manager = CLLocationManager()
    private var task: Task<Void, Never>?

    private(set) var phase: Phase = .idle
    private(set) var stores: [NearbyStore] = []
    private(set) var userCoordinate: CLLocationCoordinate2D?
    private(set) var query: String = ""

    var isBusy: Bool { phase == .locating || phase == .searching }

    /// Locates the user, then searches shops of `category` within 5 km.
    func search(category: String, language: AppLanguage) {
        let trimmed = category.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            phase = .failed
            return
        }

        task?.cancel()
        query = trimmed
        stores = []
        phase = .locating

        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            phase = .denied
            return
        }

        task = Task { [weak self] in
            guard let self else { return }
            do {
                guard let coordinate = try await self.currentCoordinate() else { return }
                guard !Task.isCancelled else { return }
                self.userCoordinate = coordinate
                self.phase = .searching
                try await self.runSearch(around: coordinate, query: trimmed, language: language)
            } catch is CancellationError {
                return
            } catch {
                self.logger.error("Store search failed: \(error.localizedDescription, privacy: .public)")
                self.phase = .failed
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Location

    /// First usable fix from the live updates stream, or nil when permission is refused.
    private func currentCoordinate() async throws -> CLLocationCoordinate2D? {
        for try await update in CLLocationUpdate.liveUpdates(.default) {
            if Task.isCancelled { return nil }

            if update.authorizationDenied || update.authorizationDeniedGlobally {
                phase = .denied
                return nil
            }
            if update.authorizationRequestInProgress || update.locationUnavailable {
                continue
            }
            if let location = update.location {
                return location.coordinate
            }
        }
        return nil
    }

    // MARK: - Map search

    private func runSearch(
        around coordinate: CLLocationCoordinate2D,
        query: String,
        language: AppLanguage
    ) async throws {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: Self.radius * 2,
            longitudinalMeters: Self.radius * 2
        )

        let response = try await MKLocalSearch(request: request).start()
        guard !Task.isCancelled else { return }

        let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let found = response.mapItems.compactMap { item -> NearbyStore? in
            guard let itemLocation = item.placemark.location else { return nil }
            let distance = origin.distance(from: itemLocation)
            guard distance <= Self.radius else { return nil }
            return NearbyStore(
                name: item.name ?? query,
                coordinate: itemLocation.coordinate,
                distance: distance,
                street: item.placemark.thoroughfare,
                mapItem: item
            )
        }
        .sorted { $0.distance < $1.distance }

        stores = Array(found.prefix(20))
        phase = stores.isEmpty ? .empty : .results
    }
}
