//
//  WeatherDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class WeatherDTO: NSObject, NSCoding {
    
    // MARK: - Properties
    
    public var condition: String
    public var cityName: String
    public var rawTemperature: Double
    public var cloudCoverage: Double
    public var humidity: Double
    public var windspeed: Double
    
    
    // MARK: - Initialization
    
    public init(condition: String, cityName: String, rawTemperature: Double, cloudCoverage: Double, humidity: Double, windspeed: Double) {
        self.condition = condition
        self.cityName = cityName
        self.rawTemperature = rawTemperature
        self.cloudCoverage = cloudCoverage
        self.humidity = humidity
        self.windspeed = windspeed
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let condition = aDecoder.decodeObject(forKey: PropertyKey.conditionKey) as! String
        let cityName = aDecoder.decodeObject(forKey: PropertyKey.cityNameKey) as! String
        let rawTemperature = aDecoder.decodeDouble(forKey: PropertyKey.rawTemperatureKey)
        let cloudCoverage = aDecoder.decodeDouble(forKey: PropertyKey.cloudCoverageKey)
        let humidity = aDecoder.decodeDouble(forKey: PropertyKey.humidityKey)
        let windspeed = aDecoder.decodeDouble(forKey: PropertyKey.windspeedKey)
        
        self.init(condition: condition, cityName: cityName, rawTemperature: rawTemperature, cloudCoverage: cloudCoverage, humidity: humidity, windspeed: windspeed)
    }
    
    
    // MARK: Public Methods
    
    public func determineTemperatureForUnit() -> String {
        switch WeatherService.current.temperatureUnit.value {
        case .celsius:
            return "\(String(format:"%.02f", rawTemperature - 273.15))°C"
        case . fahrenheit:
            return "\(String(format:"%.02f", rawTemperature * (9/5) - 459.67))°F"
        case .kelvin:
            return "\(String(format:"%.02f", rawTemperature))°K"
        }
    }
    
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(condition, forKey: PropertyKey.conditionKey)
        aCoder.encode(cityName, forKey: PropertyKey.cityNameKey)
        aCoder.encode(rawTemperature, forKey: PropertyKey.rawTemperatureKey)
        aCoder.encode(cloudCoverage, forKey: PropertyKey.cloudCoverageKey)
        aCoder.encode(humidity, forKey: PropertyKey.humidityKey)
        aCoder.encode(windspeed, forKey: PropertyKey.windspeedKey)
    }
    
    struct PropertyKey {
        static let conditionKey = "condition"
        static let cityNameKey = "cityName"
        static let rawTemperatureKey = "rawTemperature"
        static let cloudCoverageKey = "cloudCoverage"
        static let humidityKey = "humidity"
        static let windspeedKey = "windspeed"
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("nearby_weather.weather_dto")
}
