//
//  CountryViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import Foundation

final class CityViewModel {
    
    // MARK: - 상수
    private let city: City

    // MARK: - 초기화 (City 모델 필수)
    init(city: City) {
        self.city = city
    }

    // MARK: - 변수
    /// 도시의 이름
    var cityNameText: String { city.name }
    
    /// 구글 Place ID (없을 경우 빈 문자열 반환하여 뷰에서의 옵셔널 처리를 줄여줍니다)
    var placeIDText: String { city.placeID ?? "" }
}
