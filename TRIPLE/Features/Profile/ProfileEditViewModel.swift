//
//  ProfileEditViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
import UIKit
import FirebaseAuth

final class ProfileEditViewModel {
    
    // MARK: - 출력
    /// 뷰모델에서 뷰로 전달하는 출력 클로저들
    var onProfileLoaded: ((UserProfile) -> Void)?
    var onProfileImageChanged: ((UIImage?) -> Void)?
    var isLoading: ((Bool) -> Void)?
    var onSaveResult: ((Bool, String?) -> Void)?
    
    // MARK: - 속성
    /// 현재 편집 중인 프로필 정보 (외부에서 읽기만 가능)
    private(set) var profile: UserProfile
    /// 업로드 전 임시 보관하는 선택된 이미지 (Data 아님)
    private var selectedUIImage: UIImage?

    // MARK: - 초기화
    init(profile: UserProfile) {
        self.profile = profile
    }
    
    // MARK: - API
    /// Firestore에서 현재 프로필 정보를 가져와서 뷰에 전달
    func fetchCurrentProfile() {
        isLoading?(true)
        FirestoreService.shared.fetchProfile(uid: profile.uid) { [weak self] result in
            self?.isLoading?(false)
            
            switch result {
            case .success(let fetchedProfile):
                guard let self = self else { return }
                
                // 1. Firestore에서 가져온 이름
                var finalName = fetchedProfile.name
                // 2. 만약 Firestore 이름이 비어있다면 -> 구글 로그인 정보 사용
                if finalName.isEmpty {
                    finalName = Auth.auth().currentUser?.displayName ?? ""
                }
                
                // 3. Firestore 이미지
                var finalImage = fetchedProfile.profileImage
                // 4. 만약 Firestore 이미지가 없다면 -> 구글 프로필 이미지 사용
                if finalImage == nil || finalImage?.isEmpty == true {
                    finalImage = Auth.auth().currentUser?.photoURL?.absoluteString
                }
                
                // 5. 최종 데이터로 업데이트
                let finalProfile = UserProfile(uid: self.profile.uid, name: finalName, profileImage: finalImage)
                self.profile = finalProfile
                
                // View에 알림
                self.onProfileLoaded?(finalProfile)
                
            case .failure(let error):
                print("프로필 로드 실패: \(error.localizedDescription)")
                // 실패해도 기존에 init으로 받은(Auth) 정보가 있으니 그대로 둠
                if let self = self {
                    self.onProfileLoaded?(self.profile)
                }
            }
        }
    }

    /// 사용자가 입력한 이름을 프로필에 설정
    func setName(_ name: String) {
        profile.name = name
    }

    /// 사용자가 선택한 이미지를 프로필에 설정
    func setImage(_ image: UIImage?) {
        self.selectedUIImage = image
        onProfileImageChanged?(image)
    }

    /// 변경된 프로필 정보를 Firestore와 Firebase Auth에 저장
    func save() {
        isLoading?(true)
        
        if let image = selectedUIImage {
            // 1. Storage에 이미지를 먼저 올리고 URL(String)을 받아옴
            StorageService.shared.uploadProfileImage(uid: profile.uid, image: image) { [weak self] result in
                switch result {
                case .success(let urlString):
                    self?.profile.profileImage = urlString
                    self?.updateUserProfileChangeRequest(photoURL: URL(string: urlString))
                    self?.updateFirestore()
                case .failure(let error):
                    self?.isLoading?(false)
                    self?.onSaveResult?(false, error.localizedDescription)
                }
            }
        } else {
            // 이름만 변경된 경우
            if profile.name != Auth.auth().currentUser?.displayName {
                updateUserProfileChangeRequest(name: profile.name)
            }
            updateFirestore()
        }
    }
    
    // MARK: - 내부 메서드
    /// Firebase Auth의 사용자 프로필 정보 업데이트
    private func updateUserProfileChangeRequest(name: String? = nil, photoURL: URL? = nil) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        if let name = name { changeRequest?.displayName = name }
        if let photoURL = photoURL { changeRequest?.photoURL = photoURL }
        changeRequest?.commitChanges(completion: nil)
    }

    /// Firestore에 프로필 정보 저장
    private func updateFirestore() {
        FirestoreService.shared.saveProfile(profile: self.profile) { [weak self] result in
            self?.isLoading?(false)
            switch result {
            case .success:
                self?.onSaveResult?(true, nil)
            case .failure(let error):
                self?.onSaveResult?(false, error.localizedDescription)
            }
        }
    }
}
