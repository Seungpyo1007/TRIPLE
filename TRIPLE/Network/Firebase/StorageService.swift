//
//  StorageService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/26/25.
//

import FirebaseStorage
import UIKit

class StorageService {
    // MARK: - Singleton
    static let shared = StorageService()
    private let storage = Storage.storage().reference()

    // MARK: - Uploads
    /// 프로필 이미지를 업로드하고 다운로드 URL을 반환합니다.
    func uploadProfileImage(uid: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "ImageConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패"])))
            return
        }
        
        let ref = storage.child("profiles/\(uid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("업로드 실패: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("URL 가져오기 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let urlString = url?.absoluteString {
                    completion(.success(urlString))
                }
            }
        }
    }
}
