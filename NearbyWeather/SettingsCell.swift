//
//  SettingsCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    //MARK: - Assets
    
    /* Labels */
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    //MARK: - Override Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
