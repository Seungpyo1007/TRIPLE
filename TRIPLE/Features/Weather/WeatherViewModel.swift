//
//  WeatherViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import Foundation

class WeatherViewModel {
    // MARK: - 속성
    /// 날씨를 조회할 도시 이름
    var cityName: String = "Tokyo"
    /// 포맷된 온도 문자열 (예: "12°C")
    var temperature: String = "--°C"
    /// 날씨 설명 (예: "맑음")
    var description: String = "--"

    // MARK: - 출력
    /// 뷰모델이 표시 값을 업데이트할 때 메인 스레드에서 호출되는 클로저
    var onUpdated: (() -> Void)?

    // MARK: - 초기화
    init(cityName: String = "Tokyo") {
        self.cityName = cityName
    }

    // MARK: - API
    /// 현재 도시 이름으로 날씨를 로드하고 표시 속성을 업데이트합니다.
    func loadWeather() {
        let targetCity = self.cityName
        fetchWeather(cityName: targetCity) { [weak self] response in
            guard let response = response else { return }

            // 원시 모델을 표시 값으로 변환
            self?.temperature = "\(Int(response.main.temp))°C"
            self?.description = response.weather.first?.description ?? ""

            // 메인 스레드에서 UI에 알림
            DispatchQueue.main.async {
                self?.onUpdated?()
            }
        }
    }
}
