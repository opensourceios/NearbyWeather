//
//  Weather.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import MapKit
import Alamofire



struct SingleLocationWeatherData: Codable {
    var errorDataDTO: ErrorDataDTO?
    var weatherDataDTO: WeatherDataDTO?
}

struct MultiLocationWeatherData: Codable {
    var errorDataDTO: ErrorDataDTO?
    var weatherDataDTOs: [WeatherDataDTO]?
}

let kDefaultBookmarkedLocation = WeatherLocationDTO(identifier: 5341145, name: "Cupertino", country: "US", coordinates: Coordinates(latitude: 37.323002, longitude: -122.032181))

fileprivate let kWeatherDataManagerStoredContentsFileName = "WeatherDataManagerStoredContents"

struct WeatherDataManagerStoredContentsWrapper: Codable {
    var bookmarkedLocation: WeatherLocationDTO
    var singleLocationWeatherData: SingleLocationWeatherData?
    var multiLocationWeatherData: MultiLocationWeatherData?
}

class WeatherDataManager {
    
    // MARK: - Public Assets
    
    public static var shared: WeatherDataManager!
    
    public var hasDisplayableData: Bool {
        return singleLocationWeatherData?.errorDataDTO != nil
            || singleLocationWeatherData?.weatherDataDTO != nil
            || multiLocationWeatherData?.errorDataDTO != nil
            || multiLocationWeatherData?.weatherDataDTOs != nil
    }
    
    public var hasDisplayableWeatherData: Bool {
        return singleLocationWeatherData?.weatherDataDTO != nil
            || multiLocationWeatherData?.weatherDataDTOs != nil
    }
    
    public var apiKeyUnauthorized: Bool {
        return singleLocationWeatherData?.errorDataDTO?.httpStatusCode == 401
        || multiLocationWeatherData?.errorDataDTO?.httpStatusCode == 401
    }
    
    
    // MARK: - Properties
    
    public var bookmarkedLocation: WeatherLocationDTO {
        didSet {
            update(withCompletionHandler: nil)
            WeatherDataManager.storeService()
        }
    }
    
    public private(set) var singleLocationWeatherData: SingleLocationWeatherData?
    public private(set) var multiLocationWeatherData: MultiLocationWeatherData?
    
    private var locationAuthorizationObserver: NSObjectProtocol!
    
    
    // MARK: - Initialization
    
    private init(bookmarkedLocation: WeatherLocationDTO) {
        self.bookmarkedLocation = bookmarkedLocation
        
        locationAuthorizationObserver = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil, using: { [unowned self] notification in
            self.discardLocationBasedWeatherDataIfNeeded()
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(locationAuthorizationObserver)
    }
    
    
    // MARK: - Public Properties & Methods
    
    public static func instantiateSharedInstance() {
        shared = WeatherDataManager.loadService() ?? WeatherDataManager(bookmarkedLocation: kDefaultBookmarkedLocation)
    }
    
    public func update(withCompletionHandler completionHandler: (() -> ())?) {
        let fetchWeatherDataBackgroundQueue = DispatchQueue(label: "de.erikmaximilianmartens.nearbyWeather.fetchWeatherDataQueue", qos: .userInitiated, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
        
        guard NetworkReachabilityManager()!.isReachable else {
            completionHandler?()
            return
        }
        
       fetchWeatherDataBackgroundQueue.async {
            let dispatchGroup = DispatchGroup()
            
            var singleLocationWeatherData: SingleLocationWeatherData?
            var multiLocationWeatherData: MultiLocationWeatherData?
            
            dispatchGroup.enter()
            NetworkingService.shared.fetchSingleLocationWeatherData(completionHandler: { weatherData in
                singleLocationWeatherData = weatherData
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            NetworkingService.shared.fetchMultiLocationWeatherData(completionHandler: { weatherData in
                multiLocationWeatherData = weatherData
                dispatchGroup.leave()
            })
            dispatchGroup.wait()
            
            // do not publish refresh if not data was loaded
            if singleLocationWeatherData == nil && multiLocationWeatherData == nil {
                return
            }
            
            // only override previous record if there is any data
            if singleLocationWeatherData != nil {
                self.singleLocationWeatherData = singleLocationWeatherData
            }
            if multiLocationWeatherData != nil {
                self.multiLocationWeatherData = multiLocationWeatherData
            }
            
            WeatherDataManager.storeService()
            DispatchQueue.main.async {
                UserDefaults.standard.set(Date(), forKey: kWeatherDataLastRefreshDateKey)
                NotificationCenter.default.post(name: Notification.Name(rawValue: kWeatherServiceDidUpdate), object: self)
                completionHandler?()
            }
        }
    }
    
    public func weatherDTO(forIdentifier identifier: Int) -> WeatherDataDTO? {
        if let weatherDTO = singleLocationWeatherData?.weatherDataDTO,
            weatherDTO.cityID == identifier {
            return weatherDTO
        }
        if let multiLocationMatch = multiLocationWeatherData?.weatherDataDTOs?.first(where: { weatherDTO in
            return weatherDTO.cityID == identifier
        }) {
            return multiLocationMatch
        }
        return nil
    }
    
    
    // MARK: - Private Helper Methods
    
    /* Internal Storage Helpers*/
    
    private static func loadService() -> WeatherDataManager? {
        guard let weatherDataManagerStoredContents = DataStorageService.retrieveJson(fromFileWithName: kWeatherDataManagerStoredContentsFileName, andDecodeAsType: WeatherDataManagerStoredContentsWrapper.self, fromStorageLocation: .documents) else {
                return nil
        }
        
        let weatherService = WeatherDataManager(bookmarkedLocation: weatherDataManagerStoredContents.bookmarkedLocation)
        weatherService.singleLocationWeatherData = weatherDataManagerStoredContents.singleLocationWeatherData
        weatherService.multiLocationWeatherData = weatherDataManagerStoredContents.multiLocationWeatherData
        
        return weatherService
    }
    
    private static func storeService() {
        let weatherServiceBackgroundQueue = DispatchQueue(label: "de.erikmaximilianmartens.nearbyWeather.weatherDataManagerBackgroundQueue", qos: .utility, attributes: [DispatchQueue.Attributes.concurrent], autoreleaseFrequency: .inherit, target: nil)
        
        let dispatchSemaphore = DispatchSemaphore(value: 1)
        
        dispatchSemaphore.wait()
        weatherServiceBackgroundQueue.async {
            let weatherDataManagerStoredContents = WeatherDataManagerStoredContentsWrapper(bookmarkedLocation: WeatherDataManager.shared.bookmarkedLocation,
                                                                                           singleLocationWeatherData: WeatherDataManager.shared.singleLocationWeatherData,
                                                                                           multiLocationWeatherData: WeatherDataManager.shared.multiLocationWeatherData)
            DataStorageService.storeJson(forCodable: weatherDataManagerStoredContents, inFileWithName: kWeatherDataManagerStoredContentsFileName, toStorageLocation: .documents)
            dispatchSemaphore.signal()
        }
    }
    
    @objc private func discardLocationBasedWeatherDataIfNeeded() {
        if !LocationService.shared.locationPermissionsGranted {
            multiLocationWeatherData = nil
            WeatherDataManager.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kWeatherServiceDidUpdate), object: self)
        }
    }
}
