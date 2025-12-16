//
//  CityRecService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import Foundation
#if canImport(GooglePlaces)
import GooglePlaces
#endif

// Photo provider boundary for city/place thumbnails
protocol PlacePhotoProviding {
    // Returns image data (jpeg/png) for first photo of a placeID
    func fetchFirstPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (Data?) -> Void)
}

#if canImport(GooglePlaces)
/// Default Google Places-based photo provider
final class GooglePlacesPhotoService: PlacePhotoProviding {
    private let placesClient: GMSPlacesClient

    init(placesClient: GMSPlacesClient = GMSPlacesClient.shared()) {
        self.placesClient = placesClient
    }

    func fetchFirstPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (Data?) -> Void) {
        placesClient.lookUpPhotos(forPlaceID: placeID) { photos, error in
            if let error = error {
                print("[CityRec] Failed to lookup photos: \(error)")
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
                    print("[CityRec] Failed to fetch photo: \(error)")
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
#endif

// Service boundary for providing city recommendation data
protocol CityRecServicing {
    // Load a random mock list of cities (with optional verified place IDs)
    func loadMock(verifiedPlaceIDs: [String], count: Int) -> [CityRecItem]

    // Load a verified list (optionally limited in length)
    func loadVerified(limit: Int?) -> [CityRecItem]

    // Lookup a known Google Place ID for a given city name
    func placeID(for city: String) -> String?
}

// MARK: - Internal data source of known place IDs
enum CityPlaceIDs {
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

// Default implementation of the service
struct CityRecService: CityRecServicing {
    func loadMock(verifiedPlaceIDs: [String], count: Int) -> [CityRecItem] {
        let cityNames = [
            "Seoul", "Tokyo", "Osaka", "Kyoto", "Fukuoka",
            "Taipei", "Hong Kong", "Bangkok", "Singapore", "Kuala Lumpur",
            "Hanoi", "Ho Chi Minh City", "Da Nang", "Manila", "Jakarta",
            "Sydney", "Melbourne", "Auckland", "Los Angeles", "New York",
            "San Francisco", "Vancouver", "Toronto", "London", "Paris",
            "Berlin", "Barcelona", "Rome", "Istanbul", "Dubai",
            "Saigon" // alias for Ho Chi Minh City
        ]
        let shuffled = cityNames.shuffled()
        var items: [CityRecItem] = []
        for i in 0..<max(0, count) {
            let title = i < shuffled.count ? shuffled[i] : "City \(i + 1)"
            let id = CityPlaceIDs.placeID(for: title)
            let placeID = id ?? (verifiedPlaceIDs.contains { $0 == id } ? id : nil)
            items.append(CityRecItem(title: title, placeID: placeID))
        }
        return items
    }

    func loadVerified(limit: Int?) -> [CityRecItem] {
        let all = CityPlaceIDs.byCity.map { CityRecItem(title: $0.key, placeID: $0.value) }
        if let limit, limit > 0 { return Array(all.prefix(limit)) }
        return all
    }

    func placeID(for city: String) -> String? {
        CityPlaceIDs.placeID(for: city)
    }
}
