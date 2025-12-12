//
//  CityRecCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation

struct CityRecItem {
    let id: UUID = UUID()
    let title: String
}

final class CityRecCollectionViewModel {
    private(set) var items: [CityRecItem] = [] { didSet { onItemsChanged?(items) } }
    var onItemsChanged: (([CityRecItem]) -> Void)?

    var numberOfItems: Int { items.count }
    func item(at index: Int) -> CityRecItem { items[index] }

    func loadMock() {
        self.items = (1...10).map { CityRecItem(title: "City \($0)") }
    }
}
