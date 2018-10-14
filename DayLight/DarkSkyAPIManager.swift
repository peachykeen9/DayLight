//
//  DarkSkyAPIManager.swift
//  DayLight
//
//  Created by Kimberly Ha on 8/4/18.
//  Copyright © 2018 ktha-dev. All rights reserved.
//

import Foundation
import WXKDarkSky

class DarkSkyAPIManager : NSObject {
    internal let apiKey = "ENTER_API_KEY_HERE"
    let request : WXKDarkSkyRequest
    
    private static var sharedDarkSkyAPIManager : DarkSkyAPIManager = {
        return DarkSkyAPIManager()
    }()
    
    override public init() {
        request = WXKDarkSkyRequest(key: apiKey)
    }
    
    class func shared() -> DarkSkyAPIManager {
        return sharedDarkSkyAPIManager
    }
}
