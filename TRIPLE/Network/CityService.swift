//
//  CountryService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/17/25.
//

import Foundation

// MARK: - City Domain Service

// MARK: - [Protocol] 도시 정보 서비스 인터페이스
/// Provides City domain objects for given names.
protocol CityServicing {
    /// 도시 이름을 입력받아 해당 도시의 상세 모델(City)을 반환합니다.
    func city(forName name: String) -> City
}

// MARK: - [Service] 도시 정보 제공 구현체
/// Default implementation backed by static mapping tables.
struct CityService: CityServicing {
    /// 도시 이름을 기반으로 City 객체를 생성합니다.
    func city(forName name: String) -> City {
        let placeID = CityPlaceIDs.placeID(for: name)
        return City(name: name, placeID: placeID)
    }
}
