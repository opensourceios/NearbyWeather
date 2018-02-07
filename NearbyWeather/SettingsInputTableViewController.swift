//
//  SettingsInputTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import TextFieldCounter
import PKHUD

class SettingsInputTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Assets

    /* Outlets */
    
    @IBOutlet weak var inputTextField: TextFieldCounter!
    
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        navigationItem.title = NSLocalizedString("SettingsInputTVC_NavigationBarTitle_Mode_EnterAPIKey", comment: "")
        inputTextField.text = UserDefaults.standard.string(forKey: kNearbyWeatherApiKeyKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        inputTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        inputTextField.resignFirstResponder()
        if let text = inputTextField.text, text.count == 32 {
            if let currentApiKey = UserDefaults.standard.string(forKey: kNearbyWeatherApiKeyKey), text == currentApiKey {
                return
            }
            UserDefaults.standard.set(text, forKey: kNearbyWeatherApiKeyKey)
            HUD.flash(.success, delay: 1.0)
            WeatherDataManager.shared.update(withCompletionHandler: nil)
        }
    }
    
    
    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("InputSettingsTVC_SectionTitle_Mode_EnterAPIKey", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("InputSettingsTVC_SectionFooter_Mode_EnterAPIKey", comment: "")
    }
    
    
    // MARK: - ScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        inputTextField.resignFirstResponder()
    }
    
    // MARK: - Private Helpers
    
    private func configure() {
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        inputTextField.animate = true
        inputTextField.ascending = true
        inputTextField.maxLength = 32
        inputTextField.counterColor = inputTextField.textColor ?? .black
        inputTextField.limitColor = .nearbyWeatherStandard
    }
}
