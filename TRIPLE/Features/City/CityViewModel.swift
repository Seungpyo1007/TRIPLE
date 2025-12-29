//
//  CountryViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import Foundation

final class CityViewModel {
    // MARK: - 속성
    private let city: City

    // MARK: - 초기화
    init(city: City) {
        self.city = city
    }

    // MARK: - 출력
    /// 도시의 이름
    var cityNameText: String { city.name }
    /// 구글 Place ID (없을 경우 빈 문자열 반환)
    var placeIDText: String { city.placeID ?? "" }
}
