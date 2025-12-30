//
//  LoginEmailViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import UIKit

class LoginEmailViewController: UIViewController {

    // MARK: - @IBOutlets
    @IBOutlet weak var resetPasswordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - 속성
    private let viewModel = LoginEmailViewModel()

    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
        bindViewModel()
    }
    
    // MARK: - UI 설정
    private func setupUI() {
        passwordTextField.isSecureTextEntry = true
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
    }

    // MARK: - 바인딩
    private func bindViewModel() {
        viewModel.isLoading = { [weak self] loading in
            DispatchQueue.main.async {
                self?.loginButton.isEnabled = !loading
                self?.loginButton.alpha = loading ? 0.6 : 1.0
            }
        }
        
        viewModel.loginResult = { [weak self] success, message in
            DispatchQueue.main.async {
                if success {
                    self?.goToMainViewController()
                } else if let message = message {
                    self?.showAlert(message: message)
                }
            }
        }
    }

    // MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        viewModel.email = emailTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        viewModel.login()
    }
    
    // MARK: - 화면 전환
    @objc private func didTapResetPasswordLabel() {
        let vc = EmailPasswordResetViewController(nibName: "EmailPasswordResetViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func goToMainViewController() {
        let mainVC = MainViewController(nibName: "MainViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: mainVC)
        nav.isNavigationBarHidden = true
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nav
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: nil)
        }
    }
    
    // MARK: - 도우미 함수
    /// - 비밀번호 재설정 라벨 탭 제스처와 배경 탭 시 키보드 닫기 제스처를 추가
    private func setupGestureRecognizers() {
        resetPasswordLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapResetPasswordLabel))
        resetPasswordLabel.addGestureRecognizer(tap)
        
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(backgroundTap)
    }
    
    /// 키보드를 닫는 메서드
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// 에러 메시지를 표시하는 알림창
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
