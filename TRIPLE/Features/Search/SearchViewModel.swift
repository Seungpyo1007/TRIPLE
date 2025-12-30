//
//  SearchViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
import UIKit

final class SearchViewModel {
    
    // MARK: - 출력 (ViewModel -> View)
    /// 검색 결과 리스트가 변경되었을 때 View에 알리는 콜백
    var onResultsChanged: (([PlaceItem]) -> Void)?
    
    /// 현재 검색된 장소들의 리스트입니다. 데이터가 변경되면 자동으로 콜백을 호출
    private(set) var results: [PlaceItem] = [] {
        didSet {
            onResultsChanged?(results)
        }
    }
    
    // MARK: - 상수 & 초기화
    private let service: SearchServicing
    
    init(service: SearchServicing = SearchService()) {
        self.service = service
    }

    // MARK: - Search
    /// 입력된 텍스트를 바탕으로 장소를 검색하고 결과를 업데이트
    func search(text: String) {
        service.searchPlaces(text: text) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                // UI 업데이트는 메인 스레드에서 진행
                DispatchQueue.main.async { self.results = items }
            case .failure(let error):
                print("[SearchViewModel] 검색 실패: \(error.localizedDescription)")
                DispatchQueue.main.async { self.results = [] }
            }
        }
    }

    // MARK: - Photos
    /// 장소의 첫 번째 사진을 가져옴 기본 크기는 200x200
    func fetchFirstPhoto(placeID: String, maxSize: CGSize = CGSize(width: 200, height: 200), completion: @escaping (UIImage?) -> Void) {
        service.fetchFirstPhoto(placeID: placeID, maxSize: maxSize, completion: completion)
    }
}
