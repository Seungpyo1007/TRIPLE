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
    
    // Cache one YouTubePlayer per index to keep playback alive while offscreen
    private var playerCache: [Int: YouTubePlayer] = [:]

    private func playerForItem(at index: Int) -> YouTubePlayer? {
        guard let videoID = viewModel.videoIDForItem(at: index) else { return nil }
        if let cached = playerCache[index] {
            return cached
        }
        // Create a player once and cache it
        let parameters = YouTubePlayer.Parameters(
            autoPlay: true,
            loopEnabled: true,
            startTime: nil,
            showControls: false
        )
        let configuration = YouTubePlayer.Configuration(
            allowsInlineMediaPlayback: true,
            customUserAgent: nil
        )
        let player = YouTubePlayer(
            source: .video(id: videoID),
            parameters: parameters,
            configuration: configuration
        )
        playerCache[index] = player
        return player
    }
    
    init(viewModel: StoryCollectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - Public API
    func reload(with viewModel: StoryCollectionViewModel) {
        self.viewModel = viewModel
        playerCache.removeAll()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.reuseIdentifier, for: indexPath) as? StoryCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of StoryCollectionViewCell.")
        }
        let index = indexPath.item
        if let player = playerForItem(at: index) {
            cell.configureWithExisting(player: player)
        }
        
        // 유튜브 UI deprecated
        cell.isUserInteractionEnabled = false
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

