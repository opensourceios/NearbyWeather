//
//  WeatherLocationMapAnnotation.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import MapKit

class WeatherLocationMapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
    convenience init?(weatherDTO: LocationWeatherDataDTO?) {
        guard let weatherDTO = weatherDTO else { return nil }
        
        let weatherConditionIdentifier = weatherDTO.weatherCondition.first?.identifier
        let weatherConditionSymbol = weatherConditionIdentifier != nil ? ConversionService.weatherConditionSymbol(fromWeathercode: weatherConditionIdentifier!) : nil
        let temperatureDescriptor = ConversionService.temperatureDescriptor(forTemperatureUnit: WeatherDataManager.shared.temperatureUnit, fromRawTemperature: weatherDTO.atmosphericInformation.temperatureKelvin)
        
        let subtitle = weatherConditionSymbol != nil ? "\(weatherConditionSymbol!) \(temperatureDescriptor)" : "\(temperatureDescriptor)"
        let coordinate = CLLocationCoordinate2D(latitude: weatherDTO.coordinates.latitude, longitude: weatherDTO.coordinates.longitude)
        
        self.init(title: weatherDTO.cityName, subtitle: subtitle, coordinate: coordinate)
    }
}
