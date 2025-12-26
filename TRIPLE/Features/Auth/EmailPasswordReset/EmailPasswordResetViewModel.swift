//
//  EmailPasswordResetViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/26/25.
//

import Foundation
import FirebaseAuth

class EmailPasswordResetViewModel {
    // MARK: - Inputs
    var email: String = ""
    
    // MARK: - Outputs (Bindings)
    var isLoading: ((Bool) -> Void)?
    /// (성공여부, 메시지)
    var resetResult: ((Bool, String?) -> Void)?
    
    // MARK: - Public API
    func sendResetEmail() {
        guard validateEmail() else { return }
        
        isLoading?(true)
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            self.isLoading?(false)
            
            if let error = error {
                self.resetResult?(false, error.localizedDescription)
            } else {
                self.resetResult?(true, "비밀번호 재설정 이메일을 보냈습니다. 편지함을 확인해주세요.")
            }
        }
    }
    
    // MARK: - Validation
    private func validateEmail() -> Bool {
        if email.isEmpty || !email.contains("@") {
            resetResult?(false, "올바른 이메일 형식을 입력해주세요.")
            return false
        }
        return true
    }
}
