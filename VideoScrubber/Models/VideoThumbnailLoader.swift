//
//  VideoThumbnailLoader.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/24/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import AVFoundation
import UIKit

struct VideoThumbnailLoader {
    
    typealias ThumbnailLoaderCompletion = (Result<[UIImage]?>) -> Void
    
    private enum Constants {
        // By default we'll capture frames every 5 seconds as outlined in project requirements
        static let DefaultCaptureInterval = 5
    }
    
    // Generate a list of thumbnails from a video asset
    // - Parameter asset: A video asset
    // - Parameter captureInterval: The number of seconds to elapse between each video snapshot
    // - Parameter completion: A completion block that returns an array of video thumbnails
    func generateThumbnails(from asset: AVAsset, captureInterval: Int = Constants.DefaultCaptureInterval, completion: @escaping ThumbnailLoaderCompletion) {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.requestedTimeToleranceBefore = .zero
        
        let captureIntervals = generateImageRequestTimes(duration: asset.duration.seconds)
        
        // Map each thumbnail to a timestamp so we can sort them when the image generator completes
        var thumbnailCache = [Double: UIImage]()
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: captureIntervals) { (_, thumbnailImage, actualTime, result, error) in
            guard error == nil else {
                completion(.failure(error))
                return
            }
            
            guard result == .succeeded, let thumbnailImage = thumbnailImage else {
                completion(.failure(error))
                return
            }
            
            thumbnailCache[actualTime.seconds] = UIImage(cgImage: thumbnailImage)
        
            if thumbnailCache.count == captureIntervals.count {
                // Sort thumbnails by timestamp before returning for display
                let sortedThumbnails = thumbnailCache.sorted { $0.0 < $1.0 }.map { $0.value }
                completion(.success(sortedThumbnails))
            }
        }
    }

    // Generate the times at which an image should be requested by the ImageGenerator
    // - Parameter captureInterval: The number of seconds to elapse between each video snapshot
    // - Parameter duration: The duration of the asset in seconds
    // - Returns: The times at which an image should be requested
    private func generateImageRequestTimes(using captureInterval: Int = Constants.DefaultCaptureInterval, duration: Double) -> [NSValue] {
        let durationAsInt = Int(duration)
        guard captureInterval < durationAsInt else {
            return []
        }
        
        let captureIntervals = Array(0...durationAsInt).filter { $0 % captureInterval == 0 }

        let captureTimes = captureIntervals.compactMap {
            CMTimeMakeWithSeconds(Float64($0), preferredTimescale: Int32(NSEC_PER_SEC))
        }
        
        let captureTimeValues = captureTimes.compactMap { NSValue(time: $0) }
        
        return captureTimeValues
    }
}
