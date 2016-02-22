//
//  Tools.swift
//  SwiftWeather
//
//  Created by 肖奕鹏 on 16/2/22.
//  Copyright © 2016年 xiaoyipeng. All rights reserved.
//

import UIKit

class Tools: NSObject {
    //是否ios8以上的系统
    static func iOS8Beyound() -> Bool {
            let systemvesion = UIDevice.currentDevice().systemVersion
            let index = systemvesion.startIndex.advancedBy(1)
            return Int(systemvesion.substringToIndex(index))>=8
    }
    
    static func fahrenheitByAbsoluteZero(zero:Int) {
        
    }
}
