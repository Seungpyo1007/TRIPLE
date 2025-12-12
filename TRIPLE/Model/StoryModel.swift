//
//  StoryModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/12/25.
//

import Foundation

// MARK: - Domain Model

/// Travel content category
enum StoryCategory: String, CaseIterable, Codable, Sendable {
    case nature
    case city
    case food
    case adventure
    case culture

    /// Human readable title
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

/// A story item that represents a YouTube video to play
struct Story: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let category: StoryCategory
    /// YouTube video id (11 chars typically)
    let videoID: String
    /// Optional title/label
    var title: String?

    init(id: UUID = UUID(), category: StoryCategory, videoID: String, title: String? = nil) {
        self.id = id
        self.category = category
        self.videoID = videoID
        self.title = title
    }
}

// MARK: - Static Catalog

/// A small curated catalog of travel-related YouTube video IDs by category.
/// These are sample IDs; replace with your own as needed.
struct StoryCatalog {
    static let videosByCategory: [StoryCategory: [String]] = [
        .nature: [
            "dQw4w9WgXcQ", // Scenic nature
            "dQw4w9WgXcQ",
            "dQw4w9WgXcQ"
        ],
        .city: [
            "dQw4w9WgXcQ", // City timelapse
            "dQw4w9WgXcQ",
            "dQw4w9WgXcQ"
        ],
        .food: [
            "dQw4w9WgXcQ",
            "dQw4w9WgXcQ",
            "dQw4w9WgXcQ"
        ],
        .adventure: [
            "dQw4w9WgXcQ",
            "dQw4w9WgXcQ",
            "dQw4w9WgXcQ"
        ],
        .culture: [
            "dQw4w9WgXcQ",
            "dQw4w9WgXcQ",
            "dQw4w9WgXcQ"
        ]
    ]
}
