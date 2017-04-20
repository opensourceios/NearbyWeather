//
//  Weather.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

public enum SortingOrientation: Int {
    case byName
    case byTemperature
}

public class TemperatureUnit {
    
    static let count = 3
    
    var value: TemperatureUnitValue
    
    init(value: TemperatureUnitValue) {
        self.value = value
    }
    
    convenience init(rawValue: Int) {
        self.init(value: TemperatureUnitValue(rawValue: rawValue)!)
    }
    
    enum TemperatureUnitValue: Int {
        case celsius
        case fahrenheit
        case kelvin
    }
    
    var stringValue: String {
        switch value {
        case .celsius: return "Celsius"
        case .fahrenheit: return "Fahrenheit"
        case .kelvin: return "Kelvin"
        }
    }
}

public class AmountResults {
    
    static let count = 5
    
    var value: AmountResultsValue
    
    init(value: AmountResultsValue) {
        self.value = value
    }
    
    convenience init(rawValue: Int) {
        self.init(value: AmountResultsValue(rawValue: rawValue)!)
    }
    
    enum AmountResultsValue: Int {
        case ten
        case twenty
        case thirty
        case forty
        case fifty
    }
    
    var integerValue: Int {
        switch value {
        case .ten: return 10
        case .twenty: return 20
        case .thirty: return 30
        case .forty: return 40
        case .fifty: return 50
        }
    }
}

class WeatherService: NSObject, NSCoding {
    
    // MARK: - Public Assets
    
    public static var current: WeatherService!
    
    
    // MARK: - Private Assets
    
    private static let openWeather_SingleLocationBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private static let openWeather_MultiLocationBaseURL = "http://api.openweathermap.org/data/2.5/find"
    
    
    // MARK: - Properties
    
    public var temperatureUnit: TemperatureUnit {
        didSet {
            WeatherService.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated.rawValue), object: self)
        }
    }
    public var favoritedLocation: String {
        didSet {
            WeatherService.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated_dataPullRequired.rawValue), object: self)
        }
    }
    public var amountResults: Int {
        didSet {
            WeatherService.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated_dataPullRequired.rawValue), object: self)
        }
    }
    
    public var singleLocationWeatherData: [WeatherDTO]
    public var multiLocationWeatherData: [WeatherDTO]

    
    // MARK: - Initialization
    
    private init(favoritedLocation: String, amountResults: Int) {
        self.temperatureUnit = TemperatureUnit(value: .fahrenheit)
        self.favoritedLocation = favoritedLocation
        self.amountResults = amountResults
        
        self.singleLocationWeatherData = [WeatherDTO]()
        self.multiLocationWeatherData = [WeatherDTO]()
        
        super.init()
    }
    
    internal required convenience init?(coder aDecoder: NSCoder) {
        let tempUnit = aDecoder.decodeInteger(forKey: PropertyKey.temperatureUnitKey)
        let favorite = aDecoder.decodeObject(forKey: PropertyKey.favoritedLocationKey) as! String
        let amount = aDecoder.decodeInteger(forKey: PropertyKey.amountResultsKey)
        let singleLocationWeatherData = aDecoder.decodeObject(forKey: PropertyKey.singleLocationWeatherKey) as! [WeatherDTO]
        let multiLocationWeatherData = aDecoder.decodeObject(forKey: PropertyKey.multiLocationWeatherKey) as! [WeatherDTO]
        
        self.init(favoritedLocation: favorite, amountResults: amount)
        self.temperatureUnit = TemperatureUnit(rawValue: tempUnit)
        self.amountResults = amount
        self.singleLocationWeatherData = singleLocationWeatherData
        self.multiLocationWeatherData = multiLocationWeatherData
    }
    
    
    // MARK: - Public Properties & Methods
    
    public static func attachPersistentObject() {
        if let previousService: WeatherService = WeatherService.loadService() {
            WeatherService.current = previousService
        } else {
            WeatherService.current = WeatherService(favoritedLocation: "Cupertino", amountResults: 10)
        }
    }
    
    public func fetchDataWith(completionHandler: (() -> Void)?) {
        let dataQueue = DispatchQueue(label: "nearby_weather.weather_data_fetch")
        dataQueue.async {
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            self.fetchSingleLocationWeatherData(completionHandler: { data in
                self.singleLocationWeatherData = data
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            self.fetchMultiLocationWeatherData(completionHandler: { data in
                self.multiLocationWeatherData = data
                dispatchGroup.leave()
            })
            
            dispatchGroup.wait()
            DispatchQueue.main.async(execute: {
                WeatherService.storeService()
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated.rawValue), object: self)
                completionHandler?()
            })
        }
    }
    
    public func sortDataBy(orientation: SortingOrientation) {
        switch orientation {
        case .byName: multiLocationWeatherData.sort() { $0.cityName < $1.cityName }
        case .byTemperature: multiLocationWeatherData.sort() { $0.rawTemperature > $1.rawTemperature }
        }
        
    }
    
    
    // MARK: - Private Helper Methods
    
    /* Internal Storage Helpers*/
    
    private static func loadService() -> WeatherService? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: WeatherService.ArchiveURL.path) as? WeatherService
    }
    
    private static func storeService() {
        _ = NSKeyedArchiver.archiveRootObject(WeatherService.current, toFile: WeatherService.ArchiveURL.path)
    }
    
    /* Data Retrieval via Network */
    
    private func fetchSingleLocationWeatherData(completionHandler: @escaping ([WeatherDTO]) -> Void) {
        guard let apiKey = UserDefaults.standard.value(forKey: "nearby_weather.openWeatherMapApiKey") else {
            return completionHandler([WeatherDTO]())
        }
        
        let session = URLSession.shared
        
        let requestedCity: String = self.favoritedLocation.replacingOccurrences(of: " ", with: "")
        let requestURL = NSMutableURLRequest(url: URL(string: "\(WeatherService.openWeather_SingleLocationBaseURL)?APPID=\(apiKey)&q=\(requestedCity)")!)
        
        let request = session.dataTask(with: requestURL as URLRequest, completionHandler: { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response  , error == nil else {
                return
            }
            completionHandler(self.extractSingleLocation(weatherData: data!))
        })
        request.resume()
    }
    
    private func fetchMultiLocationWeatherData(completionHandler: @escaping ([WeatherDTO]) -> Void) {
        guard let apiKey = UserDefaults.standard.value(forKey: "nearby_weather.openWeatherMapApiKey") else {
            return completionHandler([WeatherDTO]())
        }
        
        let session = URLSession.shared
        
        let requestURL = NSMutableURLRequest(url: URL(string: "\(WeatherService.openWeather_MultiLocationBaseURL)?APPID=\(apiKey)&lat=\(LocationService.current.currentLatitude)&lon=\(LocationService.current.currentLongitude)&cnt=\(amountResults)")!)
        
        let request = session.dataTask(with: requestURL as URLRequest, completionHandler: { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response  , error == nil else {
                return
            }
            completionHandler(self.extractMultiLocation(weatherData: data!))
        })
        request.resume()
        
    }
    
    private func extractSingleLocation(weatherData json: Data) -> [WeatherDTO] {
        do {
            let data = try JSONSerialization.jsonObject(with: json, options: .mutableContainers) as! [String: AnyObject]
            
            guard 200 == data["cod"]! as! Int else {
                return [WeatherDTO]()
            }
            
            let condition = determineWeatherConditionSymbol(fromWeathercode: ((data["weather"] as! NSArray)[0] as! [String: AnyObject])["id"]! as! Int)
            let cityName = data["name"]! as! String
            let rawTemperature = data["main"]!["temp"]!! as! Double
            let cloudCoverage = data["clouds"]!["all"]!! as! Double
            let humidity = data["main"]!["humidity"]!! as! Double
            let windspeed = data["wind"]!["speed"]!! as! Double
            
            return [WeatherDTO(condition: condition, cityName: cityName, rawTemperature: rawTemperature, cloudCoverage: cloudCoverage, humidity: humidity, windspeed: windspeed)]
        }
        catch let jsonError as NSError {
            print("JSON error description: \(jsonError.description)")
            return [WeatherDTO]()
        }
    }
    
    private func extractMultiLocation(weatherData json: Data) -> [WeatherDTO] {
        do {
            let rawData = try JSONSerialization.jsonObject(with: json, options: .mutableContainers) as! [String: AnyObject]
            let extractedData = rawData["list"]! as? [[String: AnyObject]]
            var multiLocationData = [WeatherDTO]()
            
            guard "200" == rawData["cod"]! as! String else {
                return [WeatherDTO]()
            }
            
            for entry in extractedData! {
                let condition = determineWeatherConditionSymbol(fromWeathercode: ((entry["weather"] as! NSArray)[0] as! [String: AnyObject])["id"]! as! Int)
                let cityName = entry["name"]! as! String
                let rawTemperature = entry["main"]!["temp"]!! as! Double
                let cloudCoverage = entry["clouds"]!["all"]!! as! Double
                let humidity = entry["main"]!["humidity"]!! as! Double
                let windspeed = entry["wind"]!["speed"]!! as! Double
                
                let weatherDTO = WeatherDTO(condition: condition, cityName: cityName, rawTemperature: rawTemperature, cloudCoverage: cloudCoverage, humidity: humidity, windspeed: windspeed)
                multiLocationData.append(weatherDTO)
            }
            return multiLocationData
        }
        catch let jsonError as NSError {
            print("JSON error description: \(jsonError.description)")
            return [WeatherDTO]()
        }
    }
    
    /* Data Display Helpers */
    
    private func determineWeatherConditionSymbol(fromWeathercode: Int) -> String {
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
            else {
                return "☀️"
            }
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

    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(temperatureUnit.value.rawValue, forKey: PropertyKey.temperatureUnitKey)
        aCoder.encode(favoritedLocation, forKey: PropertyKey.favoritedLocationKey)
        aCoder.encode(amountResults, forKey: PropertyKey.amountResultsKey)
        aCoder.encode(singleLocationWeatherData, forKey: PropertyKey.singleLocationWeatherKey)
        aCoder.encode(multiLocationWeatherData, forKey: PropertyKey.multiLocationWeatherKey)
    }
    
    struct PropertyKey {
        static let temperatureUnitKey = "temperatureUnit"
        static let favoritedLocationKey = "favoritedLocation"
        static let amountResultsKey = "chosenAmountResults"
        static let singleLocationWeatherKey = "singleLocationWeatherData"
        static let multiLocationWeatherKey = "multiLocationWeatherData"
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("nearby_weather.weather_service")
}
