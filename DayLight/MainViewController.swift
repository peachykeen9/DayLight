//
//  MainViewController.swift
//  DayLight
//
//  Created by Kimberly Ha on 8/4/18.
//  Copyright © 2018 ktha-dev. All rights reserved.
//

import UIKit
import WXKDarkSky
import MapKit
import CoreLocation

class MainViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var dayLightLabel: UILabel!
    @IBOutlet weak var celestialBodyImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var welcomeView: UIView!
    
    let locationManager = CLLocationManager()
    var locationQuery : String = ""
    var day : Day!
    
    @IBOutlet weak var currentDateLabel: UILabel! {
        didSet {
            DispatchQueue.main.async {
                let today = Date()
                let df = DateFormatter()
                df.timeZone = TimeZone.current
                df.locale = NSLocale.current
                df.dateFormat = "EEEE, MMMM d, yyyy"
                self.currentDateLabel.text = df.string(from: today);
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.welcomeView.isHidden = false
        self.resetView()
        self.setInitialDate()
        
        self.searchBar.delegate = self
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func resetView() {
        self.searchBar.text = ""
        self.cityLabel.text = ""
        self.countryLabel.text = ""
        self.dayLightLabel.text = ""
        self.sunriseLabel.text = ""
        self.sunsetLabel.text = ""
        
        self.celestialBodyImage.image = nil
        self.view.backgroundColor = .white
    }
    
    func setInitialDate() {
        let today = Date()
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.locale = NSLocale.current
        df.dateFormat = "EEEE, MMMM d, yyyy"
        self.currentDateLabel.text = df.string(from: today);
        print(df.string(from: today))
    }
    
    // UISearchBarDelegate methods
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        
        locationQuery = searchText
        self.resetView()
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationQuery) { (placemarks, error) in
            guard
                let placemarks = placemarks?.first,
                let location = placemarks.location
            else {
                return
            }
            
            self.welcomeView.isHidden = true
        
            let long = location.coordinate.longitude
            let lat = location.coordinate.latitude
            let point = WXKDarkSkyRequest.Point(lat, long)
            self.requestWeatherData(point)
            
            guard
                let state = placemarks.administrativeArea,
                let country = placemarks.country
            else {
                    return
            }
            
            DispatchQueue.main.async {
                self.cityLabel.text = state
                self.countryLabel.text = country
            }
        }
        
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // Dark skies API calls
    func requestWeatherData( _ point: WXKDarkSkyRequest.Point ) {
        let request = DarkSkyAPIManager.shared().request
        
        request.loadData(point: point) { (data, error) in
            if let error = error {
                print("error %@", error)
            } else if let dataBlock = data?.daily {
                self.processDailyData(dataBlock)
            }
        }
    }
    
    func processDailyData ( _ dataBlock : WXKDarkSkyDataBlock ) {
        let dataPoints = dataBlock.data
        self.day = Day.init(dataPoint: dataPoints.first!)
        
        DispatchQueue.main.async {
            self.dayLightLabel.text = self.day.dayLightLabel()
            self.sunriseLabel.text = self.day.sunriseLabel()
            self.sunsetLabel.text = self.day.sunsetLabel()
            self.currentDateLabel.text = self.day.dateLabel()
            
            self.updateBackground()
            
            self.updateBackgroundColor(timeLeft: self.day.dayLight, totalTime: self.day.totalDayLight)
        }
    }
    
    func updateBackgroundColor( timeLeft : TimeInterval, totalTime : TimeInterval ) {
        DispatchQueue.main.async {
            let day = UIColor.init(153, 204, 255)
            let night = UIColor.init(0, 40, 77)
            
            let fraction = min( abs( 2 * CGFloat(timeLeft/totalTime) - 1 ), 1 )
//            let fraction : CGFloat = CGFloat(Double.init(self.searchBar.text!)!)
            
            self.view.backgroundColor = day.interpolateRGBColorTo(night, fraction:fraction)
        }
    }
    
    func updateBackground() {
        if (self.day.dayLight < 0) {
            self.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.27, alpha: 1.0)
            self.celestialBodyImage.image = UIImage(named: "Moon")
            
            self.sunriseLabel.textColor = UIColor.white
            self.sunsetLabel.textColor = UIColor.white
            self.dayLightLabel.textColor = UIColor.white
            self.currentDateLabel.textColor = UIColor.white
        } else {
            self.view.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 0.59, alpha: 1.0)
            self.celestialBodyImage.image = UIImage(named: "Sun")
            
            self.sunriseLabel.textColor = UIColor.black
            self.sunsetLabel.textColor = UIColor.black
            self.dayLightLabel.textColor = UIColor.black
            self.currentDateLabel.textColor = UIColor.black
        }
    }
}

extension MainViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            print(locations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
}

