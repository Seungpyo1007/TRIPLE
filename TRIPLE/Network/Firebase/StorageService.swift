//
//  StorageService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/26/25.
//

import FirebaseStorage
import UIKit

class StorageService {
    // MARK: - 싱글톤
    /// StorageService의 공유 인스턴스
    static let shared = StorageService()
    /// Firebase Storage 참조
    private let storage = Storage.storage().reference()

    // MARK: - 업로드
    /// 프로필 이미지를 Firebase Storage에 업로드하고 다운로드 URL을 반환합니다.
    func uploadProfileImage(uid: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // 이미지를 JPEG 데이터로 변환 (압축 품질 50%)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "ImageConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패"])))
            return
        }
        
        // Storage 경로 설정: profiles/{uid}.jpg
        let ref = storage.child("profiles/\(uid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 이미지 업로드
        ref.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("업로드 실패: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // 업로드 성공 후 다운로드 URL 가져오기
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
