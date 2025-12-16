//
//  CityRecModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/15/25.
//

import Foundation

struct CityRecItem {
    let id: UUID = UUID()
    let title: String
    let placeID: String?
}

final class CityRecModel {
    private(set) var items: [CityRecItem] = [] { didSet { onItemsChanged?(items) } }
    var onItemsChanged: (([CityRecItem]) -> Void)?

    private let service: CityRecServicing
    private let verifiedPlaceIDs: [String]

    init(service: CityRecServicing = CityRecService(), verifiedPlaceIDs: [String] = []) {
        self.service = service
        self.verifiedPlaceIDs = verifiedPlaceIDs
    }

    var numberOfItems: Int { items.count }
    func item(at index: Int) -> CityRecItem { items[index] }

    func loadMock(count: Int = 10) {
        self.items = service.loadMock(verifiedPlaceIDs: verifiedPlaceIDs, count: count)
    }

    func loadVerified(limit: Int? = nil) {
        self.items = service.loadVerified(limit: limit)
    }
}
