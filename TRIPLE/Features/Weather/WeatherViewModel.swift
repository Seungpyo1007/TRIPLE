//
//  WeatherViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import Foundation

class WeatherViewModel {
    // MARK: - Properties (State)
    /// City to query
    var cityName: String = "Tokyo"
    /// Formatted temperature string (e.g., "12°C")
    var temperature: String = "--°C"
    /// Weather description (e.g., "clear sky")
    var description: String = "--"

    // MARK: - Bindings
    /// Called on main thread when view model updates its display values
    var onUpdated: (() -> Void)?

    // MARK: - Lifecycle
    init(cityName: String = "Tokyo") {
        self.cityName = cityName
    }

    // MARK: - Public API
    /// Loads weather for current `cityName` and updates display properties.
    func loadWeather() {
        let targetCity = self.cityName
        fetchWeather(cityName: targetCity) { [weak self] response in
            guard let response = response else { return }

            // Transform raw model into display values
            self?.temperature = "\(Int(response.main.temp))°C"
            self?.description = response.weather.first?.description ?? ""

            // Notify UI on main thread
            DispatchQueue.main.async {
                self?.onUpdated?()
            }
        }
    }
}
