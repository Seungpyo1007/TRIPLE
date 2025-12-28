//
//  SearchService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import Foundation
import UIKit
import GooglePlaces

// MARK: - 프로토콜
/// 검색 서비스 인터페이스
protocol SearchServicing {
    /// 텍스트 키워드로 장소를 검색합니다.
    func searchPlaces(text: String, completion: @escaping (Result<[PlaceItem], Error>) -> Void)
    /// 장소 ID를 기반으로 첫 번째 이미지를 가져옵니다.
    func fetchFirstPhoto(placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void)
}

// MARK: - 에러 정의
/// 검색 서비스 관련 에러
enum SearchServiceError: Error {
    /// 검색어가 비어있음
    case emptyQuery
    /// 알 수 없는 에러
    case unknown
}

// MARK: - 서비스 구현
/// Google Places API를 사용한 장소 검색 및 이미지 로드 서비스
final class SearchService: SearchServicing {
    
    // MARK: - 속성
    /// 메모리 캐시: 장소 ID별 이미지를 저장하여 중복 네트워크 요청 방지
    private var imageCache: [String: UIImage] = [:]

    // MARK: - 장소 검색
    /// 텍스트 키워드로 Google Places API를 통해 장소를 검색합니다.
    func searchPlaces(text: String, completion: @escaping (Result<[PlaceItem], Error>) -> Void) {
        // 검색어 앞뒤 공백 제거
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 검색어 유효성 검사
        guard !query.isEmpty else {
            completion(.failure(SearchServiceError.emptyQuery))
            return
        }

        // 검색 시 가져올 데이터 속성 정의 (이름, Place ID, 평점)
        let myProperties = [GMSPlaceProperty.name, GMSPlaceProperty.placeID, GMSPlaceProperty.rating].map { $0.rawValue }
        let request = GMSPlaceSearchByTextRequest(textQuery: query, placeProperties: myProperties)
        
        // 검색 옵션 설정
        request.includedType = kGMSPlaceTypeCountry  // 국가 단위 장소만 검색
        request.maxResultCount = 20                  // 최대 20개 결과
        request.rankPreference = GMSPlaceSearchByTextRankPreference.distance  // 거리순 정렬
        request.isStrictTypeFiltering = false        // 유연한 타입 필터링

        // Google Places API 호출
        GMSPlacesClient.shared().searchByText(with: request) { results, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 결과가 없으면 빈 배열 반환
            guard let gmsResults = results else {
                completion(.success([]))
                return
            }
            
            // Google Places SDK 모델을 내부 PlaceItem 모델로 변환
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

    // MARK: - 이미지 로딩
    /// Place ID를 기반으로 장소의 첫 번째 사진을 가져옵니다.
    func fetchFirstPhoto(placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        // 캐시 확인: 이미 로드한 사진이 있다면 즉시 반환하여 네트워크 요청 방지
        if let cached = imageCache[placeID] {
            completion(cached)
            return
        }

        let client = GMSPlacesClient.shared()
        
        // 1단계: Place ID로 장소 상세 정보를 조회하여 사진 메타데이터 확보
        let properties: [GMSPlaceProperty] = [.photos]
        let request = GMSFetchPlaceRequest(placeID: placeID, placeProperties: properties.map { $0.rawValue }, sessionToken: nil)
        
        client.fetchPlace(with: request) { [weak self] (place, error) in
            // 사진 메타데이터가 없으면 nil 반환
            guard let photoMetadata = place?.photos?.first, error == nil else {
                print("[SearchService] 사진 메타데이터 없음: \(error?.localizedDescription ?? "No photos")")
                completion(nil)
                return
            }
            
            // 2단계: 획득한 메타데이터로 실제 이미지 데이터 요청
            let photoRequest = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: maxSize)
            client.fetchPhoto(with: photoRequest) { (image, error) in
                if let error = error {
                    print("[SearchService] 사진 로드 실패: \(error.localizedDescription)")
                    completion(nil)
                } else if let image = image {
                    // 성공 시 캐시에 저장하여 다음 요청 시 재사용
                    self?.imageCache[placeID] = image
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
