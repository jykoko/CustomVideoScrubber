//
//  PlayerScrubberViewController.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/24/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import AVFoundation
import UIKit

protocol PlayerScrubberDelegate: class {
    func didScrubToTime(timeInSeconds: CMTime)
}

class PlayerScrubberViewController: UIViewController {
    
    enum LayoutAttributes {
        static let Height: CGFloat = 130.0
    }
    
    lazy private var thumbnailCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = VideoThumbnailCell.Constants.Size
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(VideoThumbnailCell.self, forCellWithReuseIdentifier: VideoThumbnailCell.Constants.ReuseIdentifier)
        collection.contentInset = UIEdgeInsets(top: 0, left: view.frame.width/2, bottom: 0, right: view.frame.width/2)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        return collection
    }()
    
    lazy private var playheadContainerView: PlayheadContainerView = {
        let playheadContainer = PlayheadContainerView()
        playheadContainer.translatesAutoresizingMaskIntoConstraints = false
        return playheadContainer
    }()
    
    private var videoThumbnails: [UIImage]? {
        didSet {
            thumbnailCollectionView.reloadData()
        }
    }
    
    private var videoDuration: Double = 0
    
    private let thumbnailLoader: VideoThumbnailLoader
    
    weak var delegate: PlayerScrubberDelegate?
    
    init(thumbnailLoader: VideoThumbnailLoader) {
        self.thumbnailLoader = thumbnailLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

// MARK: UI Configuration
extension PlayerScrubberViewController {
    
    private func setupViews() {
        view.addSubview(thumbnailCollectionView)
        let collectionContraints = [
            thumbnailCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thumbnailCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thumbnailCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            thumbnailCollectionView.topAnchor.constraint(equalTo: view.topAnchor)
        ]
        
        view.addSubview(playheadContainerView)
        let playheadContainerContraints = [
            playheadContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playheadContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playheadContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            playheadContainerView.widthAnchor.constraint(equalToConstant: PlayheadContainerView.LayoutAttributes.Width),
        ]
        
        NSLayoutConstraint.activate(collectionContraints + playheadContainerContraints)
    }
}

// MARK: Public API
extension PlayerScrubberViewController {
    
    // Kickoff the scrubber initialization process
    func configure(with videoAsset: AVAsset?) {
        guard let videoAsset = videoAsset else { return }
        
        videoDuration = videoAsset.duration.seconds
        thumbnailLoader.generateThumbnails(from: videoAsset) { [weak self] result in
            switch result {
            case .success(let thumbnails):
                DispatchQueue.main.async { [weak self] in
                    self?.videoThumbnails = thumbnails
                }
            case .failure(let error):
                if let error = error {
                    // Typically I'd show an error message or error view
                    // For the purposes of this project, I'll just log the error
                    print(error)
                }
            }
        }
    }
    
    // Update scrubber label and scroll position when playback time changes
    func update(to time: CMTime) {
        playheadContainerView.currentTimeLabel.text = time.formattedTimeString()
        scrollToTime(time: time)
    }
}

// MARK: Thumbnail CollectionView
extension PlayerScrubberViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoThumbnails?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let thumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoThumbnailCell.Constants.ReuseIdentifier, for: indexPath) as! VideoThumbnailCell
        
        guard let thumbnailImage = videoThumbnails?[indexPath.row] else {
            return thumbnailCell
        }
        
        thumbnailCell.configure(with: thumbnailImage)
        
        return thumbnailCell
    }
}

// MARK: Scroll Events
extension PlayerScrubberViewController {
    
    private var contentWidth: Double {
        return thumbnailCollectionView.contentSize.width.toDouble
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x + scrollView.contentInset.left
        let seekTime = ScrubberNormalizer.normalizedSeekTime(for: xOffset, duration: videoDuration, contentWidth: contentWidth)
        delegate?.didScrubToTime(timeInSeconds: seekTime)
    }
    
    // Updates the position of the scroll view to reflect the current playback time
    private func scrollToTime(time: CMTime) {
        guard !thumbnailCollectionView.isDragging else { return }
        
        let horizontalInsets = thumbnailCollectionView.contentInset.left.toDouble
        let scrollToPosition = ScrubberNormalizer.normalizedScrubberPosition(for: time, duration: videoDuration, contentWidth: contentWidth, horizontalInsets: horizontalInsets)
        thumbnailCollectionView.bounds.origin = CGPoint(x: scrollToPosition, y: thumbnailCollectionView.contentOffset.y.toDouble)
    }
}
