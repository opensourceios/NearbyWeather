//
//  NetworkingService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import Alamofire

enum ReachabilityStatus {
    case unknown
    case disconnected
    case connected
}

private let kOpenWeatherSingleLocationBaseURL = "http://api.openweathermap.org/data/2.5/weather"
private let kOpenWeatherMultiLocationBaseURL = "http://api.openweathermap.org/data/2.5/find"

class NetworkingService {
    
    // MARK: - Public Assets
    
    public static var shared: NetworkingService!

    
    // MARK: - Properties
    
    private let reachabilityManager: NetworkReachabilityManager?
    public private(set) var reachabilityStatus: ReachabilityStatus
    
    // MARK: - Initialization
    
    private init() {
        self.reachabilityManager = NetworkReachabilityManager()
        self.reachabilityStatus = .unknown
        
        beginListeningNetworkReachability()
    }
    
    deinit {
        reachabilityManager?.stopListening()
    }
    
    // MARK: - Private Methods
    
    func beginListeningNetworkReachability() {
        reachabilityManager?.listener = { status in
            switch status {
            case .unknown: self.reachabilityStatus = .unknown
            case .notReachable: self.reachabilityStatus = .disconnected
            case .reachable(.ethernetOrWiFi), .reachable(.wwan): self.reachabilityStatus = .connected
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNetworkReachabilityChanged), object: self)
        }
        reachabilityManager?.startListening()
    }
    
    
    // MARK: - Public Methods
    
    public static func instantiateSharedInstance() {
        shared = NetworkingService()
    }
    
    public func fetchSingleLocationWeatherData(completionHandler: @escaping ((SingleLocationWeatherData) -> ())) {
        let session = URLSession.shared
        let requestedCity = WeatherDataManager.shared.bookmarkedLocation.identifier
        
        guard let apiKey = UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey),
            let requestURL = URL(string: "\(kOpenWeatherSingleLocationBaseURL)?APPID=\(apiKey)&id=\(requestedCity)") else {
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
    
    public func fetchMultiLocationWeatherData(completionHandler: @escaping (MultiLocationWeatherData) -> Void) {
        let session = URLSession.shared
        
        guard let currentLatitude = LocationService.shared.currentLatitude, let currentLongitude = LocationService.shared.currentLongitude else {
            let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .locationUnavailableError), httpStatusCode: nil)
            return completionHandler(MultiLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTOs: nil))
        }
        guard let apiKey = UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey),
            let requestURL = URL(string: "\(kOpenWeatherMultiLocationBaseURL)?APPID=\(apiKey)&lat=\(currentLatitude)&lon=\(currentLongitude)&cnt=\(PreferencesManager.shared.amountOfResults.integerValue)") else {
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
    
    
    // MARK: - Private Helpers
    
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
            print("💥 NetworkingService: Error while extracting single-location-data json: \(error.localizedDescription)")
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
            print("💥 NetworkingService: Error while extracting multi-location-data json: \(error.localizedDescription)")
            let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .jsonSerializationError), httpStatusCode: nil)
            return MultiLocationWeatherData(errorDataDTO: errorDataDTO, weatherDataDTOs: nil)
        }
    }
}
