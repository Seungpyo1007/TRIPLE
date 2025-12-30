//
//  ProfileService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
import FirebaseAuth

/// 지금은 UserDefaults에 데이터를 저장
final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private let storageKey = "user_profile"

    func loadProfile() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        let uid = Auth.auth().currentUser?.uid ?? "unknown_user"
        return UserProfile(uid: uid, name: "사용자 이름", profileImage: "")
    }

    func saveProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
