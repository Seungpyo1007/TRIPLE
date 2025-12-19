//
//  StoryModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/12/25.
//

import Foundation

// MARK: - 도메인 모델

/// 여행 콘텐츠 카테고리
enum StoryCategory: String, CaseIterable, Codable, Sendable {
    case nature
    case city
    case food
    case adventure
    case culture

    var title: String {
        switch self {
        case .nature: return "Nature"
        case .city: return "City"
        case .food: return "Food"
        case .adventure: return "Adventure"
        case .culture: return "Culture"
        }
    }
}

/// 재생할 유튜브 영상을 나타내는 스토리 항목입니다.
struct Story: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let category: StoryCategory
    /// 유튜브 동영상 ID (일반적으로 11자)
    let videoID: String
    /// 선택 사항 제목/레이블
    var title: String?

    init(id: UUID = UUID(), category: StoryCategory, videoID: String, title: String? = nil) {
        self.id = id
        self.category = category
        self.videoID = videoID
        self.title = title
    }
}

// MARK: - 정적 카탈로그

/// 카테고리별로 정리된 여행 관련 유튜브 영상 ID 모음입니다.
/// 다음은 예시 ID입니다. 필요에 따라 본인의 ID로 교체하십시오. " dQw4w9WgXcQ "
struct StoryCatalog {
    static let videosByCategory: [StoryCategory: [String]] = [
        .nature: [
            "",
            "",
            ""
        ],
        .city: [
            "",
            "",
            ""
        ],
        .food: [
            "",
            "",
            ""
        ],
        .adventure: [
            "",
            "",
            ""
        ],
        .culture: [
            "",
            "",
            ""
        ]
    ]
}
