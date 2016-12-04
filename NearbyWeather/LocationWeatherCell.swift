//
//  LocationWeatherCell.swift
//  SimpleWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class LocationWeatherCell: UITableViewCell {
    
    //MARK: - Assets
    /* Views */
    @IBOutlet weak var backgroundColorView: UIView!
    
    /* Labels */
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windspeedLabel: UILabel!
    
    //MARK: - Override Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
