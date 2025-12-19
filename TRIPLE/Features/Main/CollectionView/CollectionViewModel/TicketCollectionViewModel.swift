//
//  TicketCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation

struct TicketItem {
    let id: UUID = UUID()
    let title: String
}

final class TicketCollectionViewModel {
    private(set) var items: [TicketItem] = [] { didSet { onItemsChanged?(items) } }
    var onItemsChanged: (([TicketItem]) -> Void)?

    var numberOfItems: Int { items.count }
    func item(at index: Int) -> TicketItem { items[index] }

    func loadMock() {
        self.items = (1...10).map { TicketItem(title: "Ticket \($0)") }
    }
}
