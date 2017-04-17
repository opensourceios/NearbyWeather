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
    public var temperature: String
    public var cloudCoverage: Double
    public var humidity: Double
    public var windspeed: Double
    
    
    // MARK: - Initialization
    
    public init(condition: String, cityName: String, rawTemperature: Double, temperature: String, cloudCoverage: Double, humidity: Double, windspeed: Double) {
        self.condition = condition
        self.cityName = cityName
        self.rawTemperature = rawTemperature
        self.temperature = temperature
        self.cloudCoverage = cloudCoverage
        self.humidity = humidity
        self.windspeed = windspeed
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let condition = aDecoder.decodeObject(forKey: PropertyKey.conditionKey) as! String
        let cityName = aDecoder.decodeObject(forKey: PropertyKey.cityNameKey) as! String
        let rawTemperature = aDecoder.decodeDouble(forKey: PropertyKey.rawTemperatureKey)
        let temperature = aDecoder.decodeObject(forKey: PropertyKey.temperatureKey) as! String
        let cloudCoverage = aDecoder.decodeDouble(forKey: PropertyKey.cloudCoverageKey)
        let humidity = aDecoder.decodeDouble(forKey: PropertyKey.humidityKey)
        let windspeed = aDecoder.decodeDouble(forKey: PropertyKey.windspeedKey)
        
        self.init(condition: condition, cityName: cityName, rawTemperature: rawTemperature, temperature: temperature, cloudCoverage: cloudCoverage, humidity: humidity, windspeed: windspeed)
    }
    
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(condition, forKey: PropertyKey.conditionKey)
        aCoder.encode(cityName, forKey: PropertyKey.cityNameKey)
        aCoder.encode(rawTemperature, forKey: PropertyKey.rawTemperatureKey)
        aCoder.encode(temperature, forKey: PropertyKey.temperatureKey)
        aCoder.encode(cloudCoverage, forKey: PropertyKey.cloudCoverageKey)
        aCoder.encode(humidity, forKey: PropertyKey.humidityKey)
        aCoder.encode(windspeed, forKey: PropertyKey.windspeedKey)
    }
    
    struct PropertyKey {
        static let conditionKey = "condition"
        static let cityNameKey = "cityName"
        static let rawTemperatureKey = "rawTemperature"
        static let temperatureKey = "temperature"
        static let cloudCoverageKey = "cloudCoverage"
        static let humidityKey = "humidity"
        static let windspeedKey = "windspeed"
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("nearby_weather.weather_dto")
}
