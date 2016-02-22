//
//  WeatherService.swift
//  SwiftWeather
//
//  Created by 肖奕鹏 on 16/2/22.
//  Copyright © 2016年 xiaoyipeng. All rights reserved.
//

import UIKit
import CoreLocation

let apikey = "81c95577f51e8ad0d9174e71edb43e2c"//天气服务的apikey
let weatherServiceLocationUrl = "http://api.openweathermap.org/data/2.5/weather"//根据经纬度查天气的接口
let weatherServiceCityUrl = "http://api.openweathermap.org/data/2.5/find?q=nan&type=like&sort=population&cnt=6&appid=44db6a862fba0b067b1930da0d769e98"//根据城市拼音摸糊查询天气的接口,cnt是返回的个数
let cityCount = 6//城市名查天气时返回匹配个数

protocol WeatherServiceDelegate {
    func weatherServiceSuccess(operation:AFHTTPRequestOperation!, responseObject:AnyObject!)
    func weatherServiceError(operation:AFHTTPRequestOperation!, error:NSError!)
}

class WeatherService: NSObject {
    var delegate:WeatherServiceDelegate?
    let transition = CATransition()//图片渐变动画
    
    override init() {
        super.init()
        self.addImageAnimation()
    }
    
    //根据经纬度获取天气数据(json)
    func updateWeatherInfo(latitude:CLLocationDegrees, longtitude:CLLocationDegrees) {
        let manager = AFHTTPRequestOperationManager()
        let parameter = ["lat":latitude, "lon":longtitude, "appid":apikey]
        manager.GET(weatherServiceCityUrl, parameters: parameter, success: { (operation:AFHTTPRequestOperation!, responseObject:AnyObject!) -> Void in
            if let adelegate=self.delegate {
                adelegate.weatherServiceSuccess(operation, responseObject: responseObject)
            }
            }) { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                if let adelegate=self.delegate {
                    adelegate.weatherServiceError(operation, error: error)
                }
        }
    }
    
    //根据代码和是否晚上更新天气图标
    func updateWeatherIcon(condition: Int, nightTime: Bool, imgIcon: UIImageView) {
        imgIcon.layer.addAnimation(transition, forKey: nil)
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
    
    func updateWeatherBackground(background: UIImageView, nightTime: Bool) {
        background.layer.addAnimation(transition, forKey: nil)
        if nightTime {
            background.image = UIImage(named: "background_night")
        } else {
            background.image = UIImage(named: "background")
        }
    }
    
    //添加图片渐变动画
    func addImageAnimation() {
        transition.type = "fade";
        transition.duration = 1.0;
        transition.timingFunction = CAMediaTimingFunction(name: "easeIn")
        transition.fillMode = "forwards"
    }
    
}
