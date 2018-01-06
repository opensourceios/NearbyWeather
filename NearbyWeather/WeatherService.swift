//
//  Weather.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import Foundation

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
    
    convenience init?(rawValue: Int) {
        guard let value = TemperatureUnitValue(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
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

public class SpeedUnit {
    static let count = 2
    
    var value: SpeedUnitValue
    
    init(value: SpeedUnitValue) {
        self.value = value
    }
    
    convenience init?(rawValue: Int) {
        guard let value = SpeedUnitValue(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    enum SpeedUnitValue: Int {
        case kilometresPerHour
        case milesPerHour
    }
    
    var stringValue: String {
        switch value {
        case .kilometresPerHour: return NSLocalizedString("kilometres_per_hour", comment: "")
        case .milesPerHour: return NSLocalizedString("miles_per_hour", comment: "")
        }
    }
    
    var stringShortValue: String {
        switch value {
        case .kilometresPerHour: return NSLocalizedString("kmh", comment: "")
        case .milesPerHour: return NSLocalizedString("mph", comment: "")
        }
    }
}

public class AmountResults {
    
    static let count = 5
    
    var value: AmountResultsValue
    
    init(value: AmountResultsValue) {
        self.value = value
    }
    
    convenience init?(rawValue: Int) {
        guard let value = AmountResultsValue(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
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

let kWeatherServiceDidUpdate = "de.erikmartens.nearbyWeather.weatherServiceDidUpdate"

class WeatherService: NSObject {
    
    // MARK: - Public Assets
    
    public static var shared: WeatherService!
    
    
    // MARK: - Private Assets
    
    private static let openWeather_SingleLocationBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private static let openWeather_MultiLocationBaseURL = "http://api.openweathermap.org/data/2.5/find"
    
    private let weatherServiceBackgroundQueue = DispatchQueue(label: "de.erikmartens.nearbyWeather.weatherService", qos: DispatchQoS.background, attributes: [DispatchQueue.Attributes.concurrent], autoreleaseFrequency: .inherit, target: nil)
    
    
    // MARK: - Properties
    
    public var temperatureUnit: TemperatureUnit {
        didSet {
            weatherServiceBackgroundQueue.async {
                WeatherService.storeService()
            }
        }
    }
    public var windspeedUnit: SpeedUnit {
        didSet {
            weatherServiceBackgroundQueue.async {
                WeatherService.storeService()
            }
        }
    }
    public var favoritedLocation: String {
        didSet {
            update(withCompletionHandler: nil)
        }
    }
    public var amountResults: Int {
        didSet {
            update(withCompletionHandler: nil)
        }
    }
    
    public var singleLocationWeatherData: [WeatherDTO]?
    public var multiLocationWeatherData: [WeatherDTO]?
    
    
    // MARK: - Initialization
    
    private init(favoritedLocation: String, amountResults: Int) {
        self.temperatureUnit = TemperatureUnit(value: .celsius)
        self.windspeedUnit = SpeedUnit(value: .kilometresPerHour)
        self.favoritedLocation = favoritedLocation
        self.amountResults = amountResults
        
        super.init()
    }
    
    internal required convenience init?(coder aDecoder: NSCoder) {
        let favorite = aDecoder.decodeObject(forKey: PropertyKey.favoritedLocationKey) as! String
        let amount = aDecoder.decodeInteger(forKey: PropertyKey.amountResultsKey)
        
        self.init(favoritedLocation: favorite, amountResults: amount)
        
        let temperatureUnitRawValue = aDecoder.decodeInteger(forKey: PropertyKey.temperatureUnitKey)
        self.temperatureUnit = TemperatureUnit(rawValue: temperatureUnitRawValue)! // force unwrap -> this should never fail, if it does the app should crash so we know
        
        let windspeedUnitRawValue = aDecoder.decodeInteger(forKey: PropertyKey.windspeedUnitKey)
        self.windspeedUnit = SpeedUnit(rawValue: windspeedUnitRawValue)! // force unwrap -> this should never fail, if it does the app should crash so we know
        
        self.singleLocationWeatherData = aDecoder.decodeObject(forKey: PropertyKey.singleLocationWeatherKey) as? [WeatherDTO]
        self.multiLocationWeatherData = aDecoder.decodeObject(forKey: PropertyKey.multiLocationWeatherKey) as? [WeatherDTO]
    }
    
    
    // MARK: - Public Properties & Methods
    
    public static func instantiateSharedInstance() {
        shared = WeatherService.loadService() ?? WeatherService(favoritedLocation: "Cupertino", amountResults: 10)
    }
    
    public func update(withCompletionHandler completionHandler: (() -> Void)?) {
        weatherServiceBackgroundQueue.async {
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
            WeatherService.storeService()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: kWeatherServiceDidUpdate), object: self)
                completionHandler?()
            }
        }
    }
    
    public func sortDataBy(orientation: SortingOrientation) {
        guard multiLocationWeatherData != nil else {
            return
        }
        switch orientation {
        case .byName: multiLocationWeatherData?.sort { $0.cityName < $1.cityName }
        case .byTemperature: multiLocationWeatherData?.sort { $0.rawTemperature > $1.rawTemperature }
        }
    }
    
    
    // MARK: - Private Helper Methods
    
    /* Internal Storage Helpers*/
    
    private static func loadService() -> WeatherService? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: WeatherService.ArchiveURL.path) as? WeatherService
    }
    
    private static func storeService() {
        _ = NSKeyedArchiver.archiveRootObject(WeatherService.shared, toFile: WeatherService.ArchiveURL.path)
    }
    
    /* Data Retrieval via Network */
    
    private func fetchSingleLocationWeatherData(completionHandler: @escaping ([WeatherDTO]?) -> Void) {
        let session = URLSession.shared
        let requestedCity = favoritedLocation.replacingOccurrences(of: " ", with: "")
        
        guard let apiKey = UserDefaults.standard.value(forKey: "nearby_weather.openWeatherMapApiKey"),
            let requestURL = URL(string: "\(WeatherService.openWeather_SingleLocationBaseURL)?APPID=\(apiKey)&q=\(requestedCity)") else {
                completionHandler(nil)
                return
        }
        
        let request = URLRequest(url: requestURL)
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let receivedData = data, let _ = response, error == nil else {
                 completionHandler(nil)
                return
            }
            completionHandler(self.extractSingleLocation(weatherData: receivedData))
        })
        dataTask.resume()
    }
    
    private func fetchMultiLocationWeatherData(completionHandler: @escaping ([WeatherDTO]?) -> Void) {
        let session = URLSession.shared
        
        guard let apiKey = UserDefaults.standard.value(forKey: "nearby_weather.openWeatherMapApiKey"),
            let requestURL = URL(string: "\(WeatherService.openWeather_MultiLocationBaseURL)?APPID=\(apiKey)&lat=\(LocationService.shared.currentLatitude)&lon=\(LocationService.shared.currentLongitude)&cnt=\(amountResults)") else {
                completionHandler(nil)
                return
        }
        
        let request = URLRequest(url: requestURL)
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let receivedData = data, let _ = response, error == nil else {
                completionHandler(nil)
                return
            }
            completionHandler(self.extractMultiLocation(weatherData: receivedData))
        })
        dataTask.resume()
        
    }
    
    private func extractSingleLocation(weatherData json: Data) -> [WeatherDTO]? {
        do {
            guard let extractedData = try JSONSerialization.jsonObject(with: json, options: .mutableContainers) as? [String: AnyHashable],
                let httpStatusCode = extractedData["cod"] as? Int,
                httpStatusCode == 200 else {
                    return nil
            }
            
            guard let weatherArray = extractedData["weather"] as? [[String: AnyHashable]],
                let weatherSymbolCode = weatherArray[0]["id"] as? Int,
                let cityName = extractedData["name"] as?  String,
                let main = extractedData["main"] as? [String: AnyHashable],
                let clouds = extractedData["clouds"] as? [String: AnyHashable],
                let wind = extractedData["wind"] as? [String: AnyHashable],
                let rawTemperature = main["temp"] as? Double,
                let cloudCoverage = clouds["all"] as? Double,
                let humidity = main["humidity"] as? Double,
                let windspeed = wind["speed"] as? Double else {
                    return nil
            }
            let condition = WeatherDTO.determineWeatherConditionSymbol(fromWeathercode: weatherSymbolCode)
            return [WeatherDTO(condition: condition, cityName: cityName, rawTemperature: rawTemperature, cloudCoverage: cloudCoverage, humidity: humidity, windspeed: windspeed)]
            
        } catch let jsonError {
            print("Error while extracting single-location-data json: \(jsonError.localizedDescription)")
            return nil
        }
        
        
    }
    
    private func extractMultiLocation(weatherData json: Data) -> [WeatherDTO]? {
        do {
            guard let rawData = try JSONSerialization.jsonObject(with: json, options: .mutableContainers) as? [String: AnyHashable],
                let httpStatusCode = rawData["cod"] as? String,
                httpStatusCode == "200",
                let extractedData = rawData["list"] as? [[String: AnyHashable]] else {
                    return nil
            }
            
            let weatherData = extractedData.reduce([WeatherDTO]()) {
                var partialResultCopy = $0
                
                guard let weatherArray = $1["weather"] as? [[String: AnyHashable]],
                    let weatherSymbolCode = weatherArray[0]["id"] as? Int,
                    let cityName = $1["name"] as?  String,
                    let main = $1["main"] as? [String: AnyHashable],
                    let clouds = $1["clouds"] as? [String: AnyHashable],
                    let wind = $1["wind"] as? [String: AnyHashable],
                    let rawTemperature = main["temp"] as? Double,
                    let cloudCoverage = clouds["all"] as? Double,
                    let humidity = main["humidity"] as? Double,
                    let windspeed = wind["speed"] as? Double else {
                        return $0
                }
                let condition = WeatherDTO.determineWeatherConditionSymbol(fromWeathercode: weatherSymbolCode)
                let weatherDTO = WeatherDTO(condition: condition, cityName: cityName, rawTemperature: rawTemperature, cloudCoverage: cloudCoverage, humidity: humidity, windspeed: windspeed)
                
                partialResultCopy.append(weatherDTO)
                return partialResultCopy
            }
            
            guard !weatherData.isEmpty else {
                return nil
            }
            return weatherData
            
        } catch let jsonError {
            print("Error while extracting multi-location-data json: \(jsonError.localizedDescription)")
            return nil
        }
    }
}

extension WeatherService: NSCoding {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(temperatureUnit.value.rawValue, forKey: PropertyKey.temperatureUnitKey)
        aCoder.encode(windspeedUnit.value.rawValue, forKey: PropertyKey.windspeedUnitKey)
        aCoder.encode(favoritedLocation, forKey: PropertyKey.favoritedLocationKey)
        aCoder.encode(amountResults, forKey: PropertyKey.amountResultsKey)
        aCoder.encode(singleLocationWeatherData, forKey: PropertyKey.singleLocationWeatherKey)
        aCoder.encode(multiLocationWeatherData, forKey: PropertyKey.multiLocationWeatherKey)
    }
    
    struct PropertyKey {
        fileprivate static let temperatureUnitKey = "temperatureUnit"
        fileprivate static let windspeedUnitKey = "windspeedUnit"
        fileprivate static let favoritedLocationKey = "favoritedLocation"
        fileprivate static let amountResultsKey = "chosenAmountResults"
        fileprivate static let singleLocationWeatherKey = "singleLocationWeatherData"
        fileprivate static let multiLocationWeatherKey = "multiLocationWeatherData"
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("nearby_weather.weather_service")
}
