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
    
    init(weatherDTO: OWMWeatherDTO) {
        let weatherConditionIdentifier = weatherDTO.weatherCondition.first?.identifier
        let weatherConditionSymbol = weatherConditionIdentifier != nil ? ConversionService.weatherConditionSymbol(fromWeathercode: weatherConditionIdentifier!) : nil
        let temperatureDescriptor = ConversionService.temperatureDescriptor(forTemperatureUnit: WeatherDataService.shared.temperatureUnit, fromRawTemperature: weatherDTO.atmosphericInformation.temperatureKelvin)
        let lat = weatherDTO.coordinates.latitude
        let lon = weatherDTO.coordinates.longitude
        
        title = weatherDTO.cityName
        subtitle = weatherConditionSymbol != nil ? "\(weatherConditionSymbol!) \(temperatureDescriptor)" : "\(temperatureDescriptor)"
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
