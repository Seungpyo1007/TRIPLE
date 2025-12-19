//
//  BenefitCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation

struct BenefitItem {
    let id: UUID = UUID()
    let title: String
}

final class BenefitCollectionViewModel {
    private(set) var items: [BenefitItem] = [] { didSet { onItemsChanged?(items) } }
    var onItemsChanged: (([BenefitItem]) -> Void)?
    
    var numberOfItems: Int { items.count }
    func item(at index: Int) -> BenefitItem { items[index] }
    
    func loadMock() {
        self.items = (1...10).map { BenefitItem(title: "Benefit \($0)") }
    }
}
