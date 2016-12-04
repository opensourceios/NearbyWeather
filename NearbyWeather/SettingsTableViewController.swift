//
//  SettingsTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import EventKit

class SettingsTableViewController: UITableViewController {
    
    //MARK: - Assets
    /* General Assets */
    var amountResultsOptions: [Int] = [10, 20, 30, 40, 50]
    var chosenAmountResults: Int?
    
    var temperatureUnitOptions: [String] = ["Celsius", "Fahrenheit", "Kelvin"]
    var chosenTemperatureUnit: TemperatureUnit?
    
    let legend: [String] = [NSLocalizedString("SettingsTVC_Legend_Temperature", comment: ""), NSLocalizedString("SettingsTVC_Legend_CloudCover", comment: ""), NSLocalizedString("SettingsTVC_Legend_Humidity", comment: ""), NSLocalizedString("SettingsTVC_Legend_WindSpeed", comment: "")]
    
    //MARK: - Override Functions
    /* General */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("SettingsTVC_NavigationBarTitle", comment: "")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* TableView */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            chosenAmountResults = amountResultsOptions[indexPath.row]
            tableView.reloadData()
            break
        case 1:
            chosenTemperatureUnit = TemperatureUnit(rawValue: temperatureUnitOptions[indexPath.row])
            tableView.reloadData()
            break
        default:
            //Will never be executed
            break
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("SettingsTVC_SectionTitle1", comment: "")
        case 1:
            return NSLocalizedString("SettingsTVC_SectionTitle2", comment: "")
        case 2:
            return NSLocalizedString("SettingsTVC_SectionTitle3", comment: "")
        default:
            //Will never be executed
            return ""
        }
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return amountResultsOptions.count
        case 1:
            return temperatureUnitOptions.count
        case 2:
            return legend.count
        default:
            //Will never be executed
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        
        switch indexPath.section {
        case 0:
            cell.contentLabel.text! = "\(amountResultsOptions[indexPath.row]) \(NSLocalizedString("SettingsTVC_Results", comment: ""))"
            
            if amountResultsOptions[indexPath.row] == chosenAmountResults {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            return cell
        case 1:
            cell.contentLabel.text! = "\(temperatureUnitOptions[indexPath.row])"
            
            if temperatureUnitOptions[indexPath.row] == chosenTemperatureUnit?.rawValue {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            return cell
        case 2:
            cell.contentLabel.text! = legend[indexPath.row]
            
            cell.accessoryType = UITableViewCellAccessoryType.none
        
            return cell
        default:
            //Will never be executed
            return UITableViewCell()
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: - Navigation Seguess
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //No action necessary here
    }
    
    //MARK: - Button Interaction
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "manualUnwindToNearbyLocationsTVC", sender: self)
    }
}
