//
//  StoryCollectionDelegate.swift
//  TRIPLE
//
//  Created by Assistant on 12/10/25.
//

import UIKit

final class StoryCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.reuseIdentifier, for: indexPath) as?
            StoryCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of StoryCollectionViewCell.")
        }
        let model = viewModel.story(at: indexPath.item)
        cell.configure(with: model)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let verticalInset: CGFloat = 0
        let adjustedHeight = max(0, height - verticalInset * 2)
        let width = adjustedHeight * 0.70
        return CGSize(width: width, height: adjustedHeight)
    }
}
