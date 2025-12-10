//
//  BenefitCollectionViewCell.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit

class BenefitCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "BenefitCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .tertiarySystemBackground
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
