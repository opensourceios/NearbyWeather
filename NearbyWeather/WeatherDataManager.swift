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

let kDefaultBookmarkedLocation = WeatherLocationDTO(identifier: 5341145, name: "Cupertino", country: "US", coordinates: Coordinates(latitude: 37.323002, longitude: -122.032181))

fileprivate let kWeatherDataServiceStoredContentFileName = "WeatherDataServiceStoredContents"

struct WeatherDataServiceStoredContentsWrapper: Codable {
    var bookmarkedLocation: WeatherLocationDTO
    var amountOfResults: AmountOfResults
    var temperatureUnit: TemperatureUnit
    var windspeedUnit: DistanceSpeedUnit
    var singleLocationWeatherData: SingleLocationWeatherData?
    var multiLocationWeatherData: MultiLocationWeatherData?
}

struct SingleLocationWeatherData: Codable {
    var errorDataDTO: ErrorDataDTO?
    var weatherDataDTO: WeatherDataDTO?
}

struct MultiLocationWeatherData: Codable {
    var errorDataDTO: ErrorDataDTO?
    var weatherDataDTOs: [WeatherDataDTO]?
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
    
    public var singleLocationWeatherData: SingleLocationWeatherData?
    public var multiLocationWeatherData: MultiLocationWeatherData?
    
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
    
    public func update(withCompletionHandler completionHandler: (() -> ())?) {
        guard NetworkReachabilityManager()!.isReachable else {
            completionHandler?()
            return
        }
        
        weatherServiceBackgroundQueue.async {
            let dispatchGroup = DispatchGroup()
            
            var singleLocationWeatherData: SingleLocationWeatherData?
            var multiLocationWeatherData: MultiLocationWeatherData?
            
            dispatchGroup.enter()
            self.fetchSingleLocationWeatherData(completionHandler: { weatherData in
                singleLocationWeatherData = weatherData
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            self.fetchMultiLocationWeatherData(completionHandler: { weatherData in
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
    
    public func sortData(byOrientation: SortingOrientation) {
        guard multiLocationWeatherData != nil else {
            return
        }
        switch byOrientation {
        case .name:
            multiLocationWeatherData?.weatherDataDTOs?.sort { $0.cityName < $1.cityName }
        case .temperature:
            multiLocationWeatherData?.weatherDataDTOs?.sort { $0.atmosphericInformation.temperatureKelvin > $1.atmosphericInformation.temperatureKelvin }
        case .distance:
            guard LocationService.shared.locationPermissionsGranted,
            let currentLocation = LocationService.shared.currentLocation else {
                break
            }
            multiLocationWeatherData?.weatherDataDTOs?.sort(by: {
                let weatherLocation1 = CLLocation(latitude: $0.coordinates.latitude, longitude: $0.coordinates.longitude)
                let weatherLocation2 = CLLocation(latitude: $1.coordinates.latitude, longitude: $1.coordinates.longitude)
                return weatherLocation1.distance(from: currentLocation) < weatherLocation2.distance(from: currentLocation)
            })
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
        if !LocationService.shared.locationPermissionsGranted {
            multiLocationWeatherData = nil
            WeatherDataManager.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kWeatherServiceDidUpdate), object: self)
        }
    }
    
    /* Data Retrieval via Network */
    
    private func fetchSingleLocationWeatherData(completionHandler: @escaping ((SingleLocationWeatherData) -> ())) {
        let session = URLSession.shared
        let requestedCity = bookmarkedLocation.identifier
        
        guard let apiKey = UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey),
            let requestURL = URL(string: "\(WeatherDataManager.openWeather_SingleLocationBaseURL)?APPID=\(apiKey)&id=\(requestedCity)") else {
                let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .malformedUrlError), httpStatusCode: nil)
                return completionHandler(SingleLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTO: nil))
                
        }
        
        let request = URLRequest(url: requestURL)
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let receivedData = data, let _ = response, error == nil else {
                let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .httpError), httpStatusCode: (response as? HTTPURLResponse)?.statusCode)
                return completionHandler(SingleLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTO: nil))
            }
            completionHandler(self.extractSingleLocationWeatherData(fromData: receivedData))
        })
        dataTask.resume()
    }
    
    private func fetchMultiLocationWeatherData(completionHandler: @escaping (MultiLocationWeatherData) -> Void) {
        let session = URLSession.shared
        
        guard let currentLatitude = LocationService.shared.currentLatitude, let currentLongitude = LocationService.shared.currentLongitude else {
            let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .locationUnavailableError), httpStatusCode: nil)
            return completionHandler(MultiLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTOs: nil))
        }
        guard let apiKey = UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey),
            let requestURL = URL(string: "\(WeatherDataManager.openWeather_MultiLocationBaseURL)?APPID=\(apiKey)&lat=\(currentLatitude)&lon=\(currentLongitude)&cnt=\(amountOfResults.integerValue)") else {
                let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .malformedUrlError), httpStatusCode: nil)
                return completionHandler(MultiLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTOs: nil))
        }
        let request = URLRequest(url: requestURL)
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let receivedData = data, let _ = response, error == nil else {
                let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .httpError), httpStatusCode: (response as? HTTPURLResponse)?.statusCode)
                return completionHandler(MultiLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTOs: nil))
            }
            completionHandler(self.extractMultiLocationWeatherData(fromData: receivedData))
        })
        dataTask.resume()
    }
    
    private func extractSingleLocationWeatherData(fromData data: Data) -> SingleLocationWeatherData {
        do {
            guard let extractedData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyHashable],
                let httpStatusCode = extractedData["cod"] as? Int else {
                    let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .unparsableResponseError), httpStatusCode: nil)
                    return SingleLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTO: nil)
            }
            guard httpStatusCode == 200 else {
                if httpStatusCode == 401 {
                    let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .unrecognizedApiKeyError), httpStatusCode: httpStatusCode)
                    return SingleLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTO: nil)
                }
                let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .httpError), httpStatusCode: httpStatusCode)
                return SingleLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTO: nil)
            }
            let weatherData = try JSONDecoder().decode(WeatherDataDTO.self, from: data)
            return SingleLocationWeatherData(errorDataDTO: nil, weatherDataDTO: weatherData)
        } catch {
            print("💥 WeatherDataService: Error while extracting single-location-data json: \(error.localizedDescription)")
            let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .jsonSerializationError), httpStatusCode: nil)
            return SingleLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTO: nil)
        }
    }
    
    private func extractMultiLocationWeatherData(fromData data: Data) -> MultiLocationWeatherData {
        do {
            guard let extractedData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyHashable],
                let httpStatusCodeString = extractedData["cod"] as? String,
                let httpStatusCode = Int(httpStatusCodeString) else {
                    let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .unparsableResponseError), httpStatusCode: nil)
                    return MultiLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTOs: nil)
            }
            guard httpStatusCode == 200 else {
                if httpStatusCode == 401 {
                    let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .unrecognizedApiKeyError), httpStatusCode: httpStatusCode)
                    return MultiLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTOs: nil)
                }
                let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .httpError), httpStatusCode: httpStatusCode)
                return MultiLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTOs: nil)
            }
            let multiWeatherData = try JSONDecoder().decode(MultiWeatherDataDTO.self, from: data)
            return MultiLocationWeatherData(errorDataDTO: nil, weatherDataDTOs: multiWeatherData.list)
        } catch {
            print("💥 WeatherDataService: Error while extracting multi-location-data json: \(error.localizedDescription)")
            let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .jsonSerializationError), httpStatusCode: nil)
            return MultiLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTOs: nil)
        }
    }
}
