//
//  SideMenuViewModel.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation
import UIKit

final class SideMenuViewModel {
    private let service: ProfileService

    private(set) var profile: UserProfile {
        didSet {
            onProfileChanged?(profile)
            onProfileImageChanged?(imageFromData(profile.imageData))
        }
    }

    var onProfileChanged: ((UserProfile) -> Void)?
    var onProfileImageChanged: ((UIImage?) -> Void)?

    init(service: ProfileService = .shared) {
        self.service = service
        self.profile = service.loadProfile()
    }

    func reload() {
        profile = service.loadProfile()
    }

    private func imageFromData(_ data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
}
