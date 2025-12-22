//
//  SearchService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import Foundation
import UIKit
import GooglePlaces // 전처리기 제거 및 필수 임포트

// MARK: - [Protocol] 검색 서비스 인터페이스
protocol SearchServicing {
    /// 텍스트 키워드로 장소를 검색합니다.
    func searchPlaces(text: String, completion: @escaping (Result<[PlaceItem], Error>) -> Void)
    /// 장소 ID를 기반으로 첫 번째 이미지를 가져옵니다.
    func fetchFirstPhoto(placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void)
}

// MARK: - [Error] 검색 관련 에러 정의
enum SearchServiceError: Error {
    case emptyQuery // 검색어가 비어있음
    case unknown    // 알 수 없는 에러
}

// MARK: - [Service] 장소 검색 및 이미지 로드 구현
final class SearchService: SearchServicing {
    
    // 메모리 캐시: 장소 ID별 이미지를 저장하여 중복 네트워크 요청 방지
    private var imageCache: [String: UIImage] = [:]

    // MARK: 1. 장소 검색 기능
    func searchPlaces(text: String, completion: @escaping (Result<[PlaceItem], Error>) -> Void) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 검색어 유효성 검사
        guard !query.isEmpty else {
            completion(.failure(SearchServiceError.emptyQuery))
            return
        }

        // 검색 시 가져올 데이터 속성 정의
        let myProperties = [GMSPlaceProperty.name, GMSPlaceProperty.placeID, GMSPlaceProperty.rating].map { $0.rawValue }
        let request = GMSPlaceSearchByTextRequest(textQuery: query, placeProperties: myProperties)
        
        request.includedType = kGMSPlaceTypeCountry
        request.maxResultCount = 20
        request.rankPreference = GMSPlaceSearchByTextRankPreference.distance
        request.isStrictTypeFiltering = false

        // Google Places API 호출
        GMSPlacesClient.shared().searchByText(with: request) { results, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let gmsResults = results else {
                completion(.success([]))
                return
            }
            
            // SDK 모델을 내부 PlaceItem 모델로 변환
            let mapped: [PlaceItem] = gmsResults.map { place in
                PlaceItem(
                    id: place.placeID ?? UUID().uuidString,
                    name: place.name ?? "Unknown",
                    coordinate: place.coordinate,
                    rating: Double(place.rating)
                )
            }
            completion(.success(mapped))
        }
    }

    // MARK: 2. 사진 가져오기 기능
    func fetchFirstPhoto(placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        // 캐시 확인: 이미 받은 사진이 있다면 즉시 반환
        if let cached = imageCache[placeID] {
            completion(cached)
            return
        }

        let client = GMSPlacesClient.shared()
        
        // (1) Place ID로 장소 상세 정보를 조회하여 사진 메타데이터 확보
        let properties: [GMSPlaceProperty] = [.photos]
        let request = GMSFetchPlaceRequest(placeID: placeID, placeProperties: properties.map { $0.rawValue }, sessionToken: nil)
        
        client.fetchPlace(with: request) { [weak self] (place, error) in
            guard let photoMetadata = place?.photos?.first, error == nil else {
                print("[SearchService] 사진 메타데이터 없음: \(error?.localizedDescription ?? "No photos")")
                completion(nil)
                return
            }
            
            // (2) 획득한 메타데이터로 실제 이미지 요청
            let photoRequest = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: maxSize)
            client.fetchPhoto(with: photoRequest) { (image, error) in
                if let error = error {
                    print("[SearchService] 사진 로드 실패: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    // 성공 시 캐시에 저장 후 반환
                    self?.imageCache[placeID] = image
                    completion(image)
                }
            }
        }
    }
}
