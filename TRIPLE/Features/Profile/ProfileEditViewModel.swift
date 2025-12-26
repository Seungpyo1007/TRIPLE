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
    
    var onProfileLoaded: ((UserProfile) -> Void)?
    var onProfileImageChanged: ((UIImage?) -> Void)?
    var isLoading: ((Bool) -> Void)?
    var onSaveResult: ((Bool, String?) -> Void)?
    
    private(set) var profile: UserProfile
    private var selectedUIImage: UIImage? // 업로드 전 임시 보관 (Data 아님)

    init(profile: UserProfile) {
        self.profile = profile
    }
    
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

    func setName(_ name: String) {
        profile.name = name
    }

    func setImage(_ image: UIImage?) {
        self.selectedUIImage = image
        onProfileImageChanged?(image)
    }

    func save() {
        isLoading?(true)
        
        if let image = selectedUIImage {
            // 1. Storage에 이미지를 먼저 올리고 URL(String)을 받아옴
            StorageService.shared.uploadProfileImage(uid: profile.uid, image: image) { [weak self] result in
                switch result {
                case .success(let urlString):
                    // 🔥 이제 String을 String 필드에 넣으니까 에러가 안 납니다.
                    self?.profile.profileImage = urlString
                    // Auth 정보도 업데이트 (선택 사항)
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
    
    private func updateUserProfileChangeRequest(name: String? = nil, photoURL: URL? = nil) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        if let name = name { changeRequest?.displayName = name }
        if let photoURL = photoURL { changeRequest?.photoURL = photoURL }
        changeRequest?.commitChanges(completion: nil)
    }

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
