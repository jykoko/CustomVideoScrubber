//
//  ScrubberNormalizer.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/26/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import CoreMedia.CMTime

struct ScrubberNormalizer {
    // Creates a seek time based on the current horizontal offset of the player's scrubber
    // - Parameter xOffset: The horizontal offset that the user has scrolled to
    // - Parameter duration: The duration of the asset
    // - Parameter contentWidth: The width of the scrubber's content
    // - Returns: The seek time for the player to move to
    static func normalizedSeekTime(for xOffset: CGFloat, duration: Double, contentWidth: Double) -> CMTime {
        guard xOffset > 0 && duration > 0 && contentWidth > 0 else { return .zero }
        
        // Normalize the horizontal offset into a playback time
        let offsetAsTime = Int(duration) * xOffset.toInt / Int(contentWidth)
        let seekTime = CMTimeMakeWithSeconds(Float64(offsetAsTime), preferredTimescale: Int32(NSEC_PER_SEC))
        
        return seekTime
    }
    
    // Creates a scrubber position based on the playback time of the video
    // - Parameter time: The current time of the asset
    // - Parameter duration: The duration of the asset
    // - Parameter contentWidth: The width of the scrubber's content
    // - Parameter horizontalInsets: The scrubber's horizontal insets
    // - Returns: A horizontal offset scaled to the duration of the asset
    static func normalizedScrubberPosition(for time: CMTime, duration: Double, contentWidth: Double, horizontalInsets: Double) -> Double {
        guard time.seconds >= 0 && duration > 0 && contentWidth > 0 else { return 0 }
        
        // Using scale per second, generate the horizontal offset of a specific time
        let secondsScale = contentWidth / duration
        let currentOffset = (time.seconds * secondsScale) - horizontalInsets
        
        return currentOffset.rounded()
    }
}
