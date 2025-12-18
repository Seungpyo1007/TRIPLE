//
//  HotelModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/17/25.
//

import Foundation
import UIKit

struct HotelItem {
    let id: UUID = UUID()
    let title: String
    let placeID: String?
    let ratingJP: Double?
    let priceJPY: Int?
}

final class HotelModel {
    private(set) var items: [HotelItem] = [] {
        didSet {
            onItemsChanged?(items)
        }
    }
    
    var onItemsChanged: (([HotelItem]) -> Void)?

    private let service: HotelServicing

    init(service: HotelServicing = HotelService()) {
        self.service = service
    }

    var numberOfItems: Int { items.count }
    func item(at index: Int) -> HotelItem { items[index] }

    // Mock 데이터 로드
    func loadMockJapanHotels(limit: Int = 10) {
        self.items = service.loadMockJapanHotels(limit: limit)
    }

    func loadVerified(limit: Int? = nil) {
        self.items = service.loadVerified(limit: limit)
    }

    // 실시간 검색으로 호텔 로드
    func loadHotelsRealtime(city: String = "Tokyo", limit: Int = 12) {
        print("[Model] 🔍 Searching \(limit) hotels in \(city)...")
        
        service.searchHotelsRealtime(city: city, limit: limit) { [weak self] hotels in
            DispatchQueue.main.async {
                print("[Model] ✅ Received \(hotels.count) hotels")
                for hotel in hotels {
                    print("   - \(hotel.title) | PlaceID: \(hotel.placeID ?? "NONE")")
                }
                self?.items = hotels
            }
        }
    }
    
    // 사진 로드
    func fetchPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        service.fetchPhoto(for: placeID, maxSize: maxSize, completion: completion)
    }
}

extension HotelModel {
    func indexOfItem(with id: UUID) -> Int? {
        return items.firstIndex { $0.id == id }
    }

    func itemID(at index: Int) -> UUID { items[index].id }
}
