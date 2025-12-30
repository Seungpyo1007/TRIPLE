//
//  EventCollectionViewCell.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "EventCollectionViewCell"

    // MARK: - 생명주기
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // TODO: Reset XIB outlets when added later
    }

    // MARK: - 구성
    func configure(with placeholder: String) {
        // TODO: Bind XIB outlets with real model when available
    }
}
