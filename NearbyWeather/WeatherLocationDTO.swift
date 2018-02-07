//
//  OpenWeatherMapCityDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct WeatherLocationDTO: Codable {
    
    var identifier: Int
    var name: String
    var country: String
    var coordinates: Coordinates

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case country
        case coordinates = "coord"
    }
}

struct Coordinates: Codable {
    var latitude: Double
    var longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}
