//
//  AppDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        LocationService.instantiateSharedInstance()
        
        if UserDefaults.standard.value(forKey: "nearby_weather.openWeatherMapApiKey") != nil {
            WeatherService.instantiateSharedInstance()
            LocationService.shared.requestWhenInUseAuthorization()
        } else {
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let destinationViewController = storyboard.instantiateInitialViewController()
            
            self.window?.rootViewController = destinationViewController
        }
        return true
    }
}
