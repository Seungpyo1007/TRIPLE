//
//  CityPlacesModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/18/25.
//

import Foundation
import CoreLocation

public enum PlaceCategory: String {
    case touristAttraction = "tourist_attraction"
    case restaurant = "restaurant"
    case lodging = "lodging"
}

public struct CityPlace {
    public let name: String
    public let coordinate: CLLocationCoordinate2D
    public let rating: Double
}

public struct NearbySearchInput {
    public let center: CLLocationCoordinate2D
    public let radius: Double
    public let category: PlaceCategory
}
