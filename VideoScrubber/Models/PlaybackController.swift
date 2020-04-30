//
//  PlaybackController.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/24/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import AVFoundation
import Foundation

protocol PlaybackControllerDelegate: class {
    func playerDidChangeToTime(_ time: CMTime)
    func playerDidBecomeReadyToPlay(_ player: AVPlayer)
    func playerDidChangeToStatus(_ status: PlaybackController.PlayerStatus)
}

final class PlaybackController: NSObject {
    
    enum PlayerStatus {
        case idle
        case playing
        case paused
        case error
    }
    
    private enum Constants {
        static let TimerRate = 0.1
        static let VideoPath = "skateboard-quik-clip"
        static let VideoExtensionType = "MOV"
        static let LoadedTimeRangesKeyPath = "currentItem.loadedTimeRanges"
        static let RequiredAssetKeys = ["playable", "hasProtectedContent"]
    }
    
    private var status: PlayerStatus = .idle {
        didSet {
            delegate?.playerDidChangeToStatus(status)
        }
    }
    
    lazy private(set) var videoAsset: AVAsset? = {
        guard let url = Bundle.main.url(forResource: Constants.VideoPath, withExtension: Constants.VideoExtensionType) else {
            return nil
        }
        
        return AVAsset(url: url)
    }()
    
    private let player: AVPlayer
    
    weak var delegate: PlaybackControllerDelegate?
    
    init(with player: AVPlayer = AVPlayer()) {
        self.player = player
    }
}

// MARK: Playback Initialization
extension PlaybackController {
    
    func prepareForPlayback() {
        guard let videoAsset = videoAsset else {
            status = .error
            return
        }
        
        startAudioSession()
        addPlayerObservers()
        
        let playerItem = AVPlayerItem(asset: videoAsset, automaticallyLoadedAssetKeys: Constants.RequiredAssetKeys)
        player.replaceCurrentItem(with: playerItem)
    }
    
    private func addPlayerObservers() {
        player.addObserver(self, forKeyPath: Constants.LoadedTimeRangesKeyPath, options: .new, context: nil)
        
        let time = CMTime(seconds: Constants.TimerRate, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: time, queue: DispatchQueue.main) { [weak self] (time) in
            self?.delegate?.playerDidChangeToTime(time)
        }
    }
    
    private func startAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
}

// MARK: Playback Actions
extension PlaybackController {
    
    private var isPlaying: Bool {
        return player.rate != 0 && status == .playing
    }
    
    private var durationInSeconds: Double {
        return player.currentItem?.duration.seconds ?? 0
    }
    
    private func play() {
        player.play()
        status = .playing
    }
    
    private func pause() {
        player.pause()
        status = .paused
    }
    
    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func seek(to time: CMTime) {
        let timeInSeconds = CMTimeGetSeconds(time)
        guard timeInSeconds >= 0 && timeInSeconds <= durationInSeconds else { return }
        guard player.currentItem?.status == .readyToPlay else { return }
        
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            guard finished && self?.status != .paused else { return }
            self?.play()
        }
    }
}

// MARK: Player KVO
extension PlaybackController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Constants.LoadedTimeRangesKeyPath {
            delegate?.playerDidBecomeReadyToPlay(player)
        }
    }
}
