//
//  SideMenuViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
import UIKit

final class SideMenuViewModel {
    
    // MARK: - Output (ViewModel -> View)
    /// 유저 프로필 정보가 변경되었을 때 호출
    var onProfileChanged: ((UserProfile) -> Void)?
    /// 프로필 이미지가 가공되어 준비되었을 때 호출
    var onProfileImageChanged: ((UIImage?) -> Void)?
    
    // MARK: - Properties
    /// 현재 로드된 유저 프로필 데이터
    private(set) var profile: UserProfile {
        didSet {
            onProfileChanged?(profile)
            onProfileImageChanged?(imageFromData(profile.imageData))
        }
    }
    
    // MARK: - 상수 & 초기화
    private let service: ProfileService
    
    init(service: ProfileService = .shared) {
        self.service = service
        self.profile = service.loadProfile()
    }

    // MARK: - Input
    /// 서비스를 통해 최신 프로필 데이터를 다시 불러옴
    func reload() {
        profile = service.loadProfile()
    }
    
    /// Data 포맷을 UIImage로 변환
    private func imageFromData(_ data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
}
