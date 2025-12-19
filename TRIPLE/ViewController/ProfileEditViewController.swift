//
//  ProfileEditViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/28/25.
//

import UIKit
import PhotosUI

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let viewModel = ProfileEditViewModel()
    
    // MARK: - @IBOutlet
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextField: UITextField!
    
    // MARK: - @IBAction
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        viewModel.save()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - 스와이프 변수
    var swipeRecognizer: UISwipeGestureRecognizer!
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRecognizer)
        
        // Tap to change profile image
        profileImageView.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(imageTap)
        
        // Bind view model to UI
        viewModel.onProfileChanged = { [weak self] profile in
            self?.profileTextField.text = profile.name
            if let data = profile.imageData { self?.profileImageView.image = UIImage(data: data) }
        }
        // Initialize UI with current profile
        profileTextField.text = viewModel.profile.name
        if let data = viewModel.profile.imageData { profileImageView.image = UIImage(data: data) }
        // Listen to text changes
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
