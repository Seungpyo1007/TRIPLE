//
//  WeatherModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import Foundation

// MARK: - 날씨 모델

/// 날씨 API 응답 모델: 온도와 날씨 조건을 포함
struct WeatherResponse: Codable {
    /// 온도 정보를 담는 컨테이너
    let main: Main
    /// 날씨 조건 배열 (첫 번째 항목이 주요 조건)
    let weather: [Weather]
}

/// 온도 데이터
struct Main: Codable {
    /// 섭씨 온도 (units=metric 사용 시)
    let temp: Double
}

/// 날씨 데이터
struct Weather: Codable {
    /// 사람이 읽을 수 있는 설명 (예: "Clear, Rain")
    let description: String
}
