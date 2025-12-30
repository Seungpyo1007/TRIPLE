//
//  ProfileEditViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/28/25.
//

import UIKit
import PhotosUI

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextField: UITextField!
    
    // MARK: - 상수 & 스와이프 변수
    private let viewModel = ProfileEditViewModel()
    var swipeRecognizer: UISwipeGestureRecognizer!
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRecognizer)
        
        // 누르면 프로필 이미지 변경
        profileImageView.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(imageTap)
        
        // 뷰 모델을 UI에 바인딩
        viewModel.onProfileChanged = { [weak self] profile in
            self?.profileTextField.text = profile.name
            if let data = profile.imageData { self?.profileImageView.image = UIImage(data: data) }
        }
        // 현재 프로필로 UI를 초기화합니다.
        profileTextField.text = viewModel.profile.name
        if let data = viewModel.profile.imageData { profileImageView.image = UIImage(data: data) }
        // 텍스트 변경 사항 듣기
        profileTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        viewModel.onProfileImageChanged = { [weak self] image in
            self?.profileImageView.image = image
        }
        if let imageView = profileImageView {
            imageView.layer.cornerRadius = imageView.bounds.width / 2
            imageView.clipsToBounds = true
            imageView.layer.borderColor = UIColor.systemGray4.cgColor
            imageView.layer.borderWidth = 1
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.setName(textField.text ?? "")
    }
    
    // MARK: - @IBAction
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        viewModel.save()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Action
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    @objc private func profileImageTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        viewModel.setImage(image)
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
