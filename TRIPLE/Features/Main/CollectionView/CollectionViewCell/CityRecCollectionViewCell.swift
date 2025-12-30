//
//  CityRecCollectionViewCell.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit

class CityRecCollectionViewCell: UICollectionViewCell {

    // MARK: - 속성
    static let reuseIdentifier = "CityRecCollectionViewCell"

    /// 이미지 로딩 중 셀이 재사용되어도 올바른 이미지만 표시하기 위한 토큰
    private var loadToken: UUID?

    // MARK: - @IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!

    // MARK: - 생명주기
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 8
        
        // 이미지 비율 유지하며 채우기
        imageView.contentMode = .scaleAspectFill

        // 모서리 밖 이미지 잘라내기
        imageView.clipsToBounds = true
    }

    /// 셀이 재사용되기 전에 상태 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        cityLabel.text = nil
        loadToken = nil
    }

    // MARK: - 구성
    /// 플레이스홀더 텍스트로 셀 구성 (이미지 로딩 전 임시 표시용)
    func configure(with placeholder: String) {
        cityLabel.text = placeholder
        cityLabel.isHidden = false
    }
    
    /// City 모델로 셀 구성
    func configure(with city: City) {
        cityLabel.text = city.name
        cityLabel.isHidden = false
        // 접근성을 위해 placeID가 있으면 힌트로 추가
        if let pid = city.placeID, !pid.isEmpty {
            cityLabel.accessibilityHint = "placeID: \(pid)"
        } else {
            cityLabel.accessibilityHint = nil
        }
    }
    
    /// 비동기로 이미지를 로드하여 셀에 표시
    func configureImage(viewModel: CityRecCollectionViewModel, indexPath: IndexPath, collectionView: UICollectionView) {
        // 셀의 크기에 맞는 이미지 크기 계산 (최소 1x1 보장)
        let targetSize = CGSize(width: max(1, Int(bounds.width)), height: max(1, Int(bounds.height)))
        // 이번 로딩 요청을 식별하기 위한 고유 토큰 생성
        let token = UUID()
        self.loadToken = token
        // 이전 이미지 제거
        self.imageView.image = nil
        
        // 비동기 이미지 로딩
        viewModel.loadPhotoForItem(at: indexPath.item, targetSize: targetSize) { [weak self] image in
            DispatchQueue.main.async {
                // 셀이 재사용되지 않았고, 이번 요청의 토큰과 일치하는지 확인
                guard let self = self, self.loadToken == token else { return }
                self.imageView.image = image
            }
        }
    }
}
