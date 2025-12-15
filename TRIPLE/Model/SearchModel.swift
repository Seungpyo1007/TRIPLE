//
//  SearchModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/15/25.
//

import Foundation
import CoreLocation

struct PlaceItem: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D?
    let rating: Double?
}
