//
//  BenefitCollectionDelegate.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit

final class BenefitCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - 변수
    private var viewModel: BenefitCollectionViewModel

    // MARK: - 초기화
    init(viewModel: BenefitCollectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    // MARK: - 셀 재사용
    func reload(with viewModel: BenefitCollectionViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BenefitCollectionViewCell.reuseIdentifier, for: indexPath) as? BenefitCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of BenefitCollectionViewCell.")
        }
        let placeholder = viewModel.item(at: indexPath.item).title
        cell.configure(with: placeholder)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let verticalInset: CGFloat = 0
        let adjustedHeight = max(0, height - verticalInset * 2)
        let width = adjustedHeight * 0.9
        return CGSize(width: width, height: adjustedHeight)
    }
}
