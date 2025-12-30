//
//  StoryCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation

final class StoryCollectionViewModel {
    
    // MARK: - Output (ViewModel -> View)
    /// 스토리 아이템 목록이 변경되었을 때 호출되는 콜백입니다.
    var onItemsChanged: (([Story]) -> Void)?
    
    /// 현재 로드된 스토리 아이템 리스트입니다.
    private(set) var items: [Story] = [] {
        didSet { onItemsChanged?(items) }
    }
    
    // MARK: - 로직 (데이터 조회)
    /// 전체 아이템의 개수를 반환합니다.
    var numberOfItems: Int { items.count }
    
    /// 특정 인덱스의 스토리 정보를 가져옵니다.
    func item(at index: Int) -> Story { items[index] }
    
    /// 특정 인덱스 아이템의 비디오 ID(YouTube 등)를 반환합니다.
    func videoIDForItem(at index: Int) -> String? {
        guard index >= 0 && index < items.count else { return nil }
        return items[index].videoID
    }
    
    // MARK: - Inputs
    /// 카테고리별 비디오 카탈로그에서 무작위로 스토리를 생성하여 로드합니다.
    func loadRandomStories(categories: [StoryCategory] = Array(StoryCategory.allCases), itemCount: Int = 10) {
        var generated: [Story] = []
        let categoriesToUse = categories.isEmpty ? Array(StoryCategory.allCases) : categories
        
        // 1. 선택된 카테고리에 해당하는 비디오 데이터 수집
        var pairs: [(StoryCategory, String)] = []
        for cat in categoriesToUse {
            if let vids = StoryCatalog.videosByCategory[cat] {
                for v in vids { pairs.append((cat, v)) }
            }
        }
        
        // 2. 만약 선택된 카테고리에 데이터가 없다면 전체에서 수집
        if pairs.isEmpty {
            for (cat, vids) in StoryCatalog.videosByCategory {
                for v in vids { pairs.append((cat, v)) }
            }
        }
        
        // 3. 수집된 데이터를 셔플하여 요청된 개수만큼 스토리 객체 생성
        if !pairs.isEmpty {
            var pool = pairs.shuffled()
            while generated.count < itemCount {
                if pool.isEmpty { pool = pairs.shuffled() }
                let (cat, vid) = pool.removeFirst()
                generated.append(Story(category: cat, videoID: vid, title: cat.title))
            }
        }
        
        self.items = generated
    }
    
    /// 테스트를 위해 10개의 임시 스토리 데이터를 생성합니다.
    func loadMock() {
        loadRandomStories(itemCount: 10)
    }
}
