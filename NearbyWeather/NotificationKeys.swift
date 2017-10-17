//
//  NotificationKeys.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

enum NotificationKeys: String {
    case locationAuthorizationUpdated = "nearby_weather.locationAuthorizationUpdated"
    case weatherServiceUpdated_dataPullRequired = "nearby_weather.weatherServiceUpdated_dataPullRequired"
    case weatherServiceUpdated = "nearby_weather.weatherServiceUpdated"
    case apiKeyUpdated = "nearby_weather.apiKeyUpdated"
}
