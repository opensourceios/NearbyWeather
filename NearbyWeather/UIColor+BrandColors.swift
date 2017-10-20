//
//  UIColor+BrandColors.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 17.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension UIColor {
    
    open class var nearbyWeatherStandard: UIColor {
        get {
            return UIColor(red: 100/255, green: 190/255, blue: 250/255, alpha: 1.0)
        }
    }
    
    open class var nearbyWeatherBubble: UIColor {
        get {
            return UIColor(red: 85/255, green: 185/255, blue: 250/255, alpha: 1.0)
        }
    }
}
