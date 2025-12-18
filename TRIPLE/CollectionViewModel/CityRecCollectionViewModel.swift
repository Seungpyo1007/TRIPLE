//
//  CityRecCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation
import UIKit

final class CityRecCollectionViewModel {
    private let model: CityRecModel
    private let photoService: PlacePhotoProviding

    var onItemsChanged: (([CityRecItem]) -> Void)? {
        didSet { model.onItemsChanged = onItemsChanged }
    }

    init(photoService: PlacePhotoProviding = GooglePlacesPhotoService(), verifiedPlaceIDs: [String] = []) {
        self.photoService = photoService
        self.model = CityRecModel(verifiedPlaceIDs: verifiedPlaceIDs)
        self.model.onItemsChanged = { [weak self] items in
            self?.onItemsChanged?(items)
        }
    }

    var numberOfItems: Int { model.numberOfItems }

    func item(at index: Int) -> CityRecItem { model.item(at: index) }

    func loadMock() { model.loadMock() }

    func loadPhotoForItem(at index: Int, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let item = model.item(at: index)
        guard let placeID = item.placeID else {
            completion(nil)
            return
        }
        photoService.fetchFirstPhoto(for: placeID, maxSize: targetSize) { data in
            var image: UIImage? = nil
            if let data = data {
                image = UIImage(data: data)
            }
            if image == nil {
                print("[CityRecCollectionViewModel] Photo fetch failed or nil for placeID: \(placeID)")
            }
            completion(image)
        }
    }

    func cityForItem(at index: Int) -> City {
        let item = model.item(at: index)
        return CityService().city(forName: item.title)
    }
}
