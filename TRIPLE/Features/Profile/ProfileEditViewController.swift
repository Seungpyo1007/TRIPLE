//
//  ProfileEditViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/28/25.
//

import UIKit
import FirebaseAuth

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextField: UITextField!
    
    private var viewModel: ProfileEditViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        viewModel.fetchCurrentProfile()
    }
    
    private func setupUI() {
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .lightGray
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageTapped)))
        profileTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
    }

    private func setupViewModel() {
        guard let user = Auth.auth().currentUser else { return }
        
        let initialProfile = UserProfile(
            uid: user.uid,
            name: user.displayName ?? "",
            profileImage: user.photoURL?.absoluteString
        )
        
        viewModel = ProfileEditViewModel(profile: initialProfile)
        
        // 초기값 바인딩 (혹시 Auth 정보가 있다면 먼저 보여줌)
        updateUI(with: initialProfile)
        
        bindViewModel()
    }

    private func bindViewModel() {
        // 🔥 Firestore에서 최신 데이터가 로드되면 실행됨
        viewModel.onProfileLoaded = { [weak self] profile in
            DispatchQueue.main.async {
                self?.updateUI(with: profile)
            }
        }
        
        viewModel.onProfileImageChanged = { [weak self] image in
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }
        
        viewModel.onSaveResult = { [weak self] success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    let alert = UIAlertController(title: "오류", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
        
        viewModel.isLoading = { isLoading in
            // 로딩 인디케이터 처리 가능
        }
    }
    
    // 🔥 UI 업데이트 로직 분리 (재사용)
    private func updateUI(with profile: UserProfile) {
        profileTextField.text = profile.name
        
        if let urlString = profile.profileImage, let url = URL(string: urlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        } else {
            // 이미지가 없으면 기본 아이콘
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.setName(textField.text ?? "")
    }

    @IBAction func saveButton(_ sender: Any) {
        viewModel.save()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func profileImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        viewModel.setImage(image)
        dismiss(animated: true)
    }
}
