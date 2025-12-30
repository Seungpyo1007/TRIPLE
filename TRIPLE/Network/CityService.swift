//
//  CityService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/17/25.
//

import Foundation

// MARK: - 프로토콜
protocol CityServicing {
    /// 도시 이름을 입력받아 해당 도시의 상세 모델(City)을 반환합니다.
    func city(forName name: String) -> City
}

// MARK: - 서비스 구현
struct CityService: CityServicing {
    /// 도시 이름을 기반으로 City 객체를 생성합니다.
    func city(forName name: String) -> City {
        let placeID = CityPlaceIDs.placeID(for: name)
        return City(name: name, placeID: placeID)
    }
}
