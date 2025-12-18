//
//  HotelCollectionDelegate.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import UIKit

final class HotelCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var viewModel: HotelCollectionViewModel

    init(viewModel: HotelCollectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    func reload(with viewModel: HotelCollectionViewModel) {
        self.viewModel = viewModel
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotelCollectionViewCell.reuseIdentifier, for: indexPath) as? HotelCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of HotelCollectionViewCell.")
        }
        let hotel = viewModel.item(at: indexPath.item)
        cell.configure(with: hotel, viewModel: viewModel)
        // 이제 파라미터가 일치하므로 에러가 나지 않습니다.
        cell.configureImage(viewModel: viewModel, indexPath: indexPath, collectionView: collectionView)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let width = height * 0.75
        return CGSize(width: width, height: height)
    }
}
