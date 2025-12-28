//
//  LoginViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - 속성
    private let viewModel = LoginViewModel()

    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    // MARK: - 바인딩
    private func bindViewModel() {
        viewModel.isLoading = { [weak self] loading in
            DispatchQueue.main.async {
                self?.view.isUserInteractionEnabled = !loading
            }
        }
        
        viewModel.loginResult = { [weak self] success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    self?.goToMainViewController()
                } else if let message = errorMessage {
                    self?.showAlert(message: message)
                }
            }
        }
    }

    // MARK: - @IBActions
    @IBAction func googleButton(_ sender: Any) {
        viewModel.signInWithGoogle(presentingVC: self)
    }

    @IBAction func openLoginEmail(_ sender: Any) {
        let vc = LoginEmailViewController(nibName: "LoginEmailViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 화면 전환
    private func goToMainViewController() {
        let mainVC = MainViewController(nibName: "MainViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: mainVC)
        nav.isNavigationBarHidden = true
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nav
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    // MARK: - 도우미 함수
    /// 에러 메시지를 표시하는 알림창
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
