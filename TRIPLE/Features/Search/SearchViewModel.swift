//
//  SearchViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
import UIKit

final class SearchViewModel {
    private let service: SearchServicing

    init(service: SearchServicing = SearchService()) {
        self.service = service
    }

    private(set) var results: [PlaceItem] = [] {
        didSet { onResultsChanged?(results) }
    }
    var onResultsChanged: (([PlaceItem]) -> Void)?

    // MARK: - Search
    func search(text: String) {
        service.searchPlaces(text: text) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let items):
                DispatchQueue.main.async { self.results = items }
            case .failure:
                DispatchQueue.main.async { self.results = [] }
            }
        }
    }

    // MARK: - Photos
    func fetchFirstPhoto(placeID: String, maxSize: CGSize = CGSize(width: 200, height: 200), completion: @escaping (UIImage?) -> Void) {
        service.fetchFirstPhoto(placeID: placeID, maxSize: maxSize, completion: completion)
    }
}
