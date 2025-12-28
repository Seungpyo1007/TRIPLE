//
//  LoginEmailViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/26/25.
//

import Foundation
import FirebaseAuth

class LoginEmailViewModel {
    // MARK: - 입력
    var email: String = ""
    var password: String = ""
    
    // MARK: - 출력
    var isLoading: ((Bool) -> Void)?
    var loginResult: ((Bool, String?) -> Void)?
    
    // MARK: - API(이메일 로그인)
    func login() {
        // 입력값 유효성 검사
        guard validate() else { return }
        
        // 로딩 상태 시작
        isLoading?(true)
        
        // Firebase 이메일/비밀번호 로그인
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            self.isLoading?(false)
            
            // 로그인 결과 처리
            if let error = error {
                self.loginResult?(false, error.localizedDescription)
            } else {
                self.loginResult?(true, nil)
            }
        }
    }
    
    // MARK: - 유효성 검사
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
