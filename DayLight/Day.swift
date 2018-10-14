//
//  Day.swift
//  DayLight
//
//  Created by Kimberly Ha on 8/7/18.
//  Copyright © 2018 ktha-dev. All rights reserved.
//

import Foundation
import WXKDarkSky

class Day {
    var date: Date!
    var sunrise: Date!
    var sunset: Date!
    var dayLight: TimeInterval!
    var totalDayLight: TimeInterval!
    var uvIndex: Int!
    var uvIndexTime: Date!
    
    var df : DateFormatter {
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.locale = NSLocale.current
        df.amSymbol = "am"
        df.pmSymbol = "pm"
        df.dateFormat = "h:mm a"
        return df
    }

    required init( dataPoint: WXKDarkSkyDataPoint) {
        // initalize variables
        self.date = dataPoint.time
        self.sunrise = dataPoint.sunriseTime
        self.sunset = dataPoint.sunsetTime
        self.dayLight = self.sunset.timeIntervalSince(Date())
        self.totalDayLight = self.sunset.timeIntervalSince(self.sunrise)
        self.uvIndex = dataPoint.uvIndex
        self.uvIndexTime = dataPoint.uvIndexTime
    }
    
    func dateLabel() -> String {
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.locale = NSLocale.current
        df.dateFormat = "EEEE, MMMM d, yyyy"
        return df.string(from: self.date);
    }
    
    func sunriseLabel() -> String {
        return self.df.string(from: self.sunrise)
    }
    
    func sunsetLabel() -> String {
        return self.df.string(from: self.sunset)
    }
    
    func dayLightLabel() -> String {
        if (self.dayLight < 0) {
            return "No more daylight left!"
        } else {
            let hours = Int(self.dayLight/3600)
            let minutes = Int(self.dayLight/60) % 60
            return String(format: "%i hours %i minutes", hours, minutes)
        }
    }
    
    func totalDayLightLabel() -> String {
        let hours = Int(self.totalDayLight/3600)
        let minutes = Int(self.totalDayLight/60) % 60
        return String(format: "%i hours %i minutes", hours, minutes)
    }
    
    func uvIndexLabel() -> String {
        return String(format: "%i", self.uvIndex)
    }
    
    func uvIndexTimeLabel() -> String {
        return self.df.string(from: self.uvIndexTime)
    }
}
