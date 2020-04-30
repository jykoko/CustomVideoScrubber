//
//  CMTime+FormattedString.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/24/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import CoreMedia.CMTime

extension CMTime {
    // Create a formatted string representing the current time in minutes and seconds
    // - Returns: A time string in minutes and seconds ie.) 00:00
    func formattedTimeString() -> String {
        let minutesInt = Int(seconds) / 60 % 60
        let secondsInt = Int(seconds) % 60
        return String(format:"%02d:%02d", minutesInt, secondsInt)
    }
}
