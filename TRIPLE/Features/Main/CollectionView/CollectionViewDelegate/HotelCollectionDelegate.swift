//
//  HotelCollectionDelegate.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/11/25.
//

import UIKit

final class HotelCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - 변수
    private var viewModel: HotelCollectionViewModel

    // MARK: - 초기화
    init(viewModel: HotelCollectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - 셀 재사용
    func reload(with viewModel: HotelCollectionViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotelCollectionViewCell.reuseIdentifier, for: indexPath) as? HotelCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of HotelCollectionViewCell.")
        }
        let hotel = viewModel.item(at: indexPath.item)
        cell.configure(with: hotel, viewModel: viewModel)
        cell.configureImage(viewModel: viewModel, indexPath: indexPath, collectionView: collectionView)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let width = height * 0.75
        return CGSize(width: width, height: height)
    }
}
