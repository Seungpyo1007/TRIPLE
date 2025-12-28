//
//  LoginViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/26/25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class LoginViewModel {
    // MARK: - 출력
    var isLoading: ((Bool) -> Void)?
    var loginResult: ((Bool, String?) -> Void)?
    
    // MARK: - API(Google Sign-In)
    /// - presentingVC: Google 로그인 화면을 표시할 뷰 컨트롤러
    func signInWithGoogle(presentingVC: UIViewController) {
        // 로딩 상태 시작
        isLoading?(true)
        
        // Firebase Client ID 확인
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.loginResult?(false, "Firebase 설정을 찾을 수 없습니다.")
            return
        }
        
        // Google Sign-In 설정
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Google 로그인 화면 표시 및 인증 처리
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            // Google 로그인 에러 처리
            if let error = error {
                self.isLoading?(false)
                self.loginResult?(false, error.localizedDescription)
                return
            }
            
            // Google 인증 토큰 확인
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                self.isLoading?(false)
                self.loginResult?(false, "구글 인증 토큰을 가져오지 못했습니다.")
                return
            }
            
            // Firebase 인증 자격 증명 생성
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            // Firebase에 로그인
            Auth.auth().signIn(with: credential) { authResult, error in
                self.isLoading?(false)
                if let error = error {
                    self.loginResult?(false, error.localizedDescription)
                } else {
                    self.loginResult?(true, nil)
                }
            }
        }
    }
}
