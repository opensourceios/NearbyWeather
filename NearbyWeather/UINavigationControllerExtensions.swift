//
//  UINavigationControllerExtensions.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 22.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func addVerticalCloseButton(with completionHandler: (() -> ())?) {
        let verticalArrow = UIImage(named: "CloseVertical")
        
        let closeButton = BlockBarButtonItem(image: verticalArrow, style: .plain) {
            self.topViewController?.view.endEditing(true)
            self.presentingViewController?.dismiss(animated: true) {
                completionHandler?()
            }
        }
        viewControllers.first?.navigationItem.leftBarButtonItem = closeButton
    }
}
