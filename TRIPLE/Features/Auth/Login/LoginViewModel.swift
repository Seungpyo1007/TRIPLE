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
    // MARK: - Outputs (Bindings)
    var isLoading: ((Bool) -> Void)?
    var loginResult: ((Bool, String?) -> Void)?
    
    // MARK: - Public API (Google Sign-In)
    func signInWithGoogle(presentingVC: UIViewController) {
        isLoading?(true)
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.loginResult?(false, "Firebase 설정을 찾을 수 없습니다.")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading?(false)
                self.loginResult?(false, error.localizedDescription)
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                self.isLoading?(false)
                self.loginResult?(false, "구글 인증 토큰을 가져오지 못했습니다.")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
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
