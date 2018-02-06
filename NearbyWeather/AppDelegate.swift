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
        OWMCityService.instantiateSharedInstance()
        
        if UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey) != nil {
            WeatherDataManager.instantiateSharedInstance()
            LocationService.shared.requestWhenInUseAuthorization()
        } else {
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let destinationViewController = storyboard.instantiateInitialViewController()
            
            self.window?.rootViewController = destinationViewController
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        refreshWeatherDataIfNeeded()
    }
    
    
    // MARK: - Private Helpers
    
    private func refreshWeatherDataIfNeeded() {
        if UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey) != nil,
            UserDefaults.standard.bool(forKey: kRefreshOnAppStartKey) == true {
            WeatherDataManager.shared.update(withCompletionHandler: nil)
        }
    }
}
