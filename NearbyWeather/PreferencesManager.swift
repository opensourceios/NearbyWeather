//
//  PreferencesManager.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

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

//class PreferencesManager {
//    
//}

