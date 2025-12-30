//
//  WeatherService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import Foundation

// MARK: - 날씨 네트워킹 서비스

/// OpenWeather API를 사용하여 주어진 도시의 현재 날씨를 가져옵니다.
func fetchWeather(cityName: String, completion: @escaping (WeatherResponse?) -> Void) {
    // MARK: - API 키 읽기
    // Secret.plist에서 OpenWeather API 키를 읽어옵니다.
    guard let path = Bundle.main.path(forResource: "Secret", ofType: "plist"),
          let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
          let apiKey = dict["OpenWeather-API-KEY"] as? String,
          apiKey.isEmpty == false else {
        print("[WeatherService] Missing OpenWeather API key.")
        completion(nil)
        return
    }

    // MARK: - URL 구성
    // OpenWeather API 요청 URL을 구성합니다.
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

    // MARK: - 네트워크 요청
    URLSession.shared.dataTask(with: url) { data, response, error in
        // 네트워크 에러 처리
        if let error = error {
            print("[WeatherService] Network error: \(error.localizedDescription)")
            completion(nil)
            return
        }

        // HTTP 상태 코드 확인 (200-299 범위가 아니면 실패)
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

        // MARK: - JSON 디코딩
        do {
            let decodedResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
            completion(decodedResponse)
        } catch {
            print("[WeatherService] Decoding failed: \(error)")
            completion(nil)
        }
    }.resume()
}
