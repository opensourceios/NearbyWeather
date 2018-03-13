//
//  AppDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum QuickAction: String {
    case addLocation = "addLocation"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var launchedShortcutItem: UIApplicationShortcutItem?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var shouldPerformAdditionalDelegateHandling = true
        
        NetworkingService.instantiateSharedInstance()
        LocationService.instantiateSharedInstance()
        PreferencesManager.instantiateSharedInstance()
        WeatherLocationService.instantiateSharedInstance()
        
        if UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey) != nil {
            WeatherDataManager.instantiateSharedInstance()
            LocationService.shared.requestWhenInUseAuthorization()
        } else {
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let destinationViewController = storyboard.instantiateInitialViewController()
            
            self.window?.rootViewController = destinationViewController
        }
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem
            shouldPerformAdditionalDelegateHandling = false
            return shouldPerformAdditionalDelegateHandling
        }
        return shouldPerformAdditionalDelegateHandling
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        refreshWeatherDataIfNeeded()
        
        if let shortcutItem = launchedShortcutItem {
            handleQuickAction(shortcutItem: shortcutItem)
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let actionHandled = handleQuickAction(shortcutItem: shortcutItem)
        completionHandler(actionHandled)
    }
    
    
    // MARK: - Private Helpers
    
    private func refreshWeatherDataIfNeeded() {
        if UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey) != nil,
            UserDefaults.standard.bool(forKey: kRefreshOnAppStartKey) == true {
            WeatherDataManager.shared.update(withCompletionHandler: nil)
        }
    }
    
    @discardableResult
    private func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var shortcutItemHandled = false
        guard let type = shortcutItem.type.components(separatedBy: ".").last,
            let shortcutType = QuickAction(rawValue: type) else {
                return shortcutItemHandled
        }
        switch shortcutType {
        case .addLocation:
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let rootNavigationController = self.window?.rootViewController as? UINavigationController,
                let baseViewController = mainStoryboard.instantiateViewController(withIdentifier: "WeatherListViewController") as? WeatherListViewController else {
                    break
            }
            rootNavigationController.setViewControllers([baseViewController], animated: true)
            
            let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
            let destinationViewController = settingsStoryboard.instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController
            let settingsNavigationController = UINavigationController(rootViewController: destinationViewController)
            settingsNavigationController.addVerticalCloseButton(withCompletionHandler: nil)
            
            let addLocationViewController = settingsStoryboard.instantiateViewController(withIdentifier: "WeatherLocationSelectionTableViewController") as! WeatherLocationSelectionTableViewController
            
            rootNavigationController.present(settingsNavigationController, animated: true, completion: {
                settingsNavigationController.presentedViewController?.navigationController?.pushViewController(addLocationViewController, animated: true)
                shortcutItemHandled = true
                return
            })
        }
        return shortcutItemHandled
    }
}
