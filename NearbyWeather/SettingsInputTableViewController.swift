//
//  SettingsInputTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

public enum DisplayMode: Int {
    case enterFavoritedLocation
    case enterAPIKey
}

class SettingsInputTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Assets
    
    /* Injection Targets */
    
    var mode: DisplayMode!

    /* Outlets */
    
    @IBOutlet weak var inputTextField: UITextField!
    
    
    // MARK: - Override Functions
    
    /* General */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        inputTextField.delegate = self
        switch mode! {
        case .enterFavoritedLocation:
            navigationItem.title = NSLocalizedString("SettingsInputTVC_NavigationBarTitle_Mode_EnterFavoritedLocation", comment: "")
            inputTextField.text! = WeatherService.current.favoritedLocation
            break
        case .enterAPIKey:
            navigationItem.title = NSLocalizedString("SettingsInputTVC_NavigationBarTitle_Mode_EnterAPIKey", comment: "")
            inputTextField.text! = UserDefaults.standard.value(forKey: "nearby_weather.openWeatherMapApiKey") as! String
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        inputTextField.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsInputTableViewController.reloadTableViewData(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        inputTextField.resignFirstResponder()
        switch mode! {
        case .enterFavoritedLocation:
            let text = inputTextField.text ?? ""
            if !text.isEmpty {
                WeatherService.current.favoritedLocation = text
            }
            break
        case .enterAPIKey:
            let text = inputTextField.text ?? ""
            if text.characters.count == 32 {
                UserDefaults.standard.set(text, forKey: "nearby_weather.openWeatherMapApiKey")
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.apiKeyUpdated.rawValue), object: self)
            }
        }
    }
    
    /* TableView */
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch mode! {
        case .enterFavoritedLocation: return NSLocalizedString("InputSettingsTVC_SectionTitle_Mode_EnterFavoritedLocation", comment: "")
        case .enterAPIKey: return NSLocalizedString("InputSettingsTVC_SectionTitle_Mode_EnterAPIKey", comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch mode! {
        case .enterFavoritedLocation: return nil
        case .enterAPIKey: return NSLocalizedString("InputSettingsTVC_SectionFooter_Mode_EnterAPIKey", comment: "")
        }
    }
    
    /* TextField */
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.inputTextField.resignFirstResponder()
    }
    
    /* Deinitializer */
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Helper Functions
    
    @objc func reloadTableViewData(_ notification: Notification) {
        tableView.reloadData()
    }
}
