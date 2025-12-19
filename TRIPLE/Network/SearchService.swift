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

// MARK: - 서비스 프로토콜
protocol SearchServicing {
    func searchPlaces(text: String, completion: @escaping (Result<[PlaceItem], Error>) -> Void)
    func fetchFirstPhoto(placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void)
}

// MARK: - 에러
enum SearchServiceError: Error {
    case emptyQuery
    case unknown
}

// MARK: - 기본 구현
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
        // 대체 방안: 비동기 처리를 시뮬레이션하기 위해 약간의 지연 후 빈 값을 반환합니다.
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
        
        // 1. Place ID로 장소 상세 정보(사진 포함)를 다시 조회 (최신 방식 대응)
        let properties: [GMSPlaceProperty] = [.photos]
        let request = GMSFetchPlaceRequest(placeID: placeID, placeProperties: properties.map { $0.rawValue }, sessionToken: nil)
        
        client.fetchPlace(with: request) { [weak self] (place, error) in
            guard let photoMetadata = place?.photos?.first, error == nil else {
                print("[SearchService] fetchPlace/Photos error: \(error?.localizedDescription ?? "No photos")")
                completion(nil)
                return
            }
            
            // 2. 획득한 메타데이터로 사진 요청
            let photoRequest = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: maxSize)
            client.fetchPhoto(with: photoRequest) { (image, error) in
                if let error = error {
                    print("[SearchService] fetchPhoto error: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    self?.imageCache[placeID] = image
                    completion(image)
                }
            }
        }
        #else
        completion(nil)
        #endif
    }
}
