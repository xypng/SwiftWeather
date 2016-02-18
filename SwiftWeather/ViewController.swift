//
//  ViewController.swift
//  SwiftWeather
//
//  Created by 肖奕鹏 on 16/2/18.
//  Copyright © 2016年 xiaoyipeng. All rights reserved.
//

import UIKit
import CoreLocation

let apikey = "81c95577f51e8ad0d9174e71edb43e2c"

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var atitudeAndLongtitude: UILabel!

    @IBOutlet weak var labelCityName: UILabel!
    
    @IBOutlet weak var imgIcon: UIImageView!
    
    @IBOutlet weak var labTemp: UILabel!
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if (ios8()) {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }

    func ios8() -> Bool {
        let systemvesion = UIDevice.currentDevice().systemVersion
        let index = systemvesion.startIndex.advancedBy(1)
        return Int(systemvesion.substringToIndex(index))>=8
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count-1] as CLLocation
        if location.horizontalAccuracy>0 {
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            atitudeAndLongtitude.text = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            updateWeatherInfo(location.coordinate.latitude,longtitude: location.coordinate.longitude)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func updateWeatherInfo(latitude:CLLocationDegrees, longtitude:CLLocationDegrees) {
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        print("\(NSUUID().UUIDString)")
        let parameter = ["lat":latitude, "lon":longtitude, "appid":apikey]
        manager.GET(url, parameters: parameter, success: { (operation:AFHTTPRequestOperation!, responseObject:AnyObject!) -> Void in
                print("JSON:\(responseObject.description)")
                self.updateUISuccess(responseObject as! NSDictionary!)
            }) { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                print("Error:\(error.localizedDescription)")
        }
    }
    
    func updateUISuccess(jsonResult: NSDictionary!) {
        if let tempResult = jsonResult["main"]?["temp"] as? Double {
            var temperature: Int
            if jsonResult["sys"]?["country"] as? String == "US" {
                temperature = Int(round(((tempResult - 273.15)*1.8) + 32))
            } else {
                temperature = Int(round(tempResult-273.15))
            }
            labTemp.text = "\(temperature)ºC"
            let city = jsonResult["name"] as? String
            labelCityName.text = city
            
            let condition = jsonResult["weather"]?[0]?["id"] as? Int
            let sunrise = jsonResult["sys"]?["sunrise"] as? Int
            let sunset = jsonResult["sys"]?["sunset"] as? Int
            
            var nightTime = false
            let now = NSDate().timeIntervalSince1970
            
            if Int(now)<sunrise||Int(now)>sunset {
                nightTime = true
            }
            
            self.updateWeatherIcon(condition, nightTime: nightTime)
        }
    }
    
    func updateWeatherIcon(condition: Int?, nightTime: Bool) {
        // Thunderstorm
        if (condition < 300) {
            if nightTime {
                imgIcon.image = UIImage(named: "tstorm1_night")
            } else {
                imgIcon.image = UIImage(named: "tstorm1")
            }
        }
            // Drizzle
        else if (condition < 500) {
            imgIcon.image = UIImage(named: "light_rain")
            
        }
            // Rain / Freezing rain / Shower rain
        else if (condition < 600) {
            imgIcon.image = UIImage(named: "shower3")
        }
            // Snow
        else if (condition < 700) {
            imgIcon.image = UIImage(named: "snow4")
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            if nightTime {
                imgIcon.image = UIImage(named: "fog_night")
            } else {
                imgIcon.image = UIImage(named: "fog")
            }
        }
            // Tornado / Squalls
        else if (condition < 800) {
            imgIcon.image = UIImage(named: "tstorm3")
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                imgIcon.image = UIImage(named: "sunny_night")
            }
            else {
                imgIcon.image = UIImage(named: "sunny")
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                imgIcon.image = UIImage(named: "cloudy2_night")
            }
            else{
                imgIcon.image = UIImage(named: "cloudy2")
            }
        }
            // overcast clouds
        else if (condition == 804) {
            imgIcon.image = UIImage(named: "overcast")
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            imgIcon.image = UIImage(named: "tstorm3")
        }
            // Cold
        else if (condition == 903) {
            imgIcon.image = UIImage(named: "snow5")
        }
            // Hot
        else if (condition == 904) {
            imgIcon.image = UIImage(named: "sunny")
        }
            // Weather condition is not available
        else {
            imgIcon.image = UIImage(named: "dunno")
        }
    }
}

