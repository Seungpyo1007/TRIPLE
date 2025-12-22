//
//  ProfileEditViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
import UIKit

final class ProfileEditViewModel {
    
    // MARK: - Output (ViewModel -> View)
    /// 프로필 데이터 변경 시 UI 수정을 위해 호출
    var onProfileChanged: ((UserProfile) -> Void)?
    /// 가공된 이미지 데이터를 View에 전달
    var onProfileImageChanged: ((UIImage?) -> Void)?
    
    // MARK: - Properties
    /// 수정 중인 유저의 프로필 상태를 보유
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
    /// 사용자가 입력한 이름을 프로필 모델에 반영
    func setName(_ name: String) {
        profile.name = name
    }

    /// 선택한 이미지를 데이터로 변환하여 프로필 모델에 반영
    func setImage(_ image: UIImage?) {
        if let image = image, let data = image.jpegData(compressionQuality: 0.9) {
            profile.imageData = data
        } else {
            profile.imageData = nil
        }
    }

    /// 변경된 프로필 내용을 저장소(Service)에 영구적으로 기록
    func save() {
        service.saveProfile(profile)
    }

    // MARK: - Helpers
    /// 데이터를 UI에서 표시 가능한 UIImage 객체로 변환
    private func imageFromData(_ data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
}
