//
//  JsonManager.swift
//  SwiftWeather
//
//  Created by 肖奕鹏 on 16/2/22.
//  Copyright © 2016年 xiaoyipeng. All rights reserved.
//

import UIKit

class JsonManager: NSObject {
    
    //解析json数据并返回weathermodel
    func weatherModelByJsonResult(jsonResult: NSDictionary!) -> WeatherModel {
        let weatherModel = WeatherModel()
        
        weatherModel.lotitude = jsonResult["coord"]?["lon"] as? Float
        weatherModel.latitude = jsonResult["coord"]?["lat"] as? Float
        weatherModel.weatherId = jsonResult["weather"]?[0]?["id"] as? Int
        weatherModel.weatherDescription = jsonResult["weather"]?[0]?["description"] as? String
        weatherModel.weatherIcon = jsonResult["weather"]?[0]?["icon"] as? String
        weatherModel.windSpeed = jsonResult["wind"]?["speed"] as? Float
        weatherModel.country = jsonResult["sys"]?["country"] as? String
        weatherModel.sunRise = jsonResult["sys"]?["sunrise"] as? Int
        weatherModel.sunSet = jsonResult["sys"]?["sunset"] as? Int
        weatherModel.cityName = jsonResult["name"] as? String
        
        
        //解析温度
        if let tempResult = jsonResult["main"]?["temp"] as? Double {
            if jsonResult["sys"]?["country"] as? String == "US" {
                //美国用的是华氏度
                weatherModel.temp = "\(Int(round(((tempResult - 273.15)*1.8) + 32)))ºF"
            } else {
                //除美国之外用的是摄氏度
                weatherModel.temp = "\(Int(round(tempResult-273.15)))ºC"
            }
        }
        //解析最高温度
        if let temp_maxResult = jsonResult["main"]?["temp_max"] as? Double {
            if jsonResult["sys"]?["country"] as? String == "US" {
                //美国用的是华氏度
                weatherModel.tempMax = "\(Int(round(((temp_maxResult - 273.15)*1.8) + 32)))ºF"
            } else {
                //除美国之外用的是摄氏度
                weatherModel.tempMax = "\(Int(round(temp_maxResult-273.15)))ºC"
            }
        }
        
        //解析最低温度
        if let temp_minResult = jsonResult["main"]?["temp_min"] as? Double {
            if jsonResult["sys"]?["country"] as? String == "US" {
                //美国用的是华氏度
                weatherModel.tempMin = "\(Int(round(((temp_minResult - 273.15)*1.8) + 32)))ºF"
            } else {
                //除美国之外用的是摄氏度
                weatherModel.tempMin = "\(Int(round(temp_minResult-273.15)))ºC"
            }
        }
    
        let now = NSDate().timeIntervalSince1970
        if Int(now)<weatherModel.sunRise||Int(now)>weatherModel.sunSet {
            weatherModel.isNight = true
        } else {
            weatherModel.isNight = false
        }
        
        return weatherModel
    }
}
