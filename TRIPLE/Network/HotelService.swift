//
//  HotelService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/17/25.
//

import Foundation
import UIKit
import GooglePlaces

protocol HotelServicing {
    func searchHotelsRealtime(city: String, limit: Int, completion: @escaping ([HotelItem]) -> Void)
    func fetchPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void)
    func loadMockJapanHotels(limit: Int) -> [HotelItem]
    func loadVerified(limit: Int?) -> [HotelItem]
}

final class GooglePlacesHotelService: HotelServicing {
    static let shared = GooglePlacesHotelService()
    private let placesClient = GMSPlacesClient.shared()
    private var photoCache: [String: UIImage] = [:]

    private init() {}

    func searchHotelsRealtime(city: String, limit: Int, completion: @escaping ([HotelItem]) -> Void) {
        let query = "Hotels in \(city)"
        let properties: [GMSPlaceProperty] = [.name, .placeID, .rating, .priceLevel]
        let request = GMSPlaceSearchByTextRequest(textQuery: query, placeProperties: properties.map { $0.rawValue })
        request.maxResultCount = 999
        request.includedType = "lodging"

        placesClient.searchByText(with: request) { results, error in
            if let error = error {
                print("[Hotel] 검색 에러: \(error.localizedDescription)")
                completion([])
                return
            }
            let hotels = results?.compactMap { place -> HotelItem? in
                guard let pid = place.placeID else { return nil }
                return HotelItem(title: place.name ?? "Unknown Hotel", placeID: pid, ratingJP: Double(place.rating), priceJPY: 30000)
            } ?? []
            completion(hotels)
        }
    }

    func fetchPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        if let cached = photoCache[placeID] {
            completion(cached)
            return
        }

        let fields: GMSPlaceField = [.photos]
        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { [weak self] (place, error) in
            guard let self = self, let photoMetadata = place?.photos?.first else {
                completion(nil)
                return
            }

            self.placesClient.loadPlacePhoto(photoMetadata) { (image, error) in
                if let image = image {
                    self.photoCache[placeID] = image
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func loadMockJapanHotels(limit: Int) -> [HotelItem] { return [] }
    func loadVerified(limit: Int?) -> [HotelItem] { return [] }
}

struct HotelService: HotelServicing {
    func searchHotelsRealtime(city: String, limit: Int, completion: @escaping ([HotelItem]) -> Void) {
        GooglePlacesHotelService.shared.searchHotelsRealtime(city: city, limit: limit, completion: completion)
    }
    func fetchPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        GooglePlacesHotelService.shared.fetchPhoto(for: placeID, maxSize: maxSize, completion: completion)
    }
    func loadMockJapanHotels(limit: Int) -> [HotelItem] { return [] }
    func loadVerified(limit: Int?) -> [HotelItem] { return [] }
}
