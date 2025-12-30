//
//  TicketCollectionViewCell.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import UIKit

class TicketCollectionViewCell: UICollectionViewCell {

    // MARK: - 속성
    static let reuseIdentifier = "TicketCollectionViewCell"

    // MARK: - 생명주기
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }

    /// 셀이 재사용되기 전에 상태 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        // TODO: Reset XIB outlets when added later
    }

    // MARK: - 구성
    func configure(with placeholder: String) {
        // TODO: Bind XIB outlets with real model when available
    }
}
