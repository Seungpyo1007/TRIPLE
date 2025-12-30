//
//  StoryCollectionDelegate.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit
import YouTubePlayerKit

final class StoryCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - 변수
    private var viewModel: StoryCollectionViewModel
    
    // 화면에서 벗어나 있을 때도 재생이 계속되도록 인덱스당 하나의 YouTubePlayer를 캐시합니다.
    private var playerCache: [Int: YouTubePlayer] = [:]

    // MARK: - 캐싱 구간
    private func playerForItem(at index: Int) -> YouTubePlayer? {
        guard let videoID = viewModel.videoIDForItem(at: index) else { return nil }
        if let cached = playerCache[index] {
            return cached
        }
        // 플레이어를 한 번 생성하고 캐시해 두세요.
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
    
    // MARK: - 초기화
    init(viewModel: StoryCollectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - 셀 재사용
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
        
        // 유튜브 UI 비활성화
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

