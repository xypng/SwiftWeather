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

class ViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate, RefreshViewDelegate, WeatherServiceDelegate {
    
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
    let locationManager = CLLocationManager()//
    var refreshView: RefreshView!
    var isGetWeather = false
    let weatherService = WeatherService()
    
    @IBAction func pageChanged(sender: UIPageControl) {
        let page = Int(sender.currentPage)
        let offset = CGPoint(x: Int(CGRectGetWidth(UIScreen.mainScreen().bounds))*page, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alphaScrollViewbackground()
        
        self.addRefreshView()
        
        self.addLocationManager()
        
        self.reloadWeather()
        
        self.weatherService.delegate = self
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        viewWidth.constant = CGRectGetWidth(UIScreen.mainScreen().bounds)*3
        viewHeight.constant = CGRectGetHeight(UIScreen.mainScreen().bounds)
        firstViewLeading.constant = -20.0
        secondViewLeading.constant = CGRectGetWidth(UIScreen.mainScreen().bounds)-20.0
        thirdViewLeading.constant = CGRectGetWidth(UIScreen.mainScreen().bounds)*2-20.0
    }
    
    //使背景变透明,这样才能看到最后面的图片,并且活动时图片不会动
    func alphaScrollViewbackground() {
        firstView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        secondView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        thirdView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        containerView.backgroundColor = UIColor().colorWithAlphaComponent(0)
        scrollView.backgroundColor = UIColor().colorWithAlphaComponent(0)
//        scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
//        containerView.frame = CGRectMake(0, 0, self.view.frame.width*3, self.view.frame.height)
//        firstView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
//        secondView.frame = CGRectMake(self.view.frame.width, 0, self.view.frame.width, self.view.frame.height)
//        thirdView.frame = CGRectMake(self.view.frame.width*2, 0, self.view.frame.width, self.view.frame.height)
//        scrollView.contentSize = CGSize(width: self.view.frame.width*3, height: self.view.frame.height)
//        scrollView.contentOffset = CGPoint(x: 0, y: 0)
//        print("view.frame: \(view.frame)")
//        print("scrollView.frame: \(scrollView.frame)")
//        print("containerView.frame: \(containerView.frame)")
//        print("firstView.frame: \(firstView.frame)")
//        print("secondView.frame: \(secondView.frame)")
//        print("thirdView.frame: \(thirdView.frame)")
//        print("scrollView.contentSize: \(scrollView.contentSize)")
//        print("scrollView.contentOffset: \(scrollView.contentOffset)")
//        print("scrollView.bounds.size: \(scrollView.bounds.size)")
    }
    
    func addRefreshView() {
        let refreshHeight:CGFloat = 60
        let refreshRect = CGRectMake(0, -refreshHeight, CGRectGetWidth(self.view.frame), refreshHeight)
        refreshView = RefreshView(frame: refreshRect, scrollView: scrollView)
        refreshView.delegate = self
        firstView.addSubview(refreshView)
    }
    
    func addLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if (Tools.iOS8Beyound()) {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func reloadWeather() {
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
            print("(\(location.coordinate.latitude),\(location.coordinate.longitude))")
            atitudeAndLongtitude.text = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            self.isGetWeather = true
            weatherService.updateWeatherInfo(location.coordinate.latitude,longtitude: location.coordinate.longitude)
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
            print("停住2秒")
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(2*NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                self.refreshView.endRefreshing()
            }
        }
    }
//MARK: - WeatherServiceDelegate
    func weatherServiceSuccess(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) {
        print(responseObject)
        self.isGetWeather = false
        let jsonManager = JsonManager()
        let weatherModel = jsonManager.weatherModelByJsonResult(responseObject as? NSDictionary!)

        if let tem = weatherModel.temp {
            labTemp.text = tem
        } else {
            self.errorJson()
            return
        }
        if let city = weatherModel.cityName {
            labelCityName.text = city
        } else {
            self.errorJson()
            return
        }
        
        if let isnight = weatherModel.isNight {
            weatherService.updateWeatherBackground(imgBackground, nightTime: isnight)
        } else {
            errorJson()
            return
        }
        
        if let isnight = weatherModel.isNight, weatherid = weatherModel.weatherId {
            weatherService.updateWeatherIcon(weatherid
            , nightTime: isnight, imgIcon: imgIcon)
        } else {
            self.errorJson()
            return
        }
        self.loading.hidden = true
        print("已经刷新天气")
        refreshView.labRefresh.text = "刷新成功"
        refreshView.activityIndicator.stopAnimating()
        keepRefresh()
    }
    
    func weatherServiceError(operation: AFHTTPRequestOperation!, error: NSError!) {
        print("获取天气信息失败Error:\(error.localizedDescription)")
        self.isGetWeather = false
        self.loading.text = "获取天气信息失败,请检查网络!"
        self.loading.hidden = false
        self.refreshView.labRefresh.text = "刷新失败"
        self.keepRefresh()
    }
    
    func errorJson() {
        loading.text = "解析天气数据失败!"
        loading.hidden = false
        self.refreshView.labRefresh.text = "刷新失败"
        self.refreshView.activityIndicator.stopAnimating()
        keepRefresh()
    }
}

