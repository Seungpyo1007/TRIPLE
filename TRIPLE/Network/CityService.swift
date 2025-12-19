//
//  CountryService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/17/25.
//

import Foundation

protocol CityServicing {
    func city(forName name: String) -> City
}

struct CityService: CityServicing {
    func city(forName name: String) -> City {
        let placeID = CityPlaceIDs.placeID(for: name)
        return City(name: name, placeID: placeID)
    }
}
