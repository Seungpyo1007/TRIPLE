//
//  CountryViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import Foundation

final class CityViewModel {
    // MARK: - Properties
    private let city: City

    // MARK: - Initialization
    /// Initialize with a required `City` model
    init(city: City) {
        self.city = city
    }

    // MARK: - Computed Outputs
    /// 도시의 이름
    var cityNameText: String { city.name }
    /// 구글 Place ID (없을 경우 빈 문자열 반환)
    var placeIDText: String { city.placeID ?? "" }
}
