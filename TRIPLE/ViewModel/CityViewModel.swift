//
//  CountryViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import Foundation

final class CityViewModel {
    private let city: City

    init(city: City) {
        self.city = city
    }

    var cityNameText: String { city.name }
    var placeIDText: String { city.placeID ?? "" }
}
