//
//  StoryCollectionViewCell.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "StoryCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .systemGray5
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }

    func configure(with model: Story) {
        // TODO: Bind XIB outlets with model when available
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // TODO: Reset XIB outlets if needed
    }
}
