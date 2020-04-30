//
//  VideoThumbnailCell.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/24/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import UIKit

class VideoThumbnailCell: UICollectionViewCell {
    
    enum Constants {
        static let ReuseIdentifier = "VideoThumbnailCell"
        static let Size = CGSize(width: 80, height: 80)
    }
    
    lazy private var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}

// MARK: UI Configuration
extension VideoThumbnailCell {
    
    private func setupViews() {
        contentView.addSubview(imageView)
        
        let imageConstraints = [
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor)
        ]
        
        NSLayoutConstraint.activate(imageConstraints)
    }
}
