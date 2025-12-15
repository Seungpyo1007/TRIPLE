//
//  SearchViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
#if canImport(GooglePlaces)
import GooglePlaces
#endif
import UIKit


final class SearchViewModel {
    private(set) var results: [PlaceItem] = [] {
        didSet { onResultsChanged?(results) }
    }
    var onResultsChanged: (([PlaceItem]) -> Void)?
    
    private var imageCache: [String: UIImage] = [:]

    // MARK: - Search
    func search(text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            results = []
            return
        }

        #if canImport(GooglePlaces)
        let myProperties = [GMSPlaceProperty.name, GMSPlaceProperty.placeID, GMSPlaceProperty.rating].map { $0.rawValue }
        let request = GMSPlaceSearchByTextRequest(textQuery: query, placeProperties: myProperties)
        request.includedType = kGMSPlaceTypeCountry // e.g., "restaurant"
        request.maxResultCount = 20
        request.rankPreference = GMSPlaceSearchByTextRankPreference.distance
        request.isStrictTypeFiltering = false
        // Optional: center bias (NYC example commented)
        // request.locationBias = GMSPlaceCircularLocationOption(CLLocationCoordinate2D(latitude: 40.7, longitude: -74.0), 200.0)

        let callback: GMSPlaceSearchByTextResultCallback = { [weak self] results, error in
            guard let self = self else { return }
            if let error = error {
                print("Places search error: \(error.localizedDescription)")
                DispatchQueue.main.async { self.results = [] }
                return
            }
            guard let gmsResults = results else {
                DispatchQueue.main.async { self.results = [] }
                return
            }
            let mapped: [PlaceItem] = gmsResults.map { place in
                let coord = Optional(place.coordinate)
                return PlaceItem(id: place.placeID ?? UUID().uuidString,
                                 name: place.name ?? "Unknown",
                                 coordinate: coord,
                                 rating: Double(place.rating))
            }
            DispatchQueue.main.async { self.results = mapped }
        }

        GMSPlacesClient.shared().searchByText(with: request, callback: callback)
        #else
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.results = []
        }
        #endif
    }
    
    // MARK: - Photos
    func fetchFirstPhoto(placeID: String, maxSize: CGSize = CGSize(width: 200, height: 200), completion: @escaping (UIImage?) -> Void) {
        // Return cached image if available
        if let cached = imageCache[placeID] {
            completion(cached)
            return
        }

        #if canImport(GooglePlaces)
        let client = GMSPlacesClient.shared()
        client.lookUpPhotos(forPlaceID: placeID) { [weak self] (photos, error) in
            guard error == nil else {
                print("[Search] lookUpPhotos error: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            guard let meta = photos?.results.first else {
                completion(nil)
                return
            }
            let request = GMSFetchPhotoRequest(photoMetadata: meta, maxSize: maxSize)
            client.fetchPhoto(with: request) { (image, error) in
                if let error = error {
                    print("[Search] fetchPhoto error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                if let image = image {
                    self?.imageCache[placeID] = image
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
        #else
        completion(nil)
        #endif
    }
}
