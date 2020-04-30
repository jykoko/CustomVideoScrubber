//
//  PlayerViewController.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/24/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import AVFoundation
import UIKit

class PlayerViewController: UIViewController {
    
    lazy private var playerView: PlayerView = {
        let playerView = PlayerView(frame: .zero)
        playerView.delegate = self
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()
    
    lazy private var playerScrubber: PlayerScrubberViewController = {
        let playerScrubber = PlayerScrubberViewController(thumbnailLoader: VideoThumbnailLoader())
        playerScrubber.delegate = self
        playerScrubber.view.isHidden = true
        playerScrubber.view.translatesAutoresizingMaskIntoConstraints = false
        return playerScrubber
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let playbackController: PlaybackController
    
    init(playbackController: PlaybackController) {
        self.playbackController = playbackController
        super.init(nibName: nil, bundle: nil)
        self.playbackController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        playbackController.prepareForPlayback()
    }
}

// MARK: UI Configuration
extension PlayerViewController {
    
    private func setupViews() {
        configurePlayerView()
        configureScrubber()
    }
    
    private func configurePlayerView() {
        view.addSubview(playerView)
        
        let playerViewConstraints = [
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: PlayerView.LayoutAttributes.HeightMultiplier)
        ]
        
        NSLayoutConstraint.activate(playerViewConstraints)
    }
    
    private func configureScrubber() {
        playerScrubber.configure(with: playbackController.videoAsset)
        
        add(playerScrubber)
        let scrubberConstraints = [
            playerScrubber.view.heightAnchor.constraint(equalToConstant: PlayerScrubberViewController.LayoutAttributes.Height),
            playerScrubber.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerScrubber.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerScrubber.view.topAnchor.constraint(equalTo: playerView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(scrubberConstraints)
    }
}

// MARK: Player Control Actions
extension PlayerViewController: PlayerViewDelegate {
    
    func didPressPlayPause() {
        playbackController.togglePlayPause()
    }
}

// MARK: Playback Updates
extension PlayerViewController: PlaybackControllerDelegate {
    
    func playerDidBecomeReadyToPlay(_ player: AVPlayer) {
        playerView.configure(with: player)
        playerScrubber.view.isHidden = false
    }
    
    func playerDidChangeToStatus(_ status: PlaybackController.PlayerStatus) {
        let isPlaying = status == .playing
        playerView.updatePlayPauseButton(isPlaying: isPlaying)
    }
    
    func playerDidChangeToTime(_ time: CMTime) {
        playerScrubber.update(to: time)
    }
}

// MARK: Scrubber Updates
extension PlayerViewController: PlayerScrubberDelegate {
    
    func didScrubToTime(timeInSeconds: CMTime) {
        playbackController.seek(to: timeInSeconds)
    }
}
