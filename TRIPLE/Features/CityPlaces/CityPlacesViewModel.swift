//
//  CityPlacesViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/18/25.
//

import Foundation
import GooglePlaces

final class CityPlacesViewModel {
    
    // MARK: - Output (ViewModel -> View)
    /// 검색된 장소 목록과 해당 카테고리의 테마 색상을 View에 전달
    var onPlacesUpdate: (([GMSPlace], UIColor) -> Void)?
    /// 검색 중 발생한 에러를 View에 전달
    var onError: ((Error) -> Void)?

    // MARK: - 속성
    private let service: CityPlacesServicing

    // MARK: - 초기화
    init(service: CityPlacesServicing = CityPlacesService()) {
        self.service = service
    }

    // MARK: - 로직 (장소 검색 및 결과 처리)
    func search(category: PlaceCategory, center: CLLocationCoordinate2D, radius: Double, color: UIColor) {
        service.searchNearby(center: center, radius: radius, category: category) { [weak self] result in
            switch result {
            case .success(let places):
                // 성공 시 장소 리스트와 색상을 함께 업데이트
                self?.onPlacesUpdate?(places, color)
            case .failure(let error):
                // 실패 시 에러 알림
                self?.onError?(error)
            }
        }
    }
}
