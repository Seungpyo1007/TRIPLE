//
//  FirestoreService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/26/25.
//

import FirebaseFirestore

class FirestoreService {
    // MARK: - Singleton
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    // MARK: - Profile CRUD
    /// 프로필 저장 (merge)
    func saveProfile(profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        let data: [String: Any] = [
            "uid": profile.uid,
            "name": profile.name,
            "profileImage": profile.profileImage ?? ""
        ]
        
        db.collection("users").document(profile.uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// 프로필 불러오기
    func fetchProfile(uid: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data() else {
                let emptyProfile = UserProfile(uid: uid, name: "", profileImage: nil)
                completion(.success(emptyProfile))
                return
            }
            
            let name = data["name"] as? String ?? ""
            let profileImage = data["profileImage"] as? String
            let finalImage = (profileImage?.isEmpty == false) ? profileImage : nil
            
            let profile = UserProfile(uid: uid, name: name, profileImage: finalImage)
            completion(.success(profile))
        }
    }
}
