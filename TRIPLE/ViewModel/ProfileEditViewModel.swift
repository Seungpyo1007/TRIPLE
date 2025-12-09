//
//  ProfileEditViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
import UIKit

final class ProfileEditViewModel {
    private let service: ProfileService

    private(set) var profile: UserProfile {
        didSet {
            onProfileChanged?(profile)
            onProfileImageChanged?(imageFromData(profile.imageData))
        }
    }

    // Callback to notify UI of changes
    var onProfileChanged: ((UserProfile) -> Void)?
    var onProfileImageChanged: ((UIImage?) -> Void)?

    init(service: ProfileService = .shared) {
        self.service = service
        self.profile = service.loadProfile()
    }

    private func imageFromData(_ data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }

    func setName(_ name: String) {
        profile.name = name
    }

    func setImage(_ image: UIImage?) {
        if let image = image, let data = image.jpegData(compressionQuality: 0.9) {
            profile.imageData = data
        } else {
            profile.imageData = nil
        }
    }

    func save() {
        service.saveProfile(profile)
    }
}

