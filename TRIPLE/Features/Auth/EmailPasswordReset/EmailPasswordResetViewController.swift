//
//  EmailPasswordResetViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/26/25.
//

import UIKit

class EmailPasswordResetViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailSendButton: UIButton! 
    
    // MARK: - Properties
    private let viewModel = EmailPasswordResetViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - UI Setup
    private func setupUI() {
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Binding
    private func bindViewModel() {
        viewModel.isLoading = { [weak self] loading in
            DispatchQueue.main.async {
                self?.emailSendButton.isEnabled = !loading
                self?.emailSendButton.alpha = loading ? 0.5 : 1.0
            }
        }
        
        viewModel.resetResult = { [weak self] success, message in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if success {
                    self.showSuccessAlert(message: message ?? "")
                } else {
                    self.showAlert(message: message ?? "에러가 발생했습니다.")
                }
            }
        }
    }

    // MARK: - Actions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func emailSendButton(_ sender: Any) {
        viewModel.email = emailTextField.text ?? ""
        viewModel.sendResetEmail()
    }

    // MARK: - Helpers
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "전송 완료", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
