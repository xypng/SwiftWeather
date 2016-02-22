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

class ViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate, RefreshViewDelegate {
    
    @IBOutlet weak var atitudeAndLongtitude: UILabel!
    @IBOutlet weak var labelCityName: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var labTemp: UILabel!
    @IBOutlet weak var loading: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
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
    
    var errorLocationTimes = 0//获取地理位置信息已经出错的交数
    let transition = CATransition()//图片渐变动画
    let locationManager = CLLocationManager()//
    var refreshView: RefreshView!
    var isGetWeather = false
    
    @IBAction func pageChanged(sender: UIPageControl) {
        let page = Int(sender.currentPage)
        let offset = CGPoint(x: Int(CGRectGetWidth(UIScreen.mainScreen().bounds))*page, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alphaScrollViewbackground()
        
        self.addAnimationImage()
        
        self.addRefreshView()
        
        self.addLocation()
        
        self.refreshWeather()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        viewWidth.constant = CGRectGetWidth(UIScreen.mainScreen().bounds)*3
        viewHeight.constant = CGRectGetHeight(UIScreen.mainScreen().bounds)
        firstViewLeading.constant = -20.0
        secondViewLeading.constant = CGRectGetWidth(UIScreen.mainScreen().bounds)-20.0
        thirdViewLeading.constant = CGRectGetWidth(UIScreen.mainScreen().bounds)*2-20.0
    }

    //是否ios8以上的系统
    func ios8() -> Bool {
        let systemvesion = UIDevice.currentDevice().systemVersion
        let index = systemvesion.startIndex.advancedBy(1)
        return Int(systemvesion.substringToIndex(index))>=8
    }
    
    //使背景变透明,这样才能看到最后面的图片,并且活动时图片不会动
    func alphaScrollViewbackground() {
        firstView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        secondView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        thirdView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        containerView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        scrollView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        containerView.frame = CGRectMake(0, 0, self.view.frame.width*3, self.view.frame.height)
        firstView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        secondView.frame = CGRectMake(self.view.frame.width, 0, self.view.frame.width, self.view.frame.height)
        thirdView.frame = CGRectMake(self.view.frame.width*2, 0, self.view.frame.width, self.view.frame.height)
        scrollView.contentSize = CGSize(width: self.view.frame.width*3, height: self.view.frame.height)
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        print("view.frame: \(view.frame)")
        print("scrollView.frame: \(scrollView.frame)")
        print("containerView.frame: \(containerView.frame)")
        print("firstView.frame: \(firstView.frame)")
        print("secondView.frame: \(secondView.frame)")
        print("thirdView.frame: \(thirdView.frame)")
        print("scrollView.contentSize: \(scrollView.contentSize)")
        print("scrollView.contentOffset: \(scrollView.contentOffset)")
        print("scrollView.bounds.size: \(scrollView.bounds.size)")
    }
    
    //添加图片渐变动画
    func addAnimationImage() {
        transition.type = "fade";
        transition.duration = 1.0;
        transition.timingFunction = CAMediaTimingFunction(name: "easeIn")
        transition.fillMode = "forwards"
    }
    
    func addRefreshView() {
        let refreshHeight:CGFloat = 60
        let refreshRect = CGRectMake(0, -refreshHeight, CGRectGetWidth(self.view.frame), refreshHeight)
        refreshView = RefreshView(frame: refreshRect, scrollView: scrollView)
        refreshView.delegate = self
        firstView.addSubview(refreshView)
    }
    
    //根据经纬度获取天气数据(json)
    func updateWeatherInfo(latitude:CLLocationDegrees, longtitude:CLLocationDegrees) {
        let manager = AFHTTPRequestOperationManager()
        let parameter = ["lat":latitude, "lon":longtitude, "appid":apikey]
        self.isGetWeather = true
        manager.GET(weatherServiceUrl, parameters: parameter, success: { (operation:AFHTTPRequestOperation!, responseObject:AnyObject!) -> Void in
            self.updateUISuccess(responseObject as! NSDictionary!)
            self.isGetWeather = false
            }) { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                print("获取天气信息失败Error:\(error.localizedDescription)")
                self.loading.text = "获取天气信息失败,请检查网络!"
                self.loading.hidden = false
                self.refreshView.labRefresh.text = "刷新失败"
                self.isGetWeather = false
                self.keepRefresh()
        }
    }
    
    //解析json数据并更新页面上的天气温度等
    func updateUISuccess(jsonResult: NSDictionary!) {
        if let tempResult = jsonResult["main"]?["temp"] as? Double {
            loading.hidden = true
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
            print("已经刷新天气")
            refreshView.labRefresh.text = "刷新成功"
            refreshView.activityIndicator.stopAnimating()
            keepRefresh()
        } else {
            loading.text = "解析天气数据失败!"
            loading.hidden = false
            self.refreshView.labRefresh.text = "刷新失败"
            keepRefresh()
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
    
    func addLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if (ios8()) {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func refreshWeather() {
        locationManager.startUpdatingLocation()
    }
    
// MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if isGetWeather {
            return
        }
        let location: CLLocation = locations[locations.count-1] as CLLocation
        if location.horizontalAccuracy>0 {
            print("lotitude")
            atitudeAndLongtitude.text = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            updateWeatherInfo(location.coordinate.latitude,longtitude: location.coordinate.longitude)
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        errorLocationTimes++
        //最多重试获取地理位置信息3次
        if errorLocationTimes<=3 {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
            //提示用户检查网络
            print("获取地理位置信息失败")
            loading.text = "获取地理位置信息失败,请检查设置!"
            loading.hidden = false
            self.refreshView.labRefresh.text = "刷新失败"
            keepRefresh()
        }
    }
//MARK: - UIScrollViewDelegate
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.refreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.refreshView.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        print(scrollView.contentSize)
        let page = scrollView.contentOffset.x/CGRectGetWidth(UIScreen.mainScreen().bounds)
        pageControl.currentPage = Int(round(page))
    }
//MARK: - RefreshViewDelegate
    func refreshViewDidRefresh(refreshView: RefreshView) {
        locationManager.startUpdatingLocation()
    }
    
    func keepRefresh() {
        if refreshView.isRefreshing {
            print("停住3秒")
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(2*NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                self.refreshView.endRefreshing()
                print(3333)
            }
        }
    }
}

