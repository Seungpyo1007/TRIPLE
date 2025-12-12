//
//  StoryCollectionDelegate.swift
//  TRIPLE
//
//  Created by Assistant on 12/10/25.
//

import UIKit
import YouTubePlayerKit

final class StoryCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var viewModel: StoryCollectionViewModel
    
    init(viewModel: StoryCollectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - Public API
    func reload(with viewModel: StoryCollectionViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.reuseIdentifier, for: indexPath) as?
            StoryCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of StoryCollectionViewCell.")
        }
        // Ask the ViewModel for a ready-to-use videoID (MVVM)
        let videoID = viewModel.videoIDForItem(at: indexPath.item) ?? ""
        cell.configure(videoID: videoID, autoplay: false, loop: false, showControls: true)
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
