//
//  SettingsViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
import FirebaseAuth

final class SettingsViewModel {
    
    // MARK: - 로그아웃 처리
    func logout(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            print("Logout Error: \(error.localizedDescription)")
            completion(false)
        }
    }
}
