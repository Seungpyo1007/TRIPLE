//
//  HotelCollectionViewCell.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import UIKit

class HotelCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private var loadToken: UUID?
    static let reuseIdentifier = "HotelCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .secondarySystemBackground
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        loadToken = nil
    }

    func configure(with hotel: HotelItem, viewModel: HotelCollectionViewModel) {
        titleLabel.text = hotel.title
        infoLabel.text = viewModel.infoText(for: hotel)
        priceLabel.text = viewModel.priceText(for: hotel)
    }
    
    // 에러 해결을 위해 파라미터 3개로 맞춤
    func configureImage(viewModel: HotelCollectionViewModel, indexPath: IndexPath, collectionView: UICollectionView) {
        let token = UUID()
        self.loadToken = token
        
        // 로딩 중 기본 이미지
        self.imageView.image = nil
        self.imageView.backgroundColor = .systemGray5
        
        viewModel.loadPhotoForItem(at: indexPath.item, targetSize: CGSize(width: 300, height: 300)) { [weak self] image in
            DispatchQueue.main.async {
                // 토큰이 일치해야만 이미지 세팅 (셀 재사용 방지)
                guard let self = self, self.loadToken == token else { return }
                
                if let downloadedImage = image {
                    self.imageView.image = downloadedImage
                    self.imageView.backgroundColor = .clear
                } else {
                    self.imageView.image = UIImage(systemName: "building.2.fill")
                }
            }
        }
    }
}
