//
//  BlockBarButtonItem.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 23.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class BlockBarButtonItem: UIBarButtonItem {
    private var actionHandler: (() -> ())?
    
    convenience init(title: String?, style: UIBarButtonItemStyle, actionHandler: (() -> ())?) {
        self.init(title: title, style: style, target: nil, action: #selector(BlockBarButtonItem.barButtonItemPressed))
        self.target = self
        self.actionHandler = actionHandler
    }
    
    convenience init(image: UIImage?, style: UIBarButtonItemStyle, actionHandler: ((()) -> ())?) {
        self.init(image: image, style: style, target: nil, action: #selector(BlockBarButtonItem.barButtonItemPressed))
        self.target = self
        self.actionHandler = actionHandler
    }
    
    @objc private func barButtonItemPressed(sender: UIBarButtonItem) {
        actionHandler?()
    }
}
