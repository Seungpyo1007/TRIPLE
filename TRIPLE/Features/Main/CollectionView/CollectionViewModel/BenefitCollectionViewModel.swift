//
//  BenefitCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation

// MARK: - 데이터 모델
struct BenefitItem {
    let id: UUID = UUID()
    let title: String
}

// MARK: - 뷰모델
final class BenefitCollectionViewModel {
    
    // MARK: - 프로퍼티 (데이터 및 상태)
    private(set) var items: [BenefitItem] = [] {
        didSet { onItemsChanged?(items) }
    }
    var onItemsChanged: (([BenefitItem]) -> Void)?
    
    // MARK: - 읽기 전용 속성 (계산된 프로퍼티)
    var numberOfItems: Int { items.count }
    
    // MARK: - 메서드 (비즈니스 로직)
    func item(at index: Int) -> BenefitItem {
        items[index]
    }
    
    func loadMock() {
        self.items = (1...10).map { BenefitItem(title: "Benefit \($0)") }
    }
}
