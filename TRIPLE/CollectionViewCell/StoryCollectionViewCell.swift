//
//  StoryCollectionViewCell.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/10/25.
//

import UIKit
import YouTubePlayerKit

class StoryCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "StoryCollectionViewCell"

    // Container view to host the YouTubePlayerHostingView
    private let playerContainerView = UIView()
    // Hosting view is created once a player exists
    private var hostingView: YouTubePlayerHostingView?

    // Keep a strong reference to the player so we can configure/update it
    private var player: YouTubePlayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        // Embed container view
        playerContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playerContainerView)
        NSLayoutConstraint.activate([
            playerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playerContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        // Optimize layer for rounded corners
        playerContainerView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Remove hosting view and clear player for reuse
        hostingView?.removeFromSuperview()
        hostingView = nil
        player = nil
    }

    /// Configure the cell to display a YouTube video
    /// - Parameters:
    ///   - videoID: The YouTube video identifier
    ///   - autoplay: Whether the player should start automatically
    ///   - loop: Whether the video should loop
    ///   - startTimeSeconds: Optional start time in seconds
    ///   - showControls: Whether to show YouTube controls
    ///   - allowsInlineMediaPlayback: Allows inline playback on iOS
    ///   - customUserAgent: Optional custom user agent
    func configure(
        videoID: String,
        autoplay: Bool = false,
        loop: Bool = false,
        startTimeSeconds: Double? = nil,
        showControls: Bool = true,
        allowsInlineMediaPlayback: Bool = true,
        customUserAgent: String? = nil
    ) {
        // Build player parameters
        let parameters = YouTubePlayer.Parameters(
            autoPlay: autoplay,
            loopEnabled: loop,
            startTime: startTimeSeconds.map { .init(value: $0, unit: .seconds) },
            showControls: showControls
        )
        // Build web view configuration
        let configuration = YouTubePlayer.Configuration(
            allowsInlineMediaPlayback: allowsInlineMediaPlayback,
            customUserAgent: customUserAgent
        )
        // Create the player with source, parameters and configuration
        let player = YouTubePlayer(
            source: .video(id: videoID),
            parameters: parameters,
            configuration: configuration
        )
        // Assign and keep a reference
        self.player = player

        // Remove previous hosting view if any
        hostingView?.removeFromSuperview()

        // Create and attach a new hosting view with the player
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
