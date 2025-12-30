//
//  CountryService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/17/25.
//

import Foundation

// MARK: - [Protocol] 도시 정보 서비스 인터페이스
protocol CityServicing {
    /// 도시 이름을 입력받아 해당 도시의 상세 모델(City)을 반환합니다.
    func city(forName name: String) -> City
}

// MARK: - [Service] 도시 정보 제공 구현체
struct CityService: CityServicing {
    
    /// 도시 이름을 기반으로 City 객체를 생성합니다.
    func city(forName name: String) -> City {
        // 1. 미리 정의된 CityPlaceIDs 저장소에서 해당 도시의 Google Place ID를 찾습니다.
        let placeID = CityPlaceIDs.placeID(for: name)
        
        // 2. 검색된 ID와 함께 City 모델을 생성하여 반환합니다.
        return City(name: name, placeID: placeID)
    }
}
