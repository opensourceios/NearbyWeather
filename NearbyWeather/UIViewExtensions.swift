//
//  UIViewExtensions.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 20.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import WaterDrops

extension UIView {
    
    func setDropShadow(with color: UIColor = UIColor.black, opacity: Float = 0.5, offSet: CGSize = CGSize(width: -1, height: 1), radius: CGFloat = 1, scale: Bool = true, shouldRasterize: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = shouldRasterize
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addDropAnimation(withVignetteSize size: CGFloat) {
        let waterDropsView = WaterDropsView(frame: self.frame,
                                            direction: .down,
                                            dropNum: 18,
                                            color: UIColor.white.withAlphaComponent(0.5),
                                            minDropSize: 2,
                                            maxDropSize: 8,
                                            minLength: frame.height,
                                            maxLength: frame.height,
                                            minDuration: 3,
                                            maxDuration: 6)
        waterDropsView.frame = CGRect(x: 0, y: 0, width: self.frame.width - size, height: self.frame.height - size)
        self.addSubview(waterDropsView)
        waterDropsView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        waterDropsView.addAnimation()
    }
    
    func animateShake(withAnimationDelegate delegate: CAAnimationDelegate) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.delegate = delegate
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.25
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0]
        layer.add(animation, forKey: "shake")
    }
}
