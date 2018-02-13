//
//  WeatherDataCell.swift
//  SimpleWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import SDWebImage

class WeatherDataCell: UITableViewCell {
    
    var weatherDataIdentifier: Int!
   
    @IBOutlet weak var backgroundColorView: UIView!
    
    @IBOutlet weak var weatherConditionImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverageLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windspeedLabel: UILabel!
    
    func configureWithWeatherDTO(_ weatherDTO: WeatherDataDTO) {
        weatherDataIdentifier = weatherDTO.cityID
        
        backgroundColorView.layer.cornerRadius = 5.0
        backgroundColorView.layer.backgroundColor = UIColor.nearbyWeatherBubble.cgColor
        
        cityNameLabel.textColor = .white
        cityNameLabel.font = .preferredFont(forTextStyle: .headline)
        
        temperatureLabel.textColor = .white
        temperatureLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        cloudCoverageLabel.textColor = .white
        cloudCoverageLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        humidityLabel.textColor = .white
        humidityLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        windspeedLabel.textColor = .white
        windspeedLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        weatherConditionImageView.contentMode = .scaleAspectFill
        weatherConditionImageView.sd_setImage(with: URL(string: "http://openweathermap.org/img/w/\(weatherDTO.weatherCondition[0].conditionIconCode).png"), placeholderImage: UIImage(named: "conditionPlaceholder"))
        
        cityNameLabel.text = weatherDTO.cityName
        
        let temperatureDescriptor = ConversionService.temperatureDescriptor(forTemperatureUnit: PreferencesManager.shared.temperatureUnit, fromRawTemperature: weatherDTO.atmosphericInformation.temperatureKelvin)
        temperatureLabel.text = "🌡 \(temperatureDescriptor)"
        
        cloudCoverageLabel.text = "☁️ \(weatherDTO.cloudCoverage.coverage)%"
        
        humidityLabel.text = "💧 \(weatherDTO.atmosphericInformation.humidity)%"
        
        let windspeedDescriptor = ConversionService.windspeedDescriptor(forDistanceSpeedUnit: PreferencesManager.shared.windspeedUnit, forWindspeed: weatherDTO.windInformation.windspeed)
        windspeedLabel.text = "🎏 \(windspeedDescriptor)"
    }
}
