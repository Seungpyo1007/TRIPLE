//
//  ProfileService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation

/// 지금은 UserDefaults에 데이터를 저장합니다. 나중에 실제 백엔드로 바꿀 수 있습니다.
final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private let storageKey = "user_profile"

    func loadProfile() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        // Default profile if none stored yet
        return UserProfile(name: "")
    }

    func saveProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
