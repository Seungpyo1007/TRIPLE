//
//  StoryCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation

final class StoryCollectionViewModel {
    // Outputs
    private(set) var items: [Story] = [] {
        didSet { onItemsChanged?(items) }
    }
    
    // Binding callback
    var onItemsChanged: (([Story]) -> Void)?
    
    var numberOfItems: Int { items.count }
    
    func item(at index: Int) -> Story { items[index] }
    
    func videoIDForItem(at index: Int) -> String? {
        guard index >= 0 && index < items.count else { return nil }
        return items[index].videoID
    }
    
    // MARK: - Inputs
    /// Load random stories for given categories
    func loadRandomStories(categories: [StoryCategory] = Array(StoryCategory.allCases), itemCount: Int = 10) {
        var generated: [Story] = []
        let categoriesToUse = categories.isEmpty ? Array(StoryCategory.allCases) : categories
        
        // Pre-build a flattened list of (category, videoID)
        var pairs: [(StoryCategory, String)] = []
        for cat in categoriesToUse {
            if let vids = StoryCatalog.videosByCategory[cat] {
                for v in vids { pairs.append((cat, v)) }
            }
        }
        // Fallback: if empty, use entire catalog
        if pairs.isEmpty {
            for (cat, vids) in StoryCatalog.videosByCategory { for v in vids { pairs.append((cat, v)) } }
        }
        
        // Shuffle and pick itemCount, allowing repeats if needed
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
    
    /// Backward-compat mock loader
    func loadMock() {
        loadRandomStories(itemCount: 10)
    }
}
