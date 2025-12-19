//
//  CityPlacesViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/18/25.
//

import Foundation
import GooglePlaces

final class CityPlacesViewModel {
    var onPlacesUpdate: (([GMSPlace], UIColor) -> Void)?
    var onError: ((Error) -> Void)?

    private let service: CityPlacesServicing

    init(service: CityPlacesServicing = CityPlacesService()) {
        self.service = service
    }

    func search(category: PlaceCategory, center: CLLocationCoordinate2D, radius: Double, color: UIColor) {
        service.searchNearby(center: center, radius: radius, category: category) { [weak self] result in
            switch result {
            case .success(let places):
                self?.onPlacesUpdate?(places, color)
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
}
