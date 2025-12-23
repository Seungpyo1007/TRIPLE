//
//  WeatherModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import Foundation

struct WeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
}
