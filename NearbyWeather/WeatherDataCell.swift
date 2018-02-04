//
//  WeatherDataCell.swift
//  SimpleWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class WeatherDataCell: UITableViewCell {
    
    var weatherDataIdentifier: Int!
   
    @IBOutlet weak var backgroundColorView: UIView!
    
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windspeedLabel: UILabel!
}
