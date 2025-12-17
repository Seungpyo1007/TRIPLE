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
        // 1. lookUpPhotos 대신 fetchPlace를 사용하여 최신 사진 메타데이터를 직접 가져옵니다.
        let properties: [GMSPlaceProperty] = [.photos]
        let fetchRequest = GMSFetchPlaceRequest(
            placeID: placeID,
            placeProperties: properties.map { $0.rawValue },
            sessionToken: nil
        )

        placesClient.fetchPlace(with: fetchRequest) { [weak self] place, error in
            if let error = error {
                print("[CityRec] Failed to fetch place for photos: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // 2. 검색된 장소 정보에서 첫 번째 사진 메타데이터 추출
            guard let photoMetadata = place?.photos?.first else {
                print("[CityRec] No photo metadata found for placeID: \(placeID)")
                completion(nil)
                return
            }

            // 3. 획득한 메타데이터로 실제 사진 데이터 요청
            let fetchPhotoRequest = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: maxSize)
            
            self?.placesClient.fetchPhoto(with: fetchPhotoRequest) { image, error in
                if let error = error {
                    print("[CityRec] Failed to fetch photo data: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                // 4. 이미지 데이터를 변환하여 반환
                if let image = image {
                    if let data = image.jpegData(compressionQuality: 0.9) {
                        completion(data)
                    } else if let data = image.pngData() {
                        completion(data)
                    } else {
                        completion(nil)
                    }
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
        "Ho Chi Minh City": "ChIJ0T2NLikpdTERKxE8d61aX_E", // Saigon hotel example placeID provided
        "Hanoi": "ChIJoRyG2ZurNTERqRfKcnt_iOc",
        "Da Nang": "ChIJEyolkscZQjERBn5yhkvL8B0",
        
        // Japan
        "Tokyo": "ChIJ51cu8IcbXWARiRtXIothAS4",
        "Osaka": "ChIJ4eIGNFXmAGAR5y9q5G7BW8U",
        "Kyoto": "ChIJ8cM8zdaoAWARPR27azYdlsA",
        "Fukuoka": "ChIJKYSE6aHtQTURg4c5NplyCvY",
        
        // Korea
        "Seoul": "ChIJzWXFYYuifDUR64Pq5LTtioU",
        
        // Taiwan
        "Taipei": "ChIJi73bYWusQjQRgqQGXK260bw",
        
        // China SAR
        "Hong Kong": "ChIJD5gyo-3iAzQRfMnq27qzivA",
        
        // Thailand
        "Bangkok": "ChIJ82ENKDJgHTERIEjiXbIAAQE",
        
        // Singapore
        "Singapore": "ChIJdZOLiiMR2jERxPWrUs9peIg",
        
        // Malaysia
        "Kuala Lumpur": "ChIJ0-cIvSo2zDERmWzYQPUfLiM",
        
        // Philippines
        "Manila": "ChIJi8MeVwPKlzMRH8FpEHXV0Wk",
        
        // Indonesia
        "Jakarta": "ChIJnUvjRenzaS4RoobX2g-_cVM",
        
        // Australia & NZ
        "Sydney": "ChIJP3Sa8ziYEmsRUKgyFmh9AQM",
        "Melbourne": "ChIJ90260rVG1moRkM2MIXVWBAQ",
        "Auckland": "ChIJ--acWvtHDW0RF5miQ2HvAAU",
        
        // USA & Canada
        "Los Angeles": "ChIJE9on3F3HwoAR9AhGJW_fL-I",
        "New York": "ChIJOwg_06VPwokRYv534QaPC8g",
        "San Francisco": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Vancouver": "ChIJs0-pQ_FzhlQRi_OBm-qWkbs",
        "Toronto": "ChIJpTvG15DL1IkRd8S0KlBVNTI",
        
        // Europe
        "London": "ChIJdd4hrwug2EcRmSrV3Vo6llI",
        "Paris": "ChIJdd4hrwug2EcRmSrV3Vo6llI",
        "Berlin": "ChIJAVkDPzdOqEcRcDteW0YgIQQ",
        "Barcelona": "ChIJk_s92NyipBIRUMnDG8Kq2Js",
        "Rome": "ChIJu46S-ZZhLxMROG5lkwZ3D7k",
        "Istanbul": "ChIJawhoAASnyhQR0LABvJj-zOE",
        
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
