//
//  CityPlacesService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/18/25.
//

import Foundation
import GooglePlaces

public protocol CityPlacesServicing {
    func searchNearby(center: CLLocationCoordinate2D, radius: Double, category: PlaceCategory, completion: @escaping (Result<[GMSPlace], Error>) -> Void)
}

public final class CityPlacesService: CityPlacesServicing {
    private let client: GMSPlacesClient

    public init(client: GMSPlacesClient = .shared()) {
        self.client = client
    }

    public func searchNearby(center: CLLocationCoordinate2D, radius: Double, category: PlaceCategory, completion: @escaping (Result<[GMSPlace], Error>) -> Void) {
        let restriction = GMSPlaceCircularLocationOption(center, radius)
        let properties = [GMSPlaceProperty.name, GMSPlaceProperty.coordinate, GMSPlaceProperty.rating].map { $0.rawValue }
        var request = GMSPlaceSearchNearbyRequest(locationRestriction: restriction, placeProperties: properties)
        request.includedTypes = [category.rawValue]

        let callback: GMSPlaceSearchNearbyResultCallback = { results, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let places = results as? [GMSPlace] else {
                completion(.success([]))
                return
            }
            completion(.success(places))
        }
        client.searchNearby(with: request, callback: callback)
    }
}

