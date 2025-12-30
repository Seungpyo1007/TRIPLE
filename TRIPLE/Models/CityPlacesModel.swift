//
//  CityPlacesModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/18/25.
//

import Foundation
import CoreLocation

// MARK: - 도시 장소 모델

/// Google Places API에서 사용하는 장소 카테고리
public enum PlaceCategory: String {
    /// 관광 명소
    case touristAttraction = "tourist_attraction"
    /// 레스토랑
    case restaurant = "restaurant"
    /// 숙박 시설
    case lodging = "lodging"
}

/// 도시 내 장소 정보를 담는 구조체
public struct CityPlace {
    /// 장소 이름
    public let name: String
    /// 장소의 좌표 (위도, 경도)
    public let coordinate: CLLocationCoordinate2D
    /// 평점
    public let rating: Double
}

/// 주변 검색 입력 파라미터 구조체
public struct NearbySearchInput {
    /// 검색 중심 좌표
    public let center: CLLocationCoordinate2D
    /// 검색 반경 (미터 단위)
    public let radius: Double
    /// 검색할 장소 카테고리
    public let category: PlaceCategory
}
