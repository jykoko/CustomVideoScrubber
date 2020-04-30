//
//  PlayheadContainerView.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/26/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import UIKit

class PlayheadContainerView: UIView {
    
    enum LayoutAttributes {
        static let Width: CGFloat = 85.0
        static let PlayheadWidth: CGFloat = 5.0
        static let TimeLabelHeight: CGFloat = 20.0
    }
    
    lazy private var playheadView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 2.0
        return view
    }()
    
    lazy var currentTimeLabel: UILabel = {
        let currentTimeLabel = UILabel(frame: .zero)
        currentTimeLabel.text = "00:00"
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.backgroundColor = .clear
        currentTimeLabel.textColor = .white
        currentTimeLabel.textAlignment = .center
        return currentTimeLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UI Configuration
extension PlayheadContainerView {
    
    private func setupViews() {
        isUserInteractionEnabled = false
        configurePlayheadIndicator()
        configureCurrentTimeLabel()
    }
    
    private func configurePlayheadIndicator() {
        addSubview(playheadView)
        
        let scrubberHeadConstraints = [
            playheadView.centerXAnchor.constraint(equalTo: centerXAnchor),
            playheadView.centerYAnchor.constraint(equalTo: centerYAnchor),
            playheadView.heightAnchor.constraint(equalTo: heightAnchor, constant: -LayoutAttributes.TimeLabelHeight),
            playheadView.widthAnchor.constraint(equalToConstant: LayoutAttributes.PlayheadWidth)
        ]
        
        NSLayoutConstraint.activate(scrubberHeadConstraints)
    }
    
    private func configureCurrentTimeLabel() {
        addSubview(currentTimeLabel)
        
        let currentTimeLabelConstraints = [
            currentTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            currentTimeLabel.bottomAnchor.constraint(equalTo: playheadView.topAnchor),
            currentTimeLabel.heightAnchor.constraint(equalToConstant: LayoutAttributes.TimeLabelHeight),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: LayoutAttributes.Width)
        ]
        
        NSLayoutConstraint.activate(currentTimeLabelConstraints)
    }
}
