//
//  UserProfile.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/9/25.
//

import Foundation

struct UserProfile: Codable {
    var uid: String
    var name: String
    var profileImage: String? // 반드시 String? (물음표 필수) 이어야 합니다.
}
