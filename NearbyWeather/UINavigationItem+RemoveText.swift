//
//  UINavigationItem+RemoveText.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension UINavigationItem {
    
    func removeTextFromBackBarButton() {
        let barButton = UIBarButtonItem()
        barButton.title = ""
        self.backBarButtonItem = barButton
    }
}
