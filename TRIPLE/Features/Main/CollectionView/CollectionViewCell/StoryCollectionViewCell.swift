//
//  StoryCollectionViewCell.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit
import YouTubePlayerKit

class StoryCollectionViewCell: UICollectionViewCell {

    // MARK: - 상수
    static let reuseIdentifier = "StoryCollectionViewCell"

    // MARK: - 프로퍼티 (속성) 변수 & 상수
    
    /// 현재 설정된 비디오 ID (재사용 시 불필요한 재로딩 방지용)
    private var currentVideoID: String?

    /// YouTubePlayerHostingView를 담을 컨테이너 뷰
    private let playerContainerView = UIView()
    
    /// 플레이어가 생성된 후 할당되는 호스팅 뷰
    private var hostingView: YouTubePlayerHostingView?

    /// 플레이어 인스턴스에 대한 강한 참조 (설정 및 업데이트용)
    private var player: YouTubePlayer?

    // MARK: - 생명주기
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    /// 셀이 재사용되기 전에 상태 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        playerContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playerContainerView)
        NSLayoutConstraint.activate([
            playerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playerContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // 둥근 모서리 최적화
        playerContainerView.clipsToBounds = true
    }

    // MARK: - YoutubePlayerKit 설정
    
    /// 셀에 유튜브 비디오를 표시하도록 설정합니다.
    func configure(
        videoID: String,
        autoplay: Bool = false,
        loop: Bool = false,
        startTimeSeconds: Double? = nil,
        showControls: Bool = false,
        allowsInlineMediaPlayback: Bool = true,
        customUserAgent: String? = nil
    ) {
        // 동일한 비디오가 이미 설정되어 있고 호스팅 뷰가 존재한다면 재설정 생략 (리로드 방지)
        if currentVideoID == videoID, hostingView != nil {
            return
        }
        currentVideoID = videoID

        // 플레이어 파라미터 구성
        let parameters = YouTubePlayer.Parameters(
            autoPlay: autoplay,
            loopEnabled: loop,
            startTime: startTimeSeconds.map { .init(value: $0, unit: .seconds) },
            showControls: showControls
        )
        
        // 웹 뷰 설정 구성
        let configuration = YouTubePlayer.Configuration(
            allowsInlineMediaPlayback: allowsInlineMediaPlayback,
            customUserAgent: customUserAgent
        )
        
        // 소스, 파라미터, 설정을 사용하여 플레이어 생성
        let player = YouTubePlayer(
            source: .video(id: videoID),
            parameters: parameters,
            configuration: configuration
        )
        
        // 참조 할당 및 유지
        self.player = player

        // 이전 호스팅 뷰가 있다면 제거
        hostingView?.removeFromSuperview()

        // 새로운 플레이어로 호스팅 뷰 생성 및 부착
        let hostingView = YouTubePlayerHostingView(player: player)
        self.hostingView = hostingView
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        playerContainerView.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor)
        ])
    }

    /// 재생을 초기화하지 않고 기존 YouTubePlayer를 연결합니다.
    /// 셀이 재사용되거나 다시 나타날 때 연속적인 재생을 유지하기 위해 사용
    func configureWithExisting(player: YouTubePlayer) {
        // 제공된 플레이어 참조 유지
        self.player = player
        
        // 이전 호스팅 뷰의 플레이어가 현재와 다르다면 새로 생성하여 교체
        if hostingView?.player !== player {
            hostingView?.removeFromSuperview()
            
            let hostingView = YouTubePlayerHostingView(player: player)
            self.hostingView = hostingView
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            playerContainerView.addSubview(hostingView)
            
            NSLayoutConstraint.activate([
                hostingView.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
                hostingView.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
                hostingView.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor)
            ])
        }
    }
}
