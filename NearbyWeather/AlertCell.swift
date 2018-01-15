//
//  AlertCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class AlertCell: UITableViewCell {
    
    private var timer: Timer?
    
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var warningImageView: UIView!
    @IBOutlet weak var noticeLabel: UILabel!
    
    deinit {
        warningImageView.layer.removeAllAnimations()
        timer?.invalidate()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        warningImageView.layer.removeAllAnimations()
        timer?.invalidate()
    }
    
    func startAnimationTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(AlertCell.animateWarningShake), userInfo: nil, repeats: false)
    }
    
    @objc private func animateWarningShake() {
        warningImageView.layer.removeAllAnimations()
        warningImageView.animatePulse(withAnimationDelegate: self)
    }
}

extension AlertCell: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        startAnimationTimer()
    }
}
