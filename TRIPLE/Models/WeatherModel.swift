//
//  WeatherModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import Foundation

// MARK: - Weather Models

/// Weather response model containing main temperature and weather conditions
struct WeatherResponse: Codable {
    /// Main temperature container
    let main: Main
    /// Array of weather conditions (first item is primary)
    let weather: [Weather]
}

/// Main temperature data
struct Main: Codable {
    /// Temperature in Celsius (when using units=metric)
    let temp: Double
}

/// Weather condition description
struct Weather: Codable {
    /// Human-readable description (e.g., "clear sky")
    let description: String
}
