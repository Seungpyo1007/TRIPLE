//
//  LoginEmailViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/26/25.
//

import Foundation
import FirebaseAuth

class LoginEmailViewModel {
    // MARK: - Inputs
    var email: String = ""
    var password: String = ""
    
    // MARK: - Outputs (Bindings)
    var isLoading: ((Bool) -> Void)?
    var loginResult: ((Bool, String?) -> Void)?
    
    // MARK: - Public API
    func login() {
        guard validate() else { return }
        
        isLoading?(true)
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            self.isLoading?(false)
            
            if let error = error {
                self.loginResult?(false, error.localizedDescription)
            } else {
                self.loginResult?(true, nil)
            }
        }
    }
    
    // MARK: - Validation
    private func validate() -> Bool {
        if email.isEmpty || !email.contains("@") {
            loginResult?(false, "유효한 이메일 형식이 아닙니다.")
            return false
        }
        if password.count < 6 {
            loginResult?(false, "비밀번호는 6자리 이상이어야 합니다.")
            return false
        }
        return true
    }
}
