//
//  PreferencesManager.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

public class SortingOrientation: Codable {
    
    static let count = 3
    
    var value: SortingOrientationWrappedEnum
    
    init(value: SortingOrientationWrappedEnum) {
        self.value = value
    }
    
    convenience init?(rawValue: Int) {
        guard let value = SortingOrientationWrappedEnum(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    public enum SortingOrientationWrappedEnum: Int, Codable {
        case name
        case temperature
        case distance
    }
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
        case .kilometres: return "\(NSLocalizedString("kilometres", comment: "")) | \(NSLocalizedString("kilometres_per_hour", comment: ""))"
        case .miles: return "\(NSLocalizedString("miles", comment: "")) | \(NSLocalizedString("miles_per_hour", comment: ""))"
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

fileprivate let kPreferencesManagerStoredContentsFileName = "PreferencesManagerStoredContents"

struct PreferencesManagerStoredContentsWrapper: Codable {
    var amountOfResults: AmountOfResults
    var temperatureUnit: TemperatureUnit
    var windspeedUnit: DistanceSpeedUnit
    var sortingOrientation: SortingOrientation
}

class PreferencesManager {
    
    // MARK: - Public Assets
    
    public static var shared: PreferencesManager!
    
    
    // MARK: - Private Assets
    
    private let preferencesManagerBackgroundQueue = DispatchQueue(label: "de.erikmartens.nearbyWeather.preferencesManager", qos: .utility, attributes: [DispatchQueue.Attributes.concurrent], autoreleaseFrequency: .inherit, target: nil)
    
    
    // MARK: - Properties
    
    public var amountOfResults: AmountOfResults {
        didSet {
            WeatherDataManager.shared.update(withCompletionHandler: nil)
            preferencesManagerBackgroundQueue.async {
                PreferencesManager.storeService()
            }
        }
    }
    public var temperatureUnit: TemperatureUnit {
        didSet {
            preferencesManagerBackgroundQueue.async {
                PreferencesManager.storeService()
            }
        }
    }
    public var windspeedUnit: DistanceSpeedUnit {
        didSet {
            preferencesManagerBackgroundQueue.async {
                PreferencesManager.storeService()
            }
        }
    }
    
    public var sortingOrientation: SortingOrientation {
        didSet {
            preferencesManagerBackgroundQueue.async {
                PreferencesManager.storeService()
            }
        }
    }
    
    
    // MARK: - Initialization
    
    private init(amountOfResults: AmountOfResults, temperatureUnit: TemperatureUnit, windspeedUnit: DistanceSpeedUnit, sortingOrientation: SortingOrientation) {
        self.amountOfResults = amountOfResults
        self.temperatureUnit = temperatureUnit
        self.windspeedUnit = windspeedUnit
        self.sortingOrientation = sortingOrientation
    }
    
    
    // MARK: - Public Properties & Methods
    
    public static func instantiateSharedInstance() {
        shared = PreferencesManager.loadService() ?? PreferencesManager(amountOfResults: AmountOfResults(value: .ten), temperatureUnit: TemperatureUnit(value: .celsius), windspeedUnit: DistanceSpeedUnit(value: .kilometres), sortingOrientation: SortingOrientation(value: .name))
    }
    
    
    // MARK: - Private Helper Methods
    
    /* Internal Storage Helpers*/
    
    private static func loadService() -> PreferencesManager? {
        guard let preferencesManagerStoredContentsWrapper = DataStorageService.retrieveJson(fromFileWithName: kPreferencesManagerStoredContentsFileName, andDecodeAsType: PreferencesManagerStoredContentsWrapper.self) else {
            return nil
        }
        
        let weatherService = PreferencesManager(amountOfResults: preferencesManagerStoredContentsWrapper.amountOfResults,
                                                temperatureUnit: preferencesManagerStoredContentsWrapper.temperatureUnit,
                                                windspeedUnit: preferencesManagerStoredContentsWrapper.windspeedUnit,
                                                sortingOrientation: preferencesManagerStoredContentsWrapper.sortingOrientation)
        
        return weatherService
    }
    
    private static func storeService() {
        let preferencesManagerStoredContentsWrapper = PreferencesManagerStoredContentsWrapper(amountOfResults: PreferencesManager.shared.amountOfResults,
                                                                                       temperatureUnit: PreferencesManager.shared.temperatureUnit,
                                                                                       windspeedUnit: PreferencesManager.shared.windspeedUnit,
                                                                                       sortingOrientation: PreferencesManager.shared.sortingOrientation)
        DataStorageService.storeJson(forCodable: preferencesManagerStoredContentsWrapper, toFileWithName: kPreferencesManagerStoredContentsFileName)
    }
}
