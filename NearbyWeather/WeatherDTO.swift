//
//  WeatherDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class WeatherDTO: NSObject {
    
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
    
    public static func determineWeatherConditionSymbol(fromWeathercode: Int) -> String {
        switch fromWeathercode {
        case let x where (x >= 200 && x <= 202) || (x >= 230 && x <= 232):
            return "⛈"
        case let x where x >= 210 && x <= 211:
            return "🌩"
        case let x where x >= 212 && x <= 221:
            return "⚡️"
        case let x where x >= 300 && x <= 321:
            return "🌦"
        case let x where x >= 500 && x <= 531:
            return "🌧"
        case let x where x >= 600 && x <= 622:
            return "🌨"
        case let x where x >= 701 && x <= 771:
            return "🌫"
        case let x where x == 781 || x >= 958:
            return "🌪"
        case let x where x == 800:
            //Simulate day/night mode for clear skies condition -> sunset @ 18:00, sunrise @ 07:00
            let currentDateFormatter: DateFormatter = DateFormatter()
            currentDateFormatter.dateFormat = "ddMMyyyy"
            let currentDateString: String = currentDateFormatter.string(from: Date())
            
            let zeroHourDateFormatter: DateFormatter = DateFormatter()
            zeroHourDateFormatter.dateFormat = "ddMMyyyyHHmmss"
            let zeroHourDate = zeroHourDateFormatter.date(from: (currentDateString + "000000"))!
            
            if Date().timeIntervalSince(zeroHourDate) > 64800 || Date().timeIntervalSince(zeroHourDate) < 25200 {
                return "✨"
            }
            return "☀️"
        case let x where x == 801:
            return "🌤"
        case let x where x == 802:
            return "⛅️"
        case let x where x == 803:
            return "🌥"
        case let x where x == 804:
            return "☁️"
        case let x where x >= 952 && x <= 958:
            return "💨"
        default:
            return "☀️"
        }
    }
    
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
}

extension WeatherDTO: NSCoding {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(condition, forKey: PropertyKey.conditionKey)
        aCoder.encode(cityName, forKey: PropertyKey.cityNameKey)
        aCoder.encode(rawTemperature, forKey: PropertyKey.rawTemperatureKey)
        aCoder.encode(cloudCoverage, forKey: PropertyKey.cloudCoverageKey)
        aCoder.encode(humidity, forKey: PropertyKey.humidityKey)
        aCoder.encode(windspeed, forKey: PropertyKey.windspeedKey)
    }
    
    struct PropertyKey {
        fileprivate static let conditionKey = "condition"
        fileprivate static let cityNameKey = "cityName"
        fileprivate static let rawTemperatureKey = "rawTemperature"
        fileprivate static let cloudCoverageKey = "cloudCoverage"
        fileprivate static let humidityKey = "humidity"
        fileprivate static let windspeedKey = "windspeed"
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("nearby_weather.weather_dto")
}
