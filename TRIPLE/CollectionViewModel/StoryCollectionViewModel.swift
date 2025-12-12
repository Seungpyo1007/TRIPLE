//
//  StoryCollectionViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import Foundation
import YouTubePlayerKit

struct StoryItem {
    let id: UUID = UUID()
    let title: String
}

final class StoryCollectionViewModel {
    // Outputs
    private(set) var items: [StoryItem] = [] {
        didSet { onItemsChanged?(items) }
    }

    // Binding callback
    var onItemsChanged: (([StoryItem]) -> Void)?

    var numberOfItems: Int { items.count }

    func item(at index: Int) -> StoryItem { items[index] }

    func videoIDForItem(at index: Int) -> String? {
        let title = items[index].title
        if let source = YouTubePlayer.Source(urlString: title),
           case let .video(id: parsedID) = source {
            return parsedID
        }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty, !trimmed.contains(" "), trimmed.count <= 64 {
            return trimmed
        }
        return nil
    }

    // Inputs
    func loadMock() {
        self.items = (1...10).map { StoryItem(title: "Story \($0)") }
    }
}
