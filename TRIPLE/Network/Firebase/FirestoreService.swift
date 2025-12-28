//
//  FirestoreService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/26/25.
//

import FirebaseFirestore

class FirestoreService {
    // MARK: - 싱글톤
    /// FirestoreService의 공유 인스턴스
    static let shared = FirestoreService()
    /// Firestore 데이터베이스 인스턴스
    private let db = Firestore.firestore()

    // MARK: - 프로필 CRUD
    /// 프로필 정보를 Firestore에 저장합니다 (기존 데이터와 병합)
    func saveProfile(profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        let data: [String: Any] = [
            "uid": profile.uid,
            "name": profile.name,
            "profileImage": profile.profileImage ?? ""
        ]
        
        // merge: true로 설정하여 기존 데이터와 병합
        db.collection("users").document(profile.uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Firestore에서 사용자 프로필 정보를 가져옵니다
    func fetchProfile(uid: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 문서가 없으면 빈 프로필 반환
            guard let data = snapshot?.data() else {
                let emptyProfile = UserProfile(uid: uid, name: "", profileImage: nil)
                completion(.success(emptyProfile))
                return
            }
            
            // Firestore 데이터를 UserProfile로 변환
            let name = data["name"] as? String ?? ""
            let profileImage = data["profileImage"] as? String
            // 빈 문자열은 nil로 처리
            let finalImage = (profileImage?.isEmpty == false) ? profileImage : nil
            
            let profile = UserProfile(uid: uid, name: name, profileImage: finalImage)
            completion(.success(profile))
        }
    }
}
