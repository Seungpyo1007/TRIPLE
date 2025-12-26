//
//  WeatherService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import Foundation

// MARK: - Weather Networking Service

/// Fetch current weather for a given city using OpenWeather API.
/// - Parameters:
///   - cityName: Human readable city name (e.g., "Tokyo").
///   - completion: Called on background thread with decoded `WeatherResponse` or `nil` on failure.
func fetchWeather(cityName: String, completion: @escaping (WeatherResponse?) -> Void) {
    // MARK: - Read API Key from Secret.plist
    guard let path = Bundle.main.path(forResource: "Secret", ofType: "plist"),
          let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
          let apiKey = dict["OpenWeather-API-KEY"] as? String,
          apiKey.isEmpty == false else {
        print("[WeatherService] Missing OpenWeather API key.")
        completion(nil)
        return
    }

    // MARK: - Build URL
    var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
    components?.queryItems = [
        URLQueryItem(name: "q", value: cityName),
        URLQueryItem(name: "appid", value: apiKey),
        URLQueryItem(name: "units", value: "metric")
    ]

    guard let url = components?.url else {
        print("[WeatherService] Failed to build URL for city: \(cityName)")
        completion(nil)
        return
    }

    // MARK: - Request
    URLSession.shared.dataTask(with: url) { data, response, error in
        // Basic transport error handling
        if let error = error {
            print("[WeatherService] Network error: \(error.localizedDescription)")
            completion(nil)
            return
        }

        // Optional: Check HTTP status code
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            print("[WeatherService] HTTP status: \(http.statusCode)")
            completion(nil)
            return
        }

        guard let data = data else {
            print("[WeatherService] No data returned.")
            completion(nil)
            return
        }

        // MARK: - Decode
        do {
            let decodedResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
            completion(decodedResponse)
        } catch {
            print("[WeatherService] Decoding failed: \(error)")
            completion(nil)
        }
    }.resume()
}
