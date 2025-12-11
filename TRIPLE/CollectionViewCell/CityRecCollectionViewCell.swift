//
//  CityRecCollectionViewCell.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit

class CityRecCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "CityRecCollectionViewCell"

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

    func configure(with placeholder: String) {
        // TODO: Bind XIB outlets with real model when available
    }
}
