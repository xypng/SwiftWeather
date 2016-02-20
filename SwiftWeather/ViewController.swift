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
let weatherServiceUrl = "http://api.openweathermap.org/data/2.5/weather"

class ViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate {
    var errorLocationTimes = 0
    let transition = CATransition()
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var atitudeAndLongtitude: UILabel!

    @IBOutlet weak var labelCityName: UILabel!
    
    @IBOutlet weak var imgIcon: UIImageView!
    
    @IBOutlet weak var labTemp: UILabel!
    
    @IBOutlet weak var loading: UILabel!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgBackground: UIImageView!
    
    @IBOutlet weak var viewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var firstViewLeading: NSLayoutConstraint!
    
    @IBOutlet weak var secondViewLeading: NSLayoutConstraint!
    
    @IBOutlet weak var thirdViewLeading: NSLayoutConstraint!
    
    @IBOutlet weak var firstView: UIView!
    
    @IBOutlet weak var secondView: UIView!
    
    @IBOutlet weak var thirdView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pullRefreshLabel: UILabel!
    
    @IBOutlet weak var pullRefreshActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        secondView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        thirdView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        containerView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        scrollView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        
        transition.type = "fade";
        transition.duration = 1.0;
        transition.timingFunction = CAMediaTimingFunction(name: "easeIn")
        transition.fillMode = "forwards"
        
        loadIndicator.startAnimating()
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if (ios8()) {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }

    //是否ios8以上的系统
    func ios8() -> Bool {
        let systemvesion = UIDevice.currentDevice().systemVersion
        let index = systemvesion.startIndex.advancedBy(1)
        return Int(systemvesion.substringToIndex(index))>=8
    }
    
    //CLLocationManager delegate方法,获取地理位置信息成功时回调
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count-1] as CLLocation
        if location.horizontalAccuracy>0 {
            locationManager.stopUpdatingLocation()
            atitudeAndLongtitude.text = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            updateWeatherInfo(location.coordinate.latitude,longtitude: location.coordinate.longitude)
        }
    }
    
    //CLLocationManager delegate方法,获取地理位置信息出错时回调
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        errorLocationTimes++
        //最多重试获取地理位置信息3次
        if errorLocationTimes<=3 {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
            //提示用户检查网络
            loading.text = "获取地理位置信息失败,请检查设置!"
            loadIndicator.hidden = true
            loadIndicator.stopAnimating()
        }
    }
    
    //根据经纬度获取天气数据(json)
    func updateWeatherInfo(latitude:CLLocationDegrees, longtitude:CLLocationDegrees) {
        let manager = AFHTTPRequestOperationManager()
        let parameter = ["lat":latitude, "lon":longtitude, "appid":apikey]
        manager.GET(weatherServiceUrl, parameters: parameter, success: { (operation:AFHTTPRequestOperation!, responseObject:AnyObject!) -> Void in
                print("JSON:\(responseObject.description)")
                self.updateUISuccess(responseObject as! NSDictionary!)
            }) { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                print("Error:\(error.localizedDescription)")
                self.loadIndicator.hidden = true
                self.loadIndicator.stopAnimating()
                self.loading.text = "获取天气信息失败,请检查网络!"
        }
    }
    
    //解析json数据并更新页面上的天气温度等
    func updateUISuccess(jsonResult: NSDictionary!) {
        if let tempResult = jsonResult["main"]?["temp"] as? Double {
            loading.hidden = true
            loadIndicator.hidden = true
            loadIndicator.stopAnimating()
            var temperature: Int
            if jsonResult["sys"]?["country"] as? String == "US" {
                //美国用的是华氏度
                temperature = Int(round(((tempResult - 273.15)*1.8) + 32))
                labTemp.text = "\(temperature)ºF"
            } else {
                //除美国之外用的是摄氏度
                temperature = Int(round(tempResult-273.15))
                labTemp.text = "\(temperature)ºC"
            }
            let city = jsonResult["name"] as? String
            labelCityName.text = city
            
            let condition = jsonResult["weather"]?[0]?["id"] as? Int
            let sunrise = jsonResult["sys"]?["sunrise"] as? Int
            let sunset = jsonResult["sys"]?["sunset"] as? Int
            
            var nightTime = false
            let now = NSDate().timeIntervalSince1970
            
            self.imgBackground.layer.addAnimation(transition, forKey: nil)
            if Int(now)<sunrise||Int(now)>sunset {
                nightTime = true
                self.imgBackground.image = UIImage(named: "background_night")
            } else {
                nightTime = false
                self.imgBackground.image = UIImage(named: "background")
            }
            self.updateWeatherIcon(condition, nightTime: nightTime)
        } else {
            loading.text = "解析天气数据失败!"
            loadIndicator.hidden = true
            loadIndicator.stopAnimating()
        }
    }
    
    //根据代码和是否晚上更新天气图标
    func updateWeatherIcon(condition: Int?, nightTime: Bool) {
        self.imgIcon.layer.addAnimation(transition, forKey: nil)
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
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        viewWidth.constant = CGRectGetWidth(UIScreen.mainScreen().bounds)*3
        //为了让垂直方向上有弹性只好+1,目前还没找到更好的办法.
        viewHeight.constant = CGRectGetHeight(UIScreen.mainScreen().bounds)+1
        firstViewLeading.constant = -20.0
        secondViewLeading.constant = CGRectGetWidth(UIScreen.mainScreen().bounds)-20.0
        thirdViewLeading.constant = CGRectGetWidth(UIScreen.mainScreen().bounds)*2-20.0
    }
    
    //scrollview delegate
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < -50 ) {
            pullRefreshLabel.text = "下拉刷新"
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                scrollView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
                }, completion: { (finished) -> Void in
                    print("要慢了")
            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("滚了")
        if( scrollView.contentOffset.y < -50){
            pullRefreshLabel.text = "松开刷新"
        } else {
        }
    }
}

