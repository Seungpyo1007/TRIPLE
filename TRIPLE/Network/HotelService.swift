//
//  HotelService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/17/25.
//

import Foundation
import UIKit
import GooglePlaces

// MARK: - [Protocol] 호텔 서비스 인터페이스
protocol HotelServicing {
    /// 특정 도시의 호텔을 실시간으로 검색합니다.
    func searchHotelsRealtime(city: String, limit: Int, completion: @escaping ([HotelItem]) -> Void)
    /// 호텔의 대표 사진을 가져옵니다.
    func fetchPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void)
    /// 일본 호텔 Mock 데이터를 불러옵니다.
    func loadMockJapanHotels(limit: Int) -> [HotelItem]
    /// 검증된 호텔 목록을 불러옵니다.
    func loadVerified(limit: Int?) -> [HotelItem]
}

// MARK: - [Service] Google Places 기반 호텔 서비스
final class GooglePlacesHotelService: HotelServicing {
    static let shared = GooglePlacesHotelService()
    private let placesClient = GMSPlacesClient.shared()
    
    // 이미지 재요청을 방지하기 위한 메모리 캐시
    private var photoCache: [String: UIImage] = [:]

    private init() {}

    // MARK: 1. 실시간 호텔 검색
    func searchHotelsRealtime(city: String, limit: Int, completion: @escaping ([HotelItem]) -> Void) {
        let query = "\(city) 호텔" // 검색 쿼리
        let properties: [GMSPlaceProperty] = [.name, .placeID, .rating, .priceLevel]
        let request = GMSPlaceSearchByTextRequest(textQuery: query, placeProperties: properties.map { $0.rawValue })
        
        request.maxResultCount = 20 // API 권장 제한으로 설정
        request.includedType = "lodging" // 숙박 시설로 타입 제한

        placesClient.searchByText(with: request) { results, error in
            if let error = error {
                print("[HotelService] 검색 에러: \(error.localizedDescription)")
                completion([])
                return
            }
            
            // 검색 결과를 HotelItem 모델로 변환
            let hotels = results?.compactMap { place -> HotelItem? in
                guard let pid = place.placeID else { return nil }
                return HotelItem(
                    title: place.name ?? "이름 없는 호텔",
                    placeID: pid,
                    ratingJP: Double(place.rating),
                    priceJPY: 30000 // 가격 정보는 API에서 직접 제공되지 않으므로 임시값 설정
                )
            } ?? []
            
            completion(hotels)
        }
    }

    // MARK: 2. 호텔 사진 로드
    func fetchPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        // 캐시 확인
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

            // 사진 데이터 로드
            self.placesClient.loadPlacePhoto(photoMetadata) { (image, error) in
                if let image = image {
                    self.photoCache[placeID] = image // 캐시에 저장
                    completion(image)
                } else {
                    print("[HotelService] 사진 로드 실패: \(error?.localizedDescription ?? "알 수 없는 에러")")
                    completion(nil)
                }
            }
        }
    }

    // MARK: 3. 임시/검증 데이터 (필수여서 있어야함 필요 시 구현)
    func loadMockJapanHotels(limit: Int) -> [HotelItem] { return [] }
    func loadVerified(limit: Int?) -> [HotelItem] { return [] }
}

// MARK: - [Wrapper] 서비스 호출용 구조체
/// 실제 앱 로직에서 접근하기 쉬운 래퍼 구조체입니다.
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
