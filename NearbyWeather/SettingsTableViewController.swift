//
//  SettingsTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("SettingsTVC_NavigationBarTitle", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.styleStandard(withBarTintColor: .nearbyWeatherStandard, isTransluscent: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        tableView.reloadData()
    }
    
    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "InfoTableViewController") as! InfoTableViewController
            navigationItem.removeTextFromBackBarButton()
            navigationController?.pushViewController(destinationViewController, animated: true)
        case 1:
            break
        case 2:
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SettingsInputTVC") as! SettingsInputTableViewController
            
            navigationItem.removeTextFromBackBarButton()
            navigationController?.pushViewController(destinationViewController, animated: true)
        case 3:
            if indexPath.row == 0 {
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let destinationViewController = storyboard.instantiateViewController(withIdentifier: "WeatherLocationManagementTableViewController") as! WeatherLocationManagementTableViewController
                
                navigationItem.removeTextFromBackBarButton()
                navigationController?.pushViewController(destinationViewController, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let destinationViewController = storyboard.instantiateViewController(withIdentifier: "WeatherLocationSelectionTableViewController") as! WeatherLocationSelectionTableViewController
                
                navigationItem.removeTextFromBackBarButton()
                navigationController?.pushViewController(destinationViewController, animated: true)
            }
        case 4:
            if indexPath.row == 0 {
                triggerOptionsAlert(forOptions: amountOfResultsOptions, title: NSLocalizedString("SettingsTVC_AmountOfResults", comment: ""))
            }
            if indexPath.row == 1 {
                triggerOptionsAlert(forOptions: sortResultsOptions, title: NSLocalizedString("SettingsTVC_SortingOrientation", comment: ""))
            }
            if indexPath.row == 2 {
                triggerOptionsAlert(forOptions: temperatureUnitOptions, title: NSLocalizedString("SettingsTVC_TemperatureUnit", comment: ""))
            } else {
                triggerOptionsAlert(forOptions: distanceSpeedUnitOptions, title: NSLocalizedString("SettingsTVC_DistanceSpeedUnit", comment: ""))
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("SettingsTVC_SectionTitle0", comment: "")
        case 1:
            return nil
        case 2:
            return NSLocalizedString("SettingsTVC_SectionTitle1", comment: "")
        case 3:
            return nil
        case 4:
            return nil
        default:
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 2
        case 4:
            return 4
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell.contentLabel.text = NSLocalizedString("SettingsTVC_About", comment: "")
            cell.accessoryType = .disclosureIndicator
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath) as! ToggleCell
            cell.contentLabel.text = NSLocalizedString("SettingsTVC_RefreshOnAppStart", comment: "")
            cell.toggle.isOn = UserDefaults.standard.bool(forKey: kRefreshOnAppStartKey)
            cell.toggleSwitchHandler = { sender in
                UserDefaults.standard.set(sender.isOn, forKey: kRefreshOnAppStartKey)
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell.contentLabel.text = NSLocalizedString("apiKey", comment: "")
            cell.selectionLabel.text = UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey) as? String
            cell.accessoryType = .disclosureIndicator
            return cell
        case 3:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.contentLabel.text = NSLocalizedString("SettingsTVC_ManageLocations", comment: "")
                
                let entriesCount = WeatherDataManager.shared.bookmarkedLocations.count
                let firstLocationEntryTitle = WeatherDataManager.shared.bookmarkedLocations[indexPath.row].name
                
                cell.selectionLabel.text = entriesCount == 1 ? firstLocationEntryTitle : String(format: NSLocalizedString("SettingTVC_Locations", comment: ""), entriesCount)
                cell.accessoryType = .disclosureIndicator
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.contentLabel.text = NSLocalizedString("SettingsTVC_AddLocation", comment: "")
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        case 4:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.contentLabel.text = NSLocalizedString("SettingsTVC_AmountOfResults", comment: "")
                cell.selectionLabel.text = PreferencesManager.shared.amountOfResults.stringValue
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.contentLabel.text = NSLocalizedString("SettingsTVC_SortingOrientation", comment: "")
                cell.selectionLabel.text = PreferencesManager.shared.sortingOrientation.stringValue
                return cell
            }
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.contentLabel.text = NSLocalizedString("SettingsTVC_TemperatureUnit", comment: "")
                cell.selectionLabel.text = PreferencesManager.shared.temperatureUnit.stringValue
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.contentLabel.text = NSLocalizedString("SettingsTVC_DistanceSpeedUnit", comment: "")
                cell.selectionLabel.text = PreferencesManager.shared.distanceSpeedUnit.stringValue
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    // MARK: - Private Helpers
    
    private struct SettingsAlertOption<T: PreferencesOption> { var title: String; var value: Int; var preferenceType: T.Type }
    
    private let amountOfResultsOptions = [AmountOfResults(value: .ten),
                                          AmountOfResults(value: .twenty),
                                          AmountOfResults(value: .thirty),
                                          AmountOfResults(value: .forty),
                                          AmountOfResults(value: .fifty)]
    
    private let sortResultsOptions = [SortingOrientation(value: .name),
                                      SortingOrientation(value: .temperature),
                                      SortingOrientation(value: .distance)]
    
    private let temperatureUnitOptions = [TemperatureUnit(value: .celsius),
                                          TemperatureUnit(value: .fahrenheit),
                                          TemperatureUnit(value: .kelvin)]
    
    private let distanceSpeedUnitOptions = [DistanceSpeedUnit(value: .kilometres),
                                            DistanceSpeedUnit(value: .miles)]
    
    private func triggerOptionsAlert<T: PreferencesOption>(forOptions options: [T], title: String) {
        let optionsAlert: UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        
        // force unwrap options below -> this should never fail, if it does the app should crash so we know
        options.forEach { option in
            var actionIsSelected = false
            switch option {
            case is AmountOfResults:
                if PreferencesManager.shared.amountOfResults.value == (option as! AmountOfResults).value {
                    actionIsSelected = true
                }
            case is SortingOrientation:
                if (option as! SortingOrientation).value == .distance
                    && !LocationService.shared.locationPermissionsGranted {
                    return
                }
                if PreferencesManager.shared.sortingOrientation.value == (option as! SortingOrientation).value {
                    actionIsSelected = true
                }
            case is TemperatureUnit:
                if PreferencesManager.shared.temperatureUnit.value == (option as! TemperatureUnit).value {
                    actionIsSelected = true
                }
            case is DistanceSpeedUnit:
                if PreferencesManager.shared.distanceSpeedUnit.value == (option as! DistanceSpeedUnit).value {
                    actionIsSelected = true
                }
            default:
                return
            }
            
            let action = UIAlertAction(title: option.stringValue, style: .default, handler: { paramAction in
                switch option {
                case is AmountOfResults:
                    PreferencesManager.shared.amountOfResults = option as! AmountOfResults
                case is SortingOrientation:
                    PreferencesManager.shared.sortingOrientation = option as! SortingOrientation
                case is TemperatureUnit:
                    PreferencesManager.shared.temperatureUnit = option as! TemperatureUnit
                case is DistanceSpeedUnit:
                    PreferencesManager.shared.distanceSpeedUnit = option as! DistanceSpeedUnit
                default:
                    return
                }
                self.tableView.reloadData()
            })
            if actionIsSelected {
                action.setValue(true, forKey: "checked")
            }
            optionsAlert.addAction(action)
        }
        
        optionsAlert.addAction(cancelAction)
        
        present(optionsAlert, animated: true, completion: nil)
    }
}
