import Foundation
import UIKit

final class HotelCollectionViewModel {
    private let model: HotelModel

    var onItemsChanged: (([HotelItem]) -> Void)? {
        didSet { model.onItemsChanged = onItemsChanged }
    }

    init() {
        self.model = HotelModel()
        self.model.onItemsChanged = { [weak self] items in
            self?.onItemsChanged?(items)
        }
    }

    var numberOfItems: Int { model.numberOfItems }
    func item(at index: Int) -> HotelItem { model.item(at: index) }

    // 기존 Mock 로드 - 실시간 검색 권장!
    func loadMock() {
        print("[ViewModel] ⚠️ loadMock() - Use loadHotelsRealtime() for better results")
        model.loadMockJapanHotels(limit: 12)
    }
    
    func loadVerified(limit: Int? = nil) {
        print("[ViewModel] ⚠️ loadVerified() - Use loadHotelsRealtime() for better results")
        model.loadVerified(limit: limit)
    }

    // 실시간 검색으로 호텔 로드
    func loadHotelsRealtime(city: String = "Tokyo", limit: Int = 12) {
        model.loadHotelsRealtime(city: city, limit: limit)
    }

    // 사진 로드 (고정 크기 200x200)
    func loadPhotoForItem(at index: Int, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let item = model.item(at: index)
        
        guard let placeID = item.placeID else {
            print("[ViewModel] ⚠️ No PlaceID for hotel: \(item.title)")
            completion(nil)
            return
        }
        
        // 크기 고정 200x200
        let fixedSize = CGSize(width: 200, height: 200)
        
        print("[ViewModel] 📸 Loading photo for: \(item.title) (PlaceID: \(placeID))")
        
        model.fetchPhoto(for: placeID, maxSize: fixedSize) { image in
            if image != nil {
                print("[ViewModel] ✅ Photo loaded for: \(item.title)")
            } else {
                print("[ViewModel] ❌ Photo failed for: \(item.title)")
            }
            completion(image)
        }
    }

    func infoText(for item: HotelItem) -> String {
        if let rating = item.ratingJP {
            return "일본 평점 : \(String(format: "%.1f", rating))"
        } else {
            return "일본 평점 : -"
        }
    }

    func priceText(for item: HotelItem) -> String {
        if let price = item.priceJPY {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let text = formatter.string(from: NSNumber(value: price)) ?? "\(price)"
            return "\(text) JPY"
        } else {
            return "가격 정보 없음"
        }
    }
}
