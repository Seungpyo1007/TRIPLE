//
//  CityRecModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/15/25.
//

import Foundation

// MARK: - City Recommendation Display Models
struct CityDisplayInfo {
    let cityKoreanName: String
    let cityEnglishName: String
    let famousTownKorean: String?
    let firstFamousCityKorean: String?
    let secondFamousCityKorean: String?
}

struct CityRecItem {
    let id: UUID = UUID()
    let title: String
    let placeID: String?
}

// MARK: - City Recommendation Model (State + Lookup)
final class CityRecModel {
    // MARK: - Outputs
    private(set) var items: [CityRecItem] = [] { didSet { onItemsChanged?(items) } }
    var onItemsChanged: (([CityRecItem]) -> Void)?

    // MARK: - Dependencies
    private let service: CityRecServicing
    private let verifiedPlaceIDs: [String]

    // MARK: - Static Display Mapping
    private static let displayByCityName: [String: CityDisplayInfo] = [
        "Seoul": CityDisplayInfo(cityKoreanName: "서울", cityEnglishName: "Seoul", famousTownKorean: "북촌 한옥마을", firstFamousCityKorean: "부산", secondFamousCityKorean: "제주"),
        "Tokyo": CityDisplayInfo(cityKoreanName: "도쿄", cityEnglishName: "Tokyo", famousTownKorean: "아사쿠사", firstFamousCityKorean: "오사카", secondFamousCityKorean: "교토"),
        "Osaka": CityDisplayInfo(cityKoreanName: "오사카", cityEnglishName: "Osaka", famousTownKorean: "도톤보리", firstFamousCityKorean: "도쿄", secondFamousCityKorean: "교토"),
        "Kyoto": CityDisplayInfo(cityKoreanName: "교토", cityEnglishName: "Kyoto", famousTownKorean: "기온", firstFamousCityKorean: "도쿄", secondFamousCityKorean: "오사카"),
        "Fukuoka": CityDisplayInfo(cityKoreanName: "후쿠오카", cityEnglishName: "Fukuoka", famousTownKorean: "하카타", firstFamousCityKorean: "도쿄", secondFamousCityKorean: "오사카"),
        "Taipei": CityDisplayInfo(cityKoreanName: "타이베이", cityEnglishName: "Taipei", famousTownKorean: "지우펀", firstFamousCityKorean: "타이난", secondFamousCityKorean: "가오슝"),
        "Hong Kong": CityDisplayInfo(cityKoreanName: "홍콩", cityEnglishName: "Hong Kong", famousTownKorean: "몽콕", firstFamousCityKorean: "마카오", secondFamousCityKorean: "선전"),
        "Bangkok": CityDisplayInfo(cityKoreanName: "방콕", cityEnglishName: "Bangkok", famousTownKorean: "차이나타운", firstFamousCityKorean: "치앙마이", secondFamousCityKorean: "푸켓"),
        "Singapore": CityDisplayInfo(cityKoreanName: "싱가포르", cityEnglishName: "Singapore", famousTownKorean: "차이나타운", firstFamousCityKorean: "조호르바루", secondFamousCityKorean: "말라카"),
        "Hanoi": CityDisplayInfo(cityKoreanName: "하노이", cityEnglishName: "Hanoi", famousTownKorean: "하노이 구시가지", firstFamousCityKorean: "호치민", secondFamousCityKorean: "다낭"),
        "Ho Chi Minh City": CityDisplayInfo(cityKoreanName: "호치민", cityEnglishName: "Ho Chi Minh City", famousTownKorean: "벤탄시장", firstFamousCityKorean: "하노이", secondFamousCityKorean: "다낭"),
        "Da Nang": CityDisplayInfo(cityKoreanName: "다낭", cityEnglishName: "Da Nang", famousTownKorean: "호이안", firstFamousCityKorean: "하노이", secondFamousCityKorean: "호치민"),
        "Kuala Lumpur": CityDisplayInfo(cityKoreanName: "쿠알라룸푸르", cityEnglishName: "Kuala Lumpur", famousTownKorean: "부킷 빈탕", firstFamousCityKorean: "페낭", secondFamousCityKorean: "말라카"),
        "Manila": CityDisplayInfo(cityKoreanName: "마닐라", cityEnglishName: "Manila", famousTownKorean: "인트라무로스", firstFamousCityKorean: "세부", secondFamousCityKorean: "보라카이"),
        "Jakarta": CityDisplayInfo(cityKoreanName: "자카르타", cityEnglishName: "Jakarta", famousTownKorean: "코타 투아", firstFamousCityKorean: "발리", secondFamousCityKorean: "욕야카르타"),
        "Sydney": CityDisplayInfo(cityKoreanName: "시드니", cityEnglishName: "Sydney", famousTownKorean: "더 록스", firstFamousCityKorean: "멜버른", secondFamousCityKorean: "브리즈번"),
        "Melbourne": CityDisplayInfo(cityKoreanName: "멜버른", cityEnglishName: "Melbourne", famousTownKorean: "세인트킬다", firstFamousCityKorean: "시드니", secondFamousCityKorean: "브리즈번"),
        "Auckland": CityDisplayInfo(cityKoreanName: "오클랜드", cityEnglishName: "Auckland", famousTownKorean: "폰손비", firstFamousCityKorean: "웰링턴", secondFamousCityKorean: "크라이스트처치"),
        "Los Angeles": CityDisplayInfo(cityKoreanName: "로스앤젤레스", cityEnglishName: "Los Angeles", famousTownKorean: "헐리우드", firstFamousCityKorean: "샌프란시스코", secondFamousCityKorean: "라스베이거스"),
        "New York": CityDisplayInfo(cityKoreanName: "뉴욕", cityEnglishName: "New York", famousTownKorean: "소호", firstFamousCityKorean: "보스턴", secondFamousCityKorean: "워싱턴 D.C."),
        "San Francisco": CityDisplayInfo(cityKoreanName: "샌프란시스코", cityEnglishName: "San Francisco", famousTownKorean: "소살리토", firstFamousCityKorean: "로스앤젤레스", secondFamousCityKorean: "라스베이거스"),
        "Vancouver": CityDisplayInfo(cityKoreanName: "밴쿠버", cityEnglishName: "Vancouver", famousTownKorean: "개스타운", firstFamousCityKorean: "토론토", secondFamousCityKorean: "캘거리"),
        "Toronto": CityDisplayInfo(cityKoreanName: "토론토", cityEnglishName: "Toronto", famousTownKorean: "디스틸러리 디스트릭트", firstFamousCityKorean: "밴쿠버", secondFamousCityKorean: "몬트리올"),
        "London": CityDisplayInfo(cityKoreanName: "런던", cityEnglishName: "London", famousTownKorean: "노팅힐", firstFamousCityKorean: "맨체스터", secondFamousCityKorean: "리버풀"),
        "Paris": CityDisplayInfo(cityKoreanName: "파리", cityEnglishName: "Paris", famousTownKorean: "몽마르트르", firstFamousCityKorean: "니스", secondFamousCityKorean: "리옹"),
        "Berlin": CityDisplayInfo(cityKoreanName: "베를린", cityEnglishName: "Berlin", famousTownKorean: "미테", firstFamousCityKorean: "함부르크", secondFamousCityKorean: "뮌헨"),
        "Barcelona": CityDisplayInfo(cityKoreanName: "바르셀로나", cityEnglishName: "Barcelona", famousTownKorean: "바리 고틱", firstFamousCityKorean: "마드리드", secondFamousCityKorean: "발렌시아"),
        "Rome": CityDisplayInfo(cityKoreanName: "로마", cityEnglishName: "Rome", famousTownKorean: "트라스테베레", firstFamousCityKorean: "밀라노", secondFamousCityKorean: "나폴리"),
        "Istanbul": CityDisplayInfo(cityKoreanName: "이스탄불", cityEnglishName: "Istanbul", famousTownKorean: "술탄아흐메트", firstFamousCityKorean: "앙카라", secondFamousCityKorean: "안탈리아"),
        "Dubai": CityDisplayInfo(cityKoreanName: "두바이", cityEnglishName: "Dubai", famousTownKorean: "주메이라", firstFamousCityKorean: "아부다비", secondFamousCityKorean: "샤르자")
    ]

    // MARK: - Init
    init(service: CityRecServicing = CityRecService(), verifiedPlaceIDs: [String] = []) {
        self.service = service
        self.verifiedPlaceIDs = verifiedPlaceIDs
    }

    // MARK: - Collection API
    var numberOfItems: Int { items.count }
    func item(at index: Int) -> CityRecItem { items[index] }

    // MARK: - Loading
    func loadMock(count: Int = 10) {
        self.items = service.loadMock(verifiedPlaceIDs: verifiedPlaceIDs, count: count)
    }

    func loadVerified(limit: Int? = nil) {
        self.items = service.loadVerified(limit: limit)
    }
    
    // MARK: - Display Lookup
    func displayInfo(for cityTitle: String) -> CityDisplayInfo? {
        let normalized = CityPlaceIDs.placeID(for: cityTitle) != nil ? (cityTitle == "Saigon" ? "Ho Chi Minh City" : cityTitle) : cityTitle
        return CityRecModel.displayByCityName[normalized]
    }

    func displayInfo(forPlaceID placeID: String) -> CityDisplayInfo? {
        if let pair = CityPlaceIDs.byCity.first(where: { $0.value == placeID }) {
            return CityRecModel.displayByCityName[pair.key]
        }
        return nil
    }
}
