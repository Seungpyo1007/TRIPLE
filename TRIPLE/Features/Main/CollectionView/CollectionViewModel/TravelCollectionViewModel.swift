//
//  TravelCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation

// MARK: - 데이터 모델 목업
struct TravelItem {
    let id: UUID = UUID()
    let title: String
}

final class TravelCollectionViewModel {
    
    // MARK: - 데이터 저장소 및 바인딩
    private(set) var items: [TravelItem] = [] { didSet { onItemsChanged?(items) } }
    var onItemsChanged: (([TravelItem]) -> Void)?

    // MARK: - 데이터 조회
    var numberOfItems: Int { items.count }
    
    // MARK: - 특정 인덱스의 아이템 정보를 가져옴
    func item(at index: Int) -> TravelItem { items[index] }

    // MARK: - 테스트를 위해 10개의 임시 데이터를 생성하여 목록을 채움
    func loadMock() {
        self.items = (1...10).map { TravelItem(title: "Travel \($0)") }
    }
}
