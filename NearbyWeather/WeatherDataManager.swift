//
//  Weather.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import MapKit

public enum SortingOrientation: Int {
    case name
    case temperature
    case distance
}

public class TemperatureUnit: Codable {
    
    static let count = 3
    
    var value: TemperatureUnitWrappedEnum
    
    init(value: TemperatureUnitWrappedEnum) {
        self.value = value
    }
    
    convenience init?(rawValue: Int) {
        guard let value = TemperatureUnitWrappedEnum(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    enum TemperatureUnitWrappedEnum: Int, Codable {
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

public class DistanceSpeedUnit: Codable {
    static let count = 2
    
    var value: DistanceSpeedUnitWrappedEnum
    
    init(value: DistanceSpeedUnitWrappedEnum) {
        self.value = value
    }
    
    convenience init?(rawValue: Int) {
        guard let value = DistanceSpeedUnitWrappedEnum(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    enum DistanceSpeedUnitWrappedEnum: Int, Codable {
        case kilometres
        case miles
    }
    
    var stringDescriptor: String {
        switch value {
        case .kilometres: return "\(NSLocalizedString("kilometres", comment: ""))/\(NSLocalizedString("kilometres_per_hour", comment: ""))"
        case .miles: return "\(NSLocalizedString("miles", comment: ""))/\(NSLocalizedString("miles_per_hour", comment: ""))"
        }
    }
    
    var stringShortValue: String {
        switch value {
        case .kilometres: return NSLocalizedString("kmh", comment: "")
        case .miles: return NSLocalizedString("mph", comment: "")
        }
    }
}

public class AmountOfResults: Codable {
    
    static let count = 5
    
    var value: AmountOfResultsWrappedEnum
    
    init(value: AmountOfResultsWrappedEnum) {
        self.value = value
    }
    
    convenience init?(rawValue: Int) {
        guard let value = AmountOfResultsWrappedEnum(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    enum AmountOfResultsWrappedEnum: Int, Codable {
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

let kDefaultBookmarkedLocation = WeatherLocationDTO(identifier: 5341145, name: "Cupertino", country: "US", coordinates: Coordinates(latitude: 37.323002, longitude: -122.032181))
let kWeatherServiceDidUpdate = "de.erikmartens.nearbyWeather.weatherServiceDidUpdate"

fileprivate let kWeatherDataServiceStoredContentFileName = "WeatherDataServiceStoredContents"

struct WeatherDataServiceStoredContentsWrapper: Codable {
    var bookmarkedLocation: WeatherLocationDTO
    var amountOfResults: AmountOfResults
    var temperatureUnit: TemperatureUnit
    var windspeedUnit: DistanceSpeedUnit
    var singleLocationWeatherData: [LocationWeatherDataDTO]?
    var multiLocationWeatherData: [LocationWeatherDataDTO]?
}

class WeatherDataManager {
    
    // MARK: - Public Assets
    
    public static var shared: WeatherDataManager!
    
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
    
    public var bookmarkedLocation: WeatherLocationDTO {
        didSet {
            update(withCompletionHandler: nil)
        }
    }
    public var amountOfResults: AmountOfResults {
        didSet {
            update(withCompletionHandler: nil)
        }
    }
    public var temperatureUnit: TemperatureUnit {
        didSet {
            weatherServiceBackgroundQueue.async {
                WeatherDataManager.storeService()
            }
        }
    }
    public var windspeedUnit: DistanceSpeedUnit {
        didSet {
            weatherServiceBackgroundQueue.async {
                WeatherDataManager.storeService()
            }
        }
    }
    
    public var singleLocationWeatherData: [LocationWeatherDataDTO]?
    public var multiLocationWeatherData: [LocationWeatherDataDTO]?
    
    private var locationAuthorizationObserver: NSObjectProtocol!
    
    
    // MARK: - Initialization
    
    private init(bookmarkedLocation: WeatherLocationDTO, amountOfResults: AmountOfResults, temperatureUnit: TemperatureUnit, windspeedUnit: DistanceSpeedUnit) {
        self.bookmarkedLocation = bookmarkedLocation
        self.amountOfResults = amountOfResults
        
        self.temperatureUnit = temperatureUnit
        self.windspeedUnit = windspeedUnit
        
        locationAuthorizationObserver = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil, using: { [unowned self] notification in
            self.discardLocationBasedWeatherDataIfNeeded()
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(locationAuthorizationObserver)
    }
    
    
    // MARK: - Public Properties & Methods
    
    public static func instantiateSharedInstance() {
        shared = WeatherDataManager.loadService() ?? WeatherDataManager(bookmarkedLocation: kDefaultBookmarkedLocation, amountOfResults: AmountOfResults(value: .ten), temperatureUnit: TemperatureUnit(value: .celsius), windspeedUnit: DistanceSpeedUnit(value: .kilometres))
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
            WeatherDataManager.storeService()
            DispatchQueue.main.async {
                UserDefaults.standard.set(Date(), forKey: kWeatherDataLastRefreshDateKey)
                NotificationCenter.default.post(name: Notification.Name(rawValue: kWeatherServiceDidUpdate), object: self)
                completionHandler?()
            }
        }
    }
    
    public func sortData(byOrientation: SortingOrientation) {
        guard multiLocationWeatherData != nil else {
            return
        }
        switch byOrientation {
        case .name: multiLocationWeatherData?.sort { $0.cityName < $1.cityName }
        case .temperature: multiLocationWeatherData?.sort { $0.atmosphericInformation.temperatureKelvin > $1.atmosphericInformation.temperatureKelvin }
        case .distance:
            guard LocationService.shared.locationPermissionsGranted,
            let currentLocation = LocationService.shared.currentLocation else {
                break
            }
            multiLocationWeatherData?.sort(by: {
                let weatherLocation1 = CLLocation(latitude: $0.coordinates.latitude, longitude: $0.coordinates.longitude)
                let weatherLocation2 = CLLocation(latitude: $1.coordinates.latitude, longitude: $1.coordinates.longitude)
                return weatherLocation1.distance(from: currentLocation) < weatherLocation2.distance(from: currentLocation)
            })
        }
    }
    
    public func weatherDTO(forIdentifier identifier: Int) -> LocationWeatherDataDTO? {
        if let singleLocationMatch = singleLocationWeatherData?.first(where: { weatherDTO in
            return weatherDTO.cityID == identifier
        }) {
            return singleLocationMatch
        }
        if let multiLocationMatch = multiLocationWeatherData?.first(where: { weatherDTO in
            return weatherDTO.cityID == identifier
        }) {
            return multiLocationMatch
        }
        return nil
    }
    
    
    // MARK: - Private Helper Methods
    
    /* Internal Storage Helpers*/
    
    private static func loadService() -> WeatherDataManager? {
        guard let weatherDataServiceStoredContents = DataStorageService.retrieveJson(fromFileWithName: kWeatherDataServiceStoredContentFileName, andDecodeAsType: WeatherDataServiceStoredContentsWrapper.self) else {
                return nil
        }
        
        let weatherService = WeatherDataManager(bookmarkedLocation: weatherDataServiceStoredContents.bookmarkedLocation,
                                                amountOfResults: weatherDataServiceStoredContents.amountOfResults,
                                                temperatureUnit: weatherDataServiceStoredContents.temperatureUnit,
                                                windspeedUnit: weatherDataServiceStoredContents.windspeedUnit)
        weatherService.singleLocationWeatherData = weatherDataServiceStoredContents.singleLocationWeatherData
        weatherService.multiLocationWeatherData = weatherDataServiceStoredContents.multiLocationWeatherData
        
        return weatherService
    }
    
    private static func storeService() {
        let weatherDataServiceStoredContents = WeatherDataServiceStoredContentsWrapper(bookmarkedLocation: WeatherDataManager.shared.bookmarkedLocation,
                                                amountOfResults: WeatherDataManager.shared.amountOfResults,
                                                 temperatureUnit: WeatherDataManager.shared.temperatureUnit,
                                                 windspeedUnit: WeatherDataManager.shared.windspeedUnit,
                                                 singleLocationWeatherData: WeatherDataManager.shared.singleLocationWeatherData,
                                                 multiLocationWeatherData: WeatherDataManager.shared.multiLocationWeatherData)
        DataStorageService.storeJson(forCodable: weatherDataServiceStoredContents, toFileWithName: kWeatherDataServiceStoredContentFileName)
    }
    
    @objc private func discardLocationBasedWeatherDataIfNeeded() {
        if LocationService.shared.authorizationStatus != .authorizedWhenInUse && LocationService.shared.authorizationStatus != .authorizedAlways {
            multiLocationWeatherData = nil
            WeatherDataManager.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kWeatherServiceDidUpdate), object: self)
        }
    }
    
    /* Data Retrieval via Network */
    
    private func fetchSingleLocationWeatherData(completionHandler: @escaping ([LocationWeatherDataDTO]?) -> Void) {
        let session = URLSession.shared
        let requestedCity = bookmarkedLocation.identifier
        
        guard let apiKey = UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey),
            let requestURL = URL(string: "\(WeatherDataManager.openWeather_SingleLocationBaseURL)?APPID=\(apiKey)&id=\(requestedCity)") else {
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
    
    private func fetchMultiLocationWeatherData(completionHandler: @escaping ([LocationWeatherDataDTO]?) -> Void) {
        let session = URLSession.shared
        
        guard let currentLatitude = LocationService.shared.currentLatitude, let currentLongitude = LocationService.shared.currentLongitude else {
            completionHandler(nil)
            return
        }
        
        guard let apiKey = UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey),
            let requestURL = URL(string: "\(WeatherDataManager.openWeather_MultiLocationBaseURL)?APPID=\(apiKey)&lat=\(currentLatitude)&lon=\(currentLongitude)&cnt=\(amountOfResults.integerValue)") else {
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
    
    private func extractSingleLocationWeatherData(fromData data: Data) -> [LocationWeatherDataDTO]? {
        do {
            guard let extractedData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyHashable],
                let httpStatusCode = extractedData["cod"] as? Int,
                httpStatusCode == 200 else {
                    return nil
            }
            let weatherData = try JSONDecoder().decode(LocationWeatherDataDTO.self, from: data)
            return [weatherData]
        } catch let error {
            print("💥 WeatherDataService: Error while extracting single-location-data json: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func extractMultiLocationWeatherData(fromData data: Data) -> [LocationWeatherDataDTO]? {
        do {
            guard let extractedData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyHashable],
                let httpStatusCode = extractedData["cod"] as? String,
                httpStatusCode == "200" else {
                    return nil
            }
            let multiWeatherData = try JSONDecoder().decode(OWMMultiWeatherDTO.self, from: data)
            return multiWeatherData.list
        } catch let error {
            print("💥 WeatherDataService: Error while extracting multi-location-data json: \(error.localizedDescription)")
            return nil
        }
    }
}
