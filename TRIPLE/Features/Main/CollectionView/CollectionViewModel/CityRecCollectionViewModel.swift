//
//  CityRecCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation
import UIKit

final class CityRecCollectionViewModel {
    
    // MARK: - Output (ViewModel -> View)
    /// 도시 추천 목록이 업데이트되었을 때 호출되는 콜백입니다.
    var onItemsChanged: (([CityRecItem]) -> Void)? {
        didSet { model.onItemsChanged = onItemsChanged }
    }

    // MARK: - 상수 & 초기화
    private let model: CityRecModel
    private let photoService: PlacePhotoProviding

    init(photoService: PlacePhotoProviding = GooglePlacesPhotoService(), verifiedPlaceIDs: [String] = []) {
        self.photoService = photoService
        self.model = CityRecModel(verifiedPlaceIDs: verifiedPlaceIDs)
        
        // Model의 데이터 변경을 ViewModel의 Output으로 연결
        self.model.onItemsChanged = { [weak self] items in
            self?.onItemsChanged?(items)
        }
    }

    // MARK: - 로직 (데이터 조회)
    /// 전체 아이템의 개수를 반환합니다.
    var numberOfItems: Int { model.numberOfItems }

    /// 특정 인덱스의 도시 추천 아이템을 가져옵니다.
    func item(at index: Int) -> CityRecItem { model.item(at: index) }

    /// 특정 인덱스의 아이템을 기반으로 상세 City 모델 객체를 생성합니다.
    func cityForItem(at index: Int) -> City {
        let item = model.item(at: index)
        return CityService().city(forName: item.title)
    }

    // MARK: - Inputs
    /// 테스트용 임시 도시 목록 데이터를 로드합니다.
    func loadMock() {
        model.loadMock()
    }

    /// 특정 도시의 썸네일 사진을 가져옵니다.
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
                print("[CityRecCollectionViewModel] 사진 로드 실패 혹은 데이터 없음 (placeID: \(placeID))")
            }
            
            completion(image)
        }
    }
}
