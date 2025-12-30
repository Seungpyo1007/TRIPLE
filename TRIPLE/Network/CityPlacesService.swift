//
//  CityPlacesService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/18/25.
//

import Foundation
import CoreLocation
import GooglePlaces

// MARK: - 프로토콜
public protocol CityPlacesServicing {
    /// 중심 좌표와 반경을 기준으로 특정 카테고리의 장소를 검색합니다.
    func searchNearby(
        center: CLLocationCoordinate2D,
        radius: Double,
        category: PlaceCategory,
        completion: @escaping (Result<[GMSPlace], Error>) -> Void
    )
}

// MARK: - 서비스 구현
public final class CityPlacesService: CityPlacesServicing {
    private let client: GMSPlacesClient

    public init(client: GMSPlacesClient = .shared()) {
        self.client = client
    }

    /// 인근 장소 검색 실행
    public func searchNearby(
        center: CLLocationCoordinate2D,
        radius: Double,
        category: PlaceCategory,
        completion: @escaping (Result<[GMSPlace], Error>) -> Void
    ) {
        // 검색 범위 설정 (중심점으로부터의 원형 반경)
        let restriction = GMSPlaceCircularLocationOption(center, radius)
        
        // 받아올 장소 데이터 속성 정의 (이름, 좌표, 평점)
        let properties = [
            GMSPlaceProperty.name,
            GMSPlaceProperty.coordinate,
            GMSPlaceProperty.rating
        ].map { $0.rawValue }
        
        // 검색 요청 객체 생성 및 카테고리(필터) 설정
        let request = GMSPlaceSearchNearbyRequest(locationRestriction: restriction, placeProperties: properties)
        request.includedTypes = [category.rawValue]

        // Google Places API 호출
        let callback: GMSPlaceSearchNearbyResultCallback = { results, error in
            if let error = error {
                print("[CityPlacesService] 검색 에러: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            let places = results ?? []
            completion(.success(places))
        }
        
        client.searchNearby(with: request, callback: callback)
    }
}
