//
//  LoginEmailViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/23/25.
//

import UIKit

class LoginEmailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var resetPasswordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Properties
    private let viewModel = LoginEmailViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
        bindViewModel()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        passwordTextField.isSecureTextEntry = true
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
    }

    // MARK: - Binding
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

    // MARK: - Actions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        viewModel.email = emailTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        viewModel.login()
    }
    
    // MARK: - Navigation
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
    
    // MARK: - Helpers
    private func setupGestureRecognizers() {
        resetPasswordLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapResetPasswordLabel))
        resetPasswordLabel.addGestureRecognizer(tap)
        
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(backgroundTap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
