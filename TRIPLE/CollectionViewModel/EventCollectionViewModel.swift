//
//  EventCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation

struct EventItem {
    let id: UUID = UUID()
    let title: String
}

final class EventCollectionViewModel {
    private(set) var items: [EventItem] = [] { didSet { onItemsChanged?(items) } }
    var onItemsChanged: (([EventItem]) -> Void)?
    
    var numberOfItems: Int { items.count }
    func item(at index: Int) -> EventItem { items[index] }
    
    func loadMock() {
        self.items = (1...10).map { EventItem(title: "Event \($0)") }
    }
}
