//
//  AppDelegate.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/24/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import UIKit
import AVFoundation.AVFAudio

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        showPlayerViewController()
        return true
    }
    
    private func showPlayerViewController() {
        let playerViewController = PlayerViewController(playbackController: PlaybackController())
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = playerViewController
        window?.makeKeyAndVisible()
    }
}
