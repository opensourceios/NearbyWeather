//
//  NavigationBarExtensions.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 18.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func styleStandard(withTransluscency isTransluscent: Bool, animated: Bool) {
        isTranslucent = isTransluscent
        
        barTintColor = .nearbyWeatherStandard
        tintColor = .white
        titleTextAttributes = [.foregroundColor: UIColor.white]
        barStyle = .black
    }
}
