//
//  SingleLocationWeatherData.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct SingleLocationWeatherData: Codable {
    
    var statusCode: Int
    var locationWeatherDataDTO: WeatherDataDTO?
}
