//
//  CityRecCollectionViewCell.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit

class CityRecCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "CityRecCollectionViewCell"

    @IBOutlet weak var imageView: UIImageView!
    private var loadToken: UUID?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        loadToken = nil
        // TODO: Reset XIB outlets when added later
    }

    func configure(with placeholder: String) {
        // This configure method now only handles text or placeholder binding
    }
    
    func configureImage(viewModel: CityRecCollectionViewModel, indexPath: IndexPath, collectionView: UICollectionView) {
        let targetSize = CGSize(width: max(1, Int(bounds.width)), height: max(1, Int(bounds.height)))
        let token = UUID()
        self.loadToken = token
        self.imageView.image = nil
        viewModel.loadPhotoForItem(at: indexPath.item, targetSize: targetSize) { [weak self] image in
            DispatchQueue.main.async {
                guard let self = self, self.loadToken == token else { return }
                self.imageView.image = image
            }
        }
    }
}
