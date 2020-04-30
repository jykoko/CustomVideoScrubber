//
//  Result.swift
//  VideoScrubber
//
//  Created by Jacob Koko on 6/24/19.
//  Copyright © 2019 com.KokoTechnologies. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error?)
}
