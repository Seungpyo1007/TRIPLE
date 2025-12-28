//
//  SideMenuViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
import UIKit
import FirebaseAuth

final class SideMenuViewModel {
    
    // MARK: - Outputs (Bindings)
    /// 유저 프로필 정보가 변경되었을 때 호출
    var onProfileChanged: ((UserProfile) -> Void)?
    
    // MARK: - State
    /// 현재 로드된 유저 프로필 데이터
    private(set) var profile: UserProfile = UserProfile(uid: "", name: "", profileImage: nil) {
        didSet { onProfileChanged?(profile) }
    }
    
    // MARK: - Init
    init() {
        self.reload()
    }

    // MARK: - API
    /// 최신 프로필 데이터를 불러옴
    func reload() {
        if let user = Auth.auth().currentUser {
            let newProfile = UserProfile(
                uid: user.uid,
                name: user.displayName ?? "사용자",
                profileImage: user.photoURL?.absoluteString
            )
            self.profile = newProfile
        }
    }
}
