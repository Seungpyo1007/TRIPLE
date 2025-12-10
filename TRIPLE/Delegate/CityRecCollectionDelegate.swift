//
//  CityRecCollectionDelegate.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit

final class CityRecCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    // MARK: - Public API
    func reload(with viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfStories
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityRecCollectionViewCell.reuseIdentifier, for: indexPath) as? CityRecCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of CityRecCollectionViewCell.")
        }
        // 임시: 스토리 타이틀을 플레이스홀더로 사용. 추후 City 전용 모델로 교체 예정
        let placeholder = viewModel.story(at: indexPath.item).title
        cell.configure(with: placeholder)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let verticalInset: CGFloat = 0
        let adjustedHeight = max(0, height - verticalInset * 2)
        return CGSize(width: adjustedHeight, height: adjustedHeight)
    }
}
