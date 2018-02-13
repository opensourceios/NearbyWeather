//
//  OpenWeatherMapCityService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

class WeatherLocationService {
    
    // MARK: - Public Assets
    
    public static var shared: WeatherLocationService!
    
    public var openWeatherMapCities: [WeatherLocationDTO]
    
    
    // MARK: - Private Assets
    
    private let openWeatherMapCityServiceBackgroundQueue = DispatchQueue(label: "de.erikmaximilianmartens.nearbyWeather.openWeatherMapCityService", qos: DispatchQoS.background, attributes: [DispatchQueue.Attributes.concurrent], autoreleaseFrequency: .inherit, target: nil)
    
    
    // MARK: - Initialization
    
    private init(openWeatherMapCities: [WeatherLocationDTO]) {
        self.openWeatherMapCities = openWeatherMapCities
    }
    
    private convenience init(fileName: String) {
        self.init(openWeatherMapCities: [WeatherLocationDTO]())
        
        var cities: [WeatherLocationDTO]?
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        openWeatherMapCityServiceBackgroundQueue.async {
            guard let path = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                dispatchGroup.leave()
                return
            }
            do {
                let cityJsonData = try Data(contentsOf: path, options: .mappedIfSafe)
                cities = try JSONDecoder().decode([WeatherLocationDTO].self, from: cityJsonData)
                dispatchGroup.leave()
            } catch let error {
                dispatchGroup.leave()
                print(error.localizedDescription)
                return
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            if let openWeatherMapCities = cities {
                self.openWeatherMapCities = openWeatherMapCities
            }
        })
    }
    
    // MARK: - Public Properties & Methods
    
    public static func instantiateSharedInstance() {
        shared = WeatherLocationService(fileName: "cityList_17-04-2017")
    }
}
