//
//  MainViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation

struct Story {
    let id: UUID = UUID()
    let title: String
    let imageName: String? // Placeholder for future image support
}

final class MainViewModel {
    // MARK: - Outputs
    private(set) var stories: [Story] = {
        return (1...10).map { Story(title: "Story \($0)", imageName: nil) }
    }() {
        didSet { self.onStoriesChanged?(stories) }
    }

    // 바인딩용 콜백
    var onStoriesChanged: (([Story]) -> Void)?

    var numberOfStories: Int { stories.count }

    func story(at index: Int) -> Story {
        return stories[index]
    }

    // MARK: - Inputs (데이터 갱신 시)
    func reload() {
        // 향후 네트워크/캐시 로직 추가
        // self.stories = fetched
    }
}
