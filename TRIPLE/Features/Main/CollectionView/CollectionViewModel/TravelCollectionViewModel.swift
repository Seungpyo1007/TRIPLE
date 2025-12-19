//
//  TravelCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation

struct TravelItem {
    let id: UUID = UUID()
    let title: String
}

final class TravelCollectionViewModel {
    private(set) var items: [TravelItem] = [] { didSet { onItemsChanged?(items) } }
    var onItemsChanged: (([TravelItem]) -> Void)?

    var numberOfItems: Int { items.count }
    func item(at index: Int) -> TravelItem { items[index] }

    func loadMock() {
        self.items = (1...10).map { TravelItem(title: "Travel \($0)") }
    }
}
