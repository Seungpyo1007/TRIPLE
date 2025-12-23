//
//  WeatherService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import Foundation
    
func fetchWeather() {
    // Secret.plist에서 API 키 로드
    guard let path = Bundle.main.path(forResource: "Secret", ofType: "plist"),
          let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
          let apiKey = dict["OpenWeather-API-KEY"] as? String,
          !apiKey.isEmpty else {
        assertionFailure("Secret.plist에 OpenWeather-API-KEY를 넣어주세요")
        return
    }

    // 요청 URL 생성 (서울, 섭씨)
    let urlString = "https://api.openweathermap.org/data/2.5/weather?q=Seoul&appid=\(apiKey)&units=metric"
    guard let url = URL(string: urlString) else {
        print("잘못된 URL: \(urlString)")
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        // 네트워크 에러 출력
        if let error = error {
            print("네트워크 에러:", error.localizedDescription)
            return
        }

        // HTTP 상태 코드 검사
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let body = String(data: data ?? Data(), encoding: .utf8) ?? ""
            print("HTTP 상태코드: \(http.statusCode)\n응답 바디: \(body)")
            return
        }

        guard let data = data else {
            print("데이터가 비었습니다.")
            return
        }

        // 디코딩 시도
        do {
            let decodedResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
            print("현재 서울 기온: \(decodedResponse.main.temp)°C")
        } catch {
            print("디코딩 실패:", error)
            if let body = String(data: data, encoding: .utf8) {
                print("원본 응답:", body)
            }
        }
    }.resume()
}
