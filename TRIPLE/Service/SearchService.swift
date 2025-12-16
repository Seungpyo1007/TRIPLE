//
//  SearchService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import Foundation
#if canImport(GooglePlaces)
import GooglePlaces
#endif

// MARK: - Service Protocol
protocol SearchServicing {
    func searchPlaces(text: String, completion: @escaping (Result<[PlaceItem], Error>) -> Void)
    func fetchFirstPhoto(placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void)
}

// MARK: - Errors
enum SearchServiceError: Error {
    case emptyQuery
    case unknown
}

// MARK: - Default Implementation
final class SearchService: SearchServicing {
    private var imageCache: [String: UIImage] = [:]

    func searchPlaces(text: String, completion: @escaping (Result<[PlaceItem], Error>) -> Void) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            completion(.failure(SearchServiceError.emptyQuery))
            return
        }

        #if canImport(GooglePlaces)
        let myProperties = [GMSPlaceProperty.name, GMSPlaceProperty.placeID, GMSPlaceProperty.rating].map { $0.rawValue }
        let request = GMSPlaceSearchByTextRequest(textQuery: query, placeProperties: myProperties)
        request.includedType = kGMSPlaceTypeCountry
        request.maxResultCount = 20
        request.rankPreference = GMSPlaceSearchByTextRankPreference.distance
        request.isStrictTypeFiltering = false

        let callback: GMSPlaceSearchByTextResultCallback = { results, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let gmsResults = results else {
                completion(.success([]))
                return
            }
            let mapped: [PlaceItem] = gmsResults.map { place in
                let coord = Optional(place.coordinate)
                return PlaceItem(id: place.placeID ?? UUID().uuidString,
                                 name: place.name ?? "Unknown",
                                 coordinate: coord,
                                 rating: Double(place.rating))
            }
            completion(.success(mapped))
        }

        GMSPlacesClient.shared().searchByText(with: request, callback: callback)
        #else
        // Fallback: return empty after slight delay to simulate async
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            completion(.success([]))
        }
        #endif
    }

    func fetchFirstPhoto(placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        if let cached = imageCache[placeID] {
            completion(cached)
            return
        }

        #if canImport(GooglePlaces)
        let client = GMSPlacesClient.shared()
        client.lookUpPhotos(forPlaceID: placeID) { [weak self] (photos, error) in
            guard error == nil else {
                print("[SearchService] lookUpPhotos error: \(error!.localizedDescription)")
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
                    print("[SearchService] fetchPhoto error: \(error.localizedDescription)")
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
