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
    
    func configureWithErrorDataDTO(_ errorDataDTO: ErrorDataDTO?) {
        backgroundColorView.layer.cornerRadius = 5.0
        backgroundColorView.layer.backgroundColor = UIColor.black.cgColor
        
        if let errorDataDTO = errorDataDTO {
            switch errorDataDTO.errorType.value {
            case .httpError:
                noticeLabel.text = String(format: NSLocalizedString("LocationsListTVC_HttpError", comment: ""), errorDataDTO.httpStatusCode ?? -1)
            case .requestTimOutError:
                noticeLabel.text = NSLocalizedString("LocationsListTVC_RequestTimOutError", comment: "")
            case .malformedUrlError:
                noticeLabel.text = NSLocalizedString("LocationsListTVC_MalformedUrlError", comment: "")
            case .unparsableResponseError:
                noticeLabel.text = NSLocalizedString("LocationsListTVC_UnreadableResult", comment: "")
            case .jsonSerializationError:
                noticeLabel.text = NSLocalizedString("LocationsListTVC_UnreadableResult", comment: "")
            case .unrecognizedApiKeyError:
                noticeLabel.text = NSLocalizedString("LocationsListTVC_UnauthorizedApiKey", comment: "")
            case .locationUnavailableError:
                noticeLabel.text = NSLocalizedString("LocationsListTVC_LocationUnavailable", comment: "")
            }
        } else {
            noticeLabel.text = NSLocalizedString("LocationsListTVC_UnknownError", comment: "")
        }
        startAnimationTimer()
    }
    
    private func startAnimationTimer() {
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
