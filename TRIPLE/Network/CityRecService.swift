//
//  CityRecService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import Foundation
import UIKit
import GooglePlaces

// MARK: - Photo Provider
protocol PlacePhotoProviding {
    func fetchFirstPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (Data?) -> Void)
}

final class GooglePlacesPhotoService: PlacePhotoProviding {
    private let placesClient: GMSPlacesClient

    init(placesClient: GMSPlacesClient = GMSPlacesClient.shared()) {
        self.placesClient = placesClient
    }

    func fetchFirstPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (Data?) -> Void) {
        let properties: [GMSPlaceProperty] = [.photos]
        let fetchRequest = GMSFetchPlaceRequest(
            placeID: placeID,
            placeProperties: properties.map { $0.rawValue },
            sessionToken: nil
        )

        placesClient.fetchPlace(with: fetchRequest) { [weak self] place, error in
            if let error = error {
                print("[CityRec] 상세 정보 조회 실패: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let photoMetadata = place?.photos?.first else {
                print("[CityRec] 사진 메타데이터 없음 (ID: \(placeID))")
                completion(nil)
                return
            }

            let fetchPhotoRequest = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: maxSize)
            
            self?.placesClient.fetchPhoto(with: fetchPhotoRequest) { image, error in
                guard let image = image, error == nil else {
                    print("[CityRec] 사진 데이터 로드 실패: \(error?.localizedDescription ?? "Unknown")")
                    completion(nil)
                    return
                }

                if let data = image.jpegData(compressionQuality: 0.9) {
                    completion(data)
                } else {
                    completion(image.pngData())
                }
            }
        }
    }
}

// MARK: - City Rec Service Protocol
protocol CityRecServicing {
    func loadMock(verifiedPlaceIDs: [String], count: Int) -> [CityRecItem]
    func loadVerified(limit: Int?) -> [CityRecItem]
    func placeID(for city: String) -> String?
}

// MARK: - Place ID Mapping
enum CityPlaceIDs {
    static let byCity: [String: String] = [
        "Ho Chi Minh City": "ChIJ0T2NLikpdTERKxE8d61aX_E",
        "Hanoi": "ChIJoRyG2ZurNTERqRfKcnt_iOc",
        "Da Nang": "ChIJEyolkscZQjERBn5yhkvL8B0",
        "Tokyo": "ChIJ51cu8IcbXWARiRtXIothAS4",
        "Osaka": "ChIJ4eIGNFXmAGAR5y9q5G7BW8U",
        "Kyoto": "ChIJ8cM8zdaoAWARPR27azYdlsA",
        "Fukuoka": "ChIJKYSE6aHtQTURg4c5NplyCvY",
        "Seoul": "ChIJzWXFYYuifDUR64Pq5LTtioU",
        "Taipei": "ChIJi73bYWusQjQRgqQGXK260bw",
        "Hong Kong": "ChIJD5gyo-3iAzQRfMnq27qzivA",
        "Bangkok": "ChIJ82ENKDJgHTERIEjiXbIAAQE",
        "Singapore": "ChIJdZOLiiMR2jERxPWrUs9peIg",
        "Kuala Lumpur": "ChIJ0-cIvSo2zDERmWzYQPUfLiM",
        "Manila": "ChIJi8MeVwPKlzMRH8FpEHXV0Wk",
        "Jakarta": "ChIJnUvjRenzaS4RoobX2g-_cVM",
        "Sydney": "ChIJP3Sa8ziYEmsRUKgyFmh9AQM",
        "Melbourne": "ChIJ90260rVG1moRkM2MIXVWBAQ",
        "Auckland": "ChIJ--acWvtHDW0RF5miQ2HvAAU",
        "Los Angeles": "ChIJE9on3F3HwoAR9AhGJW_fL-I",
        "New York": "ChIJOwg_06VPwokRYv534QaPC8g",
        "San Francisco": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Vancouver": "ChIJs0-pQ_FzhlQRi_OBm-qWkbs",
        "Toronto": "ChIJpTvG15DL1IkRd8S0KlBVNTI",
        "London": "ChIJdd4hrwug2EcRmSrV3Vo6llI",
        "Paris": "ChIJdd4hrwug2EcRmSrV3Vo6llI",
        "Berlin": "ChIJAVkDPzdOqEcRcDteW0YgIQQ",
        "Barcelona": "ChIJk_s92NyipBIRUMnDG8Kq2Js",
        "Rome": "ChIJu46S-ZZhLxMROG5lkwZ3D7k",
        "Istanbul": "ChIJawhoAASnyhQR0LABvJj-zOE",
        "Dubai": "ChIJRcbZaklDXz4RYlEphFBu5r0"
    ]

    static func placeID(for city: String) -> String? {
        switch city {
        case "Saigon": return byCity["Ho Chi Minh City"]
        default: return byCity[city]
        }
    }
}

// MARK: - Service Implementation
struct CityRecService: CityRecServicing {
    func loadMock(verifiedPlaceIDs: [String], count: Int) -> [CityRecItem] {
        let cityNames = Array(CityPlaceIDs.byCity.keys) + ["Saigon"]
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
        if let limit = limit, limit > 0 {
            return Array(all.prefix(limit))
        }
        return all
    }

    func placeID(for city: String) -> String? {
        CityPlaceIDs.placeID(for: city)
    }
}
