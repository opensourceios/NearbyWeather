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

public class TemperatureUnitWrappedEnum: Codable {
    
    static let count = 3
    
    var value: TemperatureUnit
    
    init(value: TemperatureUnit) {
        self.value = value
    }
    
    convenience init?(rawValue: Int) {
        guard let value = TemperatureUnit(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    enum TemperatureUnit: Int, Codable {
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

public class SpeedUnitWrappedEnum: Codable {
    static let count = 2
    
    var value: SpeedUnit
    
    init(value: SpeedUnit) {
        self.value = value
    }
    
    convenience init?(rawValue: Int) {
        guard let value = SpeedUnit(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    enum SpeedUnit: Int, Codable {
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

public class AmountOfResultsWrappedEnum {
    
    static let count = 5
    
    var value: AmountOfResults
    
    init(value: AmountOfResults) {
        self.value = value
    }
    
    convenience init?(rawValue: Int) {
        guard let value = AmountOfResults(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    enum AmountOfResults: Int {
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

let kDefaultFavoritedCity = OWMCityDTO(identifier: 5341145, name: "Cupertino", country: "US", coordinates: Coordinates(latitude: 37.323002, longitude: -122.032181))
let kWeatherServiceDidUpdate = "de.erikmartens.nearbyWeather.weatherServiceDidUpdate"

fileprivate let kFavoritedLocationFileName = "de.erikmartens.nearbyWeather.weatherService.favoritedLocation"
fileprivate let kAmountResultsFileName = "de.erikmartens.nearbyWeather.weatherService.amountResults"
fileprivate let kTemperatureUnitFileName = "de.erikmartens.nearbyWeather.weatherService.temperatureUnit"
fileprivate let kWindspeedUnitFileName = "de.erikmartens.nearbyWeather.weatherService.windspeedUnit"
fileprivate let kSingleLocationWeatherData = "de.erikmartens.nearbyWeather.weatherService.singleLocationWeatherData"
fileprivate let kMultiLocationWeatherData = "de.erikmartens.nearbyWeather.weatherService.multiLocationWeatherData"

class WeatherDataService {
    
    // MARK: - Public Assets
    
    public static var shared: WeatherDataService!
    
    public var hasSingleLocationWeatherData: Bool {
        return singleLocationWeatherData != nil && !singleLocationWeatherData!.isEmpty
    }
    public var hasMultiLocationWeatherData: Bool {
        return multiLocationWeatherData != nil && !multiLocationWeatherData!.isEmpty
    }
    
    
    // MARK: - Private Assets
    
    private static let openWeather_SingleLocationBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private static let openWeather_MultiLocationBaseURL = "http://api.openweathermap.org/data/2.5/find"
    
    private let weatherServiceBackgroundQueue = DispatchQueue(label: "de.erikmartens.nearbyWeather.weatherService", qos: DispatchQoS.background, attributes: [DispatchQueue.Attributes.concurrent], autoreleaseFrequency: .inherit, target: nil)
    
    
    // MARK: - Properties
    
    public var favoritedLocation: OWMCityDTO {
        didSet {
            update(withCompletionHandler: nil)
        }
    }
    public var amountResults: Int {
        didSet {
            update(withCompletionHandler: nil)
        }
    }
    public var temperatureUnit: TemperatureUnitWrappedEnum {
        didSet {
            weatherServiceBackgroundQueue.async {
                WeatherDataService.storeService()
            }
        }
    }
    public var windspeedUnit: SpeedUnitWrappedEnum {
        didSet {
            weatherServiceBackgroundQueue.async {
                WeatherDataService.storeService()
            }
        }
    }
    
    public var singleLocationWeatherData: [OWMWeatherDTO]?
    public var multiLocationWeatherData: [OWMWeatherDTO]?
    
    private var locationAuthorizationObserver: NSObjectProtocol!
    
    
    // MARK: - Initialization
    
    private init(favoritedLocation: OWMCityDTO, amountResults: Int) {
        self.favoritedLocation = favoritedLocation
        self.amountResults = amountResults
        
        self.temperatureUnit = TemperatureUnitWrappedEnum(value: .celsius)
        self.windspeedUnit = SpeedUnitWrappedEnum(value: .kilometresPerHour)
        
        locationAuthorizationObserver = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil, using: { [unowned self] notification in
            self.update(withCompletionHandler: nil)
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(locationAuthorizationObserver)
    }
    
    
    // MARK: - Public Properties & Methods
    
    public static func instantiateSharedInstance() {
        shared = WeatherDataService.loadService() ?? WeatherDataService(favoritedLocation: kDefaultFavoritedCity, amountResults: 10)
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
            WeatherDataService.storeService()
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
        case .byTemperature: multiLocationWeatherData?.sort { $0.atmosphericInformation.temperatureKelvin > $1.atmosphericInformation.temperatureKelvin }
        }
    }
    
    
    // MARK: - Private Helper Methods
    
    /* Internal Storage Helpers*/
    
    private static func loadService() -> WeatherDataService? {
        guard let favoritedLocation = DataStorageService.retrieveFile(withFileName: kFavoritedLocationFileName, fromDirectory: .documents, asType: OWMCityDTO.self),
            let amountResults = DataStorageService.retrieveFile(withFileName: kAmountResultsFileName, fromDirectory: .documents, asType: Int.self),
            let temperatureUnit = DataStorageService.retrieveFile(withFileName: kTemperatureUnitFileName, fromDirectory: .documents, asType: TemperatureUnitWrappedEnum.self),
            let windspeedUnit = DataStorageService.retrieveFile(withFileName: kWindspeedUnitFileName, fromDirectory: .documents, asType: SpeedUnitWrappedEnum.self),
            let singleLocationWeatherData = DataStorageService.retrieveFile(withFileName: kWindspeedUnitFileName, fromDirectory: .documents, asType: [OWMWeatherDTO].self),
            let multiLocationWeatherData = DataStorageService.retrieveFile(withFileName: kWindspeedUnitFileName, fromDirectory: .documents, asType: [OWMWeatherDTO].self) else {
                return nil
        }
        
        let weatherService = WeatherDataService(favoritedLocation: favoritedLocation, amountResults: amountResults)
        weatherService.temperatureUnit = temperatureUnit
        weatherService.windspeedUnit = windspeedUnit
        weatherService.singleLocationWeatherData = singleLocationWeatherData
        weatherService.multiLocationWeatherData = multiLocationWeatherData
        
        return weatherService
    }
    
    private static func storeService() {
        DataStorageService.storeFile(withFileNwame: kFavoritedLocationFileName, forObject: WeatherDataService.shared.favoritedLocation, toDirectory: .documents)
        DataStorageService.storeFile(withFileNwame: kAmountResultsFileName, forObject: WeatherDataService.shared.amountResults, toDirectory: .documents)
        DataStorageService.storeFile(withFileNwame: kTemperatureUnitFileName, forObject: WeatherDataService.shared.temperatureUnit, toDirectory: .documents)
        DataStorageService.storeFile(withFileNwame: kWindspeedUnitFileName, forObject: WeatherDataService.shared.windspeedUnit, toDirectory: .documents)
        DataStorageService.storeFile(withFileNwame: kWindspeedUnitFileName, forObject: WeatherDataService.shared.singleLocationWeatherData, toDirectory: .documents)
        DataStorageService.storeFile(withFileNwame: kWindspeedUnitFileName, forObject: WeatherDataService.shared.multiLocationWeatherData, toDirectory: .documents)
    }
    
    /* Data Retrieval via Network */
    
    private func fetchSingleLocationWeatherData(completionHandler: @escaping ([OWMWeatherDTO]?) -> Void) {
        let session = URLSession.shared
        let requestedCity = favoritedLocation.identifier
        
        guard let apiKey = UserDefaults.standard.value(forKey: "nearby_weather.openWeatherMapApiKey"),
            let requestURL = URL(string: "\(WeatherDataService.openWeather_SingleLocationBaseURL)?APPID=\(apiKey)&id=\(requestedCity)") else {
                completionHandler(nil)
                return
        }
        
        let request = URLRequest(url: requestURL)
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let receivedData = data, let _ = response, error == nil else {
                 completionHandler(nil)
                return
            }
            completionHandler(self.extractSingleLocationWeatherData(fromData: receivedData))
        })
        dataTask.resume()
    }
    
    private func fetchMultiLocationWeatherData(completionHandler: @escaping ([OWMWeatherDTO]?) -> Void) {
        let session = URLSession.shared
        
        guard let currentLatitude = LocationService.shared.currentLatitude, let currentLongitude = LocationService.shared.currentLongitude else {
            completionHandler(nil)
            return
        }
        
        guard let apiKey = UserDefaults.standard.value(forKey: "nearby_weather.openWeatherMapApiKey"),
            let requestURL = URL(string: "\(WeatherDataService.openWeather_MultiLocationBaseURL)?APPID=\(apiKey)&lat=\(currentLatitude)&lon=\(currentLongitude)&cnt=\(amountResults)") else {
                completionHandler(nil)
                return
        }
        
        let request = URLRequest(url: requestURL)
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let receivedData = data, let _ = response, error == nil else {
                completionHandler(nil)
                return
            }
            completionHandler(self.extractMultiLocationWeatherData(fromData: receivedData))
        })
        dataTask.resume()
    }
    
    private func validateHttpStatusCode(fromData data: Data) throws -> Bool {
        guard let extractedData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyHashable],
            let httpStatusCode = extractedData["cod"] as? Int,
            httpStatusCode == 200 else {
                return false
        }
        return true
    }
    
    private func extractSingleLocationWeatherData(fromData data: Data) -> [OWMWeatherDTO]? {
        do {
            guard let extractedData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyHashable],
                let httpStatusCode = extractedData["cod"] as? Int,
                httpStatusCode == 200 else {
                    return nil
            }
            let weatherData = try JSONDecoder().decode(OWMWeatherDTO.self, from: data)
            return [weatherData]
        } catch let jsonError {
            print("💥 WeatherService: Error while extracting single-location-data json: \(jsonError.localizedDescription)")
            return nil
        }
    }
    
    private func extractMultiLocationWeatherData(fromData data: Data) -> [OWMWeatherDTO]? {
        do {
            guard let extractedData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyHashable],
                let httpStatusCode = extractedData["cod"] as? String,
                httpStatusCode == "200" else {
                    return nil
            }
            let multiWeatherData = try JSONDecoder().decode(OWMMultiWeatherDTO.self, from: data)
            return multiWeatherData.list
        } catch let jsonError {
            print("💥 WeatherService: Error while extracting single-location-data json: \(jsonError.localizedDescription)")
            return nil
        }
    }
}
