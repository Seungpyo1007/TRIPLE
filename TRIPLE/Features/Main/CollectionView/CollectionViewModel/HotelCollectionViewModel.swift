//
//  HotelCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation
import UIKit

final class HotelCollectionViewModel {
    
    // MARK: - Output (ViewModel -> View)
    /// 호텔 목록이 변경되었을 때 View 업데이트를 위해 호출되는 콜백입니다.
    var onItemsChanged: (([HotelItem]) -> Void)? {
        didSet { model.onItemsChanged = onItemsChanged }
    }

    // MARK: - 상수 & 초기화
    private let model: HotelModel

    init() {
        self.model = HotelModel()
        // 모델의 데이터 변경 이벤트를 뷰모델의 콜백으로 연결
        self.model.onItemsChanged = { [weak self] items in
            self?.onItemsChanged?(items)
        }
    }

    // MARK: - 로직 (데이터 조회)
    /// 전체 아이템의 개수를 반환
    var numberOfItems: Int { model.numberOfItems }
    
    /// 특정 인덱스의 호텔 정보를 가져옴
    func item(at index: Int) -> HotelItem { model.item(at: index) }
    
    /// 검증된 호텔 목록을 불러옴
    func loadVerified(limit: Int? = nil) {
        model.loadVerified(limit: limit)
    }

    /// 특정 도시의 호텔을 실시간으로 검색하여 로드
    func loadHotelsRealtime(city: String = "Tokyo", limit: Int = 12) {
        model.loadHotelsRealtime(city: city, limit: limit)
    }

    // MARK: - 로직 (사진 및 텍스트 처리)
    /// 특정 항목의 사진을 로드 (크기 200x200 고정)
    func loadPhotoForItem(at index: Int, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let item = model.item(at: index)
        
        guard let placeID = item.placeID else {
            completion(nil)
            return
        }
        
        // 고정 크기 설정 (200x200)
        let fixedSize = CGSize(width: 200, height: 200)
        
        model.fetchPhoto(for: placeID, maxSize: fixedSize) { image in
            completion(image)
        }
    }

    /// 호텔 평점 정보를 표시용 텍스트로 변환
    func infoText(for item: HotelItem) -> String {
        if let rating = item.ratingJP {
            return "일본 평점 : \(String(format: "%.1f", rating))"
        } else {
            return "일본 평점 : -"
        }
    }

    /// 호텔 가격 정보를 통화 (JPY) 텍스트로 변환
    func priceText(for item: HotelItem) -> String {
        if let price = item.priceJPY {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let text = formatter .string(from: NSNumber(value: price)) ?? "\(price)"
            return "\(text) JPY"
        } else {
            return "가격 정보 없음"
        }
    }
}
