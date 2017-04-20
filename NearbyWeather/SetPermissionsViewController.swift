//
//  SetPermissionsViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class SetPermissionsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var askPermissionsButton: UIButton!
    
    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = NSLocalizedString("SetPermissionsVC_NavigationBarTitle", comment: "")
        setUp()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SetPermissionsViewController.launchApp), name: Notification.Name(rawValue: NotificationKeys.locationAuthorizationUpdated.rawValue), object: nil)
    }
    
    /* Deinitializer */
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Helper Functions
    
    func setUp() {
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.text! = NSLocalizedString("SetPermissionsVC_Description", comment: "")
        
        askPermissionsButton.setTitle(NSLocalizedString("SetPermissionsVC_AskPermissionsButtonTitle", comment: ""), for: .normal)
        askPermissionsButton.setTitleColor(UIColor(red: 39/255, green: 214/255, blue: 1, alpha: 1.0), for: .normal)
        askPermissionsButton.setTitleColor(.white, for: .highlighted)
        askPermissionsButton.layer.cornerRadius = 5.0
        askPermissionsButton.layer.borderColor = UIColor(red: 39/255, green: 214/255, blue: 1, alpha: 1.0).cgColor
        askPermissionsButton.layer.borderWidth = 1.0
    }
    
    func launchApp() {
        WeatherService.attachPersistentObject()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateInitialViewController()
        
        UIApplication.shared.keyWindow?.rootViewController = destinationViewController
    }
    
    
    // MARK: - Button Interaction
    
    @IBAction func didTapAskPermissionsButton(_ sender: UIButton) {
        if LocationService.current.authorizationStatus == .notDetermined {
            LocationService.current.requestWhenInUseAuthorization()
        } else {
            launchApp()
        }
    }
}
