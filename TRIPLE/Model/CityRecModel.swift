//
//  CityRecModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/15/25.
//

import Foundation
import UIKit
import GooglePlaces

struct CityRecItem {
    let id: UUID = UUID()
    let title: String
    let placeID: String?
}

private enum CityPlaceIDs {
    // Known Google Places placeIDs per city name
    static let byCity: [String: String] = [
        // Vietnam
        "Ho Chi Minh City": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s", // Saigon hotel example placeID provided
        "Hanoi": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Da Nang": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // Japan
        "Tokyo": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Osaka": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Kyoto": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Fukuoka": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // Korea
        "Seoul": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // Taiwan
        "Taipei": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // China SAR
        "Hong Kong": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // Thailand
        "Bangkok": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // Singapore
        "Singapore": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // Malaysia
        "Kuala Lumpur": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // Philippines
        "Manila": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // Indonesia
        "Jakarta": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // Australia & NZ
        "Sydney": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Melbourne": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Auckland": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // USA & Canada
        "Los Angeles": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "New York": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "San Francisco": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Vancouver": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Toronto": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // Europe
        "London": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Paris": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Berlin": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Barcelona": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Rome": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Istanbul": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        
        // UAE
        "Dubai": "ChIJRcbZaklDXz4RYlEphFBu5r0"
    ]

    static func placeID(for city: String) -> String? {
        // Normalize common aliases
        switch city {
        case "Saigon":
            return byCity["Ho Chi Minh City"]
        default:
            return byCity[city]
        }
    }
}

protocol PlacePhotoProviding {
    func fetchFirstPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (Data?) -> Void)
}

final class GooglePlacesPhotoService: PlacePhotoProviding {

    private let placesClient: GMSPlacesClient

    init(placesClient: GMSPlacesClient = GMSPlacesClient.shared()) {
        self.placesClient = placesClient
    }

    func fetchFirstPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (Data?) -> Void) {
        placesClient.lookUpPhotos(forPlaceID: placeID) { photos, error in
            if let error = error {
                print("Failed to lookup photos: \(error)")
                completion(nil)
                return
            }
            guard let photoMetadata = photos?.results.first else {
                completion(nil)
                return
            }
            let fetchPhotoRequest = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: maxSize)
            self.placesClient.fetchPhoto(with: fetchPhotoRequest) { image, error in
                if let error = error {
                    print("Failed to fetch photo: \(error)")
                    completion(nil)
                    return
                }
                if let image = image, let data = image.jpegData(compressionQuality: 0.9) {
                    completion(data)
                } else if let image = image, let data = image.pngData() {
                    completion(data)
                } else {
                    completion(nil)
                }
            }
        }
    }
}


final class CityRecModel {
    private(set) var items: [CityRecItem] = [] { didSet { onItemsChanged?(items) } }
    var onItemsChanged: (([CityRecItem]) -> Void)?

    private let verifiedPlaceIDs: [String]

    init(verifiedPlaceIDs: [String] = []) {
        self.verifiedPlaceIDs = verifiedPlaceIDs
    }

    var numberOfItems: Int { items.count }
    func item(at index: Int) -> CityRecItem { items[index] }

    func loadMock() {
        let cityNames = [
            "Seoul", "Tokyo", "Osaka", "Kyoto", "Fukuoka",
            "Taipei", "Hong Kong", "Bangkok", "Singapore", "Kuala Lumpur",
            "Hanoi", "Ho Chi Minh City", "Da Nang", "Manila", "Jakarta",
            "Sydney", "Melbourne", "Auckland", "Los Angeles", "New York",
            "San Francisco", "Vancouver", "Toronto", "London", "Paris",
            "Berlin", "Barcelona", "Rome", "Istanbul", "Dubai",
            "Saigon" // alias for Ho Chi Minh City
        ]
        let count = 10
        let shuffledCities = cityNames.shuffled()
        var mocks: [CityRecItem] = []
        for i in 0..<count {
            let title = i < shuffledCities.count ? shuffledCities[i] : "City \(i + 1)"
            let placeID = CityPlaceIDs.placeID(for: title) ?? (verifiedPlaceIDs.contains { $0 == CityPlaceIDs.placeID(for: title) } ? CityPlaceIDs.placeID(for: title) : nil)
            mocks.append(CityRecItem(title: title, placeID: placeID))
        }
        self.items = mocks
    }
    
    func loadVerified(limit: Int? = nil) {
        let all = CityPlaceIDs.byCity.map { CityRecItem(title: $0.key, placeID: $0.value) }
        if let limit, limit > 0 {
            self.items = Array(all.prefix(limit))
        } else {
            self.items = all
        }
    }
}
