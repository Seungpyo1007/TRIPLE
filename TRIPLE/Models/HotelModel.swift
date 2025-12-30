//
//  HotelModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/17/25.
//

import Foundation
import UIKit

// MARK: - 호텔 모델
/// 호텔 아이템 구조체
struct HotelItem {
    /// 고유 식별자
    let id: UUID = UUID()
    /// 호텔 제목
    let title: String
    /// Google Places API의 Place ID
    let placeID: String?
    /// 일본어 평점
    let ratingJP: Double?
    /// 일본 엔화 가격
    let priceJPY: Int?
}

final class HotelModel {
    // MARK: - 출력
    /// 호텔 아이템 목록 (변경 시 클로저 호출)
    private(set) var items: [HotelItem] = [] {
        didSet {
            onItemsChanged?(items)
        }
    }
    /// 아이템 목록이 변경될 때 호출되는 클로저
    var onItemsChanged: (([HotelItem]) -> Void)?

    // MARK: - 의존성
    /// 호텔 서비스
    private let service: HotelServicing

    // MARK: - 초기화
    init(service: HotelServicing = HotelService()) {
        self.service = service
    }

    // MARK: - 컬렉션 API
    /// 아이템 개수 반환
    var numberOfItems: Int { items.count }
    /// 특정 인덱스의 아이템 반환
    func item(at index: Int) -> HotelItem { items[index] }

    // MARK: - 로딩
    /// 일본 호텔 목업 데이터를 로드합니다.
    func loadMockJapanHotels(limit: Int = 10) {
        self.items = service.loadMockJapanHotels(limit: limit)
    }

    /// 검증된 호텔 목록을 로드합니다.
    func loadVerified(limit: Int? = nil) {
        self.items = service.loadVerified(limit: limit)
    }

    /// 실시간 검색으로 호텔을 로드합니다.
    func loadHotelsRealtime(city: String = "Tokyo", limit: Int = 12) {
        service.searchHotelsRealtime(city: city, limit: limit) { [weak self] hotels in
            DispatchQueue.main.async {
                self?.items = hotels
            }
        }
    }
    
    // MARK: - 이미지 로딩
    /// Place ID로 호텔 사진을 가져옵니다.
    func fetchPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        service.fetchPhoto(for: placeID, maxSize: maxSize, completion: completion)
    }
}

// MARK: - 도우미 메서드
extension HotelModel {
    /// ID로 아이템의 인덱스를 찾습니다.
    func indexOfItem(with id: UUID) -> Int? {
        return items.firstIndex { $0.id == id }
    }

    /// 인덱스로 아이템의 ID를 반환합니다.
    func itemID(at index: Int) -> UUID { items[index].id }
}
