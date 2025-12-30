//
//  EmailPasswordResetViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/26/25.
//

import Foundation
import FirebaseAuth

class EmailPasswordResetViewModel {
    // MARK: - 입력
    var email: String = ""
    
    // MARK: - 출력
    var isLoading: ((Bool) -> Void)?
    var resetResult: ((Bool, String?) -> Void)?
    
    // MARK: - API(비밀번호 재설정 이메일 전송)
    func sendResetEmail() {
        // 이메일 유효성 검사
        guard validateEmail() else { return }
        
        // 로딩 상태 시작
        isLoading?(true)
        
        // Firebase 비밀번호 재설정 이메일 전송
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            self.isLoading?(false)
            
            // 전송 결과 처리
            if let error = error {
                self.resetResult?(false, error.localizedDescription)
            } else {
                self.resetResult?(true, "비밀번호 재설정 이메일을 보냈습니다. 편지함을 확인해주세요.")
            }
        }
    }
    
    // MARK: - 유효성 검사
    private func validateEmail() -> Bool {
        if email.isEmpty || !email.contains("@") {
            resetResult?(false, "올바른 이메일 형식을 입력해주세요.")
            return false
        }
        return true
    }
}
