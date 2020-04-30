//
//  PlayerView.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/24/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import AVFoundation
import UIKit

protocol PlayerViewDelegate: class {
    func didPressPlayPause()
}

class PlayerView: UIView {
    
    enum LayoutAttributes {
        static let HeightMultiplier: CGFloat = 0.8
        static let PlayPauseButtonSize: CGFloat = 64.0
    }
    
    private enum Assets {
        static let PauseButtonImage = UIImage(named: "pause-button")
        static let PlayButtonImage = UIImage(named: "play-button")
    }
    
    private var playerLayer: AVPlayerLayer? {
        return layer as? AVPlayerLayer
    }
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    lazy private var playPauseButton: UIButton = {
        let playPauseBtn = UIButton(frame: .zero)
        playPauseBtn.translatesAutoresizingMaskIntoConstraints = false
        playPauseBtn.setBackgroundImage(Assets.PlayButtonImage, for: .normal)
        playPauseBtn.addTarget(self, action: #selector(didPressPlayPause), for: .touchUpInside)
        return playPauseBtn
    }()
    
    weak var delegate: PlayerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: UI Configuration
extension PlayerView {
    
    private func setupViews() {
        addSubview(playPauseButton)
        let playPauseButtonConstraints = [
            playPauseButton.widthAnchor.constraint(equalToConstant: LayoutAttributes.PlayPauseButtonSize),
            playPauseButton.heightAnchor.constraint(equalToConstant: LayoutAttributes.PlayPauseButtonSize),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(playPauseButtonConstraints)
    }
    
    func configure(with player: AVPlayer) {
        guard playerLayer?.player == nil else { return }
        playerLayer?.player = player
    }
}

// MARK: PlayPause Actions
extension PlayerView {
    
    @objc private func didPressPlayPause() {
        delegate?.didPressPlayPause()
    }
    
    func updatePlayPauseButton(isPlaying: Bool) {
        let playPauseButtonImage = isPlaying ? Assets.PauseButtonImage : Assets.PlayButtonImage
        playPauseButton.setBackgroundImage(playPauseButtonImage, for: .normal)
    }
}
