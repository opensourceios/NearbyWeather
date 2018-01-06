//
//  SettingsInputTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import PKHUD

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
            inputTextField.text! = WeatherService.shared.favoritedLocation
            break
        case .enterAPIKey:
            navigationItem.title = NSLocalizedString("SettingsInputTVC_NavigationBarTitle_Mode_EnterAPIKey", comment: "")
            inputTextField.text! = UserDefaults.standard.value(forKey: "nearby_weather.openWeatherMapApiKey") as! String
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        inputTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        inputTextField.resignFirstResponder()
        switch mode! {
        case .enterFavoritedLocation:
            if let text = inputTextField.text, !text.isEmpty, text != WeatherService.shared.favoritedLocation {
                WeatherService.shared.favoritedLocation = text
                HUD.flash(.success, delay: 1.5)
            }
        case .enterAPIKey:
            if let text = inputTextField.text, text.count == 32 {
                if let currentApiKey = UserDefaults.standard.string(forKey: "nearby_weather.openWeatherMapApiKey"), text == currentApiKey {
                    return
                }
                UserDefaults.standard.set(text, forKey: "nearby_weather.openWeatherMapApiKey")
                HUD.flash(.success, delay: 1.5)
                WeatherService.shared.update(withCompletionHandler: nil)
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
        inputTextField.resignFirstResponder()
    }
}
