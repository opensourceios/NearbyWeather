//
//  AlertCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class AlertCell: UITableViewCell {
    
    // MARK: - Assets
    
    /* Views */
    
    @IBOutlet weak var backgroundColorView: UIView!
    
    /* Labels */
    
    @IBOutlet weak var noticeLabel: UILabel!

    
    // MARK: - Override Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
