//
//  LocationsListTableViewController.swift
//  SimpleWeather
//
//  Created by Erik Maximilian Martens on 02.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyLocationsTableViewController: UITableViewController {
    
    // MARK: - Override Functions
    
    /* General */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "NW"
        
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: NSLocalizedString("LocationsListTVC_RefreshPullHandle", comment: ""))
        refreshControl?.addTarget(self, action: #selector(NearbyLocationsTableViewController.refreshContent(refreshControl:)), for: UIControlEvents.valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NearbyLocationsTableViewController.reloadTableViewDataWithDataPull(_:)), name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated_dataPullRequired.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NearbyLocationsTableViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NearbyLocationsTableViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: NotificationKeys.apiKeyUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NearbyLocationsTableViewController.reloadTableViewData(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: "nearby_weather.isInitialLaunch") == nil {
            startActivityIndicator()
            WeatherService.current.fetchDataWith {
                UserDefaults.standard.set(false, forKey: "nearby_weather.isInitialLaunch")
                self.stopActivityIndicator()
            }
        }
    }
    
    /* TableView */

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !WeatherService.current.singleLocationWeatherData.isEmpty && !WeatherService.current.multiLocationWeatherData.isEmpty {
            switch section {
            case 0:
                return NSLocalizedString("LocationsListTVC_TableViewSectionHeader1", comment: "")
            case 1:
                return NSLocalizedString("LocationsListTVC_TableViewSectionHeader2", comment: "")
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !WeatherService.current.singleLocationWeatherData.isEmpty && !WeatherService.current.multiLocationWeatherData.isEmpty {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !WeatherService.current.singleLocationWeatherData.isEmpty && !WeatherService.current.multiLocationWeatherData.isEmpty {
            if section == 0 {
                return WeatherService.current.singleLocationWeatherData.count
            }
            return WeatherService.current.multiLocationWeatherData.count
        }
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !WeatherService.current.singleLocationWeatherData.isEmpty && !WeatherService.current.multiLocationWeatherData.isEmpty {
            var weatherData: WeatherDTO!
            if indexPath.section == 0 {
                weatherData = WeatherService.current.singleLocationWeatherData[indexPath.row]
            } else {
                weatherData = WeatherService.current.multiLocationWeatherData[indexPath.row]
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationWeatherCell", for: indexPath) as! LocationWeatherCell
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            cell.backgroundColorView.layer.cornerRadius = 5.0
            cell.backgroundColorView.layer.backgroundColor = UIColor(red: 39/255, green: 214/255, blue: 1, alpha: 1.0).cgColor
            
            cell.cityNameLabel.textColor = .white
            cell.cityNameLabel.font = .preferredFont(forTextStyle: .headline)
            
            cell.temperatureLabel.textColor = .white
            cell.temperatureLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.cloudCoverLabel.textColor = .white
            cell.cloudCoverLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.humidityLabel.textColor = .white
            cell.humidityLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.windspeedLabel.textColor = .white
            cell.windspeedLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.weatherConditionLabel.text! = weatherData.condition
            cell.cityNameLabel.text! = weatherData.cityName
            cell.temperatureLabel.text! = "🌡 \(weatherData.temperature)"
            cell.cloudCoverLabel.text! = "☁️ \(weatherData.cloudCoverage)%"
            cell.humidityLabel.text! = "💧 \(weatherData.humidity)%"
            cell.windspeedLabel.text! = "💨 \(weatherData.windspeed) km/h"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            cell.noticeLabel.text! = NSLocalizedString("LocationsListTVC_AlertNoData", comment: "")
            cell.backgroundColorView.layer.cornerRadius = 5.0
            return cell
        }
    }
    
    /* Deinitializer */
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Helper Functions
    
    /* General */
    
    @objc private func refreshContent(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        
        WeatherService.current.fetchDataWith {
            refreshControl.endRefreshing()
        }
    }
    
    @objc func reloadTableViewDataWithDataPull(_ notification: Notification) {
        startActivityIndicator()
        WeatherService.current.fetchDataWith {
            UserDefaults.standard.set(false, forKey: "nearby_weather.isInitialLaunch")
            self.stopActivityIndicator()
            self.tableView.reloadData()
        }
    }
    
    @objc func reloadTableViewData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    private func startActivityIndicator() {
        guard tableView != nil else {
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        activityIndicator.layer.cornerRadius = 10
        
        tableView?.addSubview(activityIndicator)
        if let superViewCenter = activityIndicator.superview?.center {
            activityIndicator.center = superViewCenter
        }
        activityIndicator.startAnimating()
        
        
    }
    
    private func stopActivityIndicator() {
        guard let subviews = tableView?.subviews else {
            return
        }
        for subview in subviews where subview is UIActivityIndicatorView {
            subview.removeFromSuperview()
        }
    }
    
    /* Alerts */
    
    private func triggerSortAlert() {
        let sortAlert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let firstAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        let secondAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Action1", comment: ""), style: UIAlertActionStyle.default, handler: {(paramAction:UIAlertAction!) in
            WeatherService.current.sortDataBy(orientation: .byName)
            self.tableView.reloadData()
        })
        let thirdAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Action2", comment: ""), style: UIAlertActionStyle.default, handler: {(paramAction:UIAlertAction!) in
            WeatherService.current.sortDataBy(orientation: .byTemperature)
            self.tableView.reloadData()
        })
        
        sortAlert.addAction(firstAction)
        sortAlert.addAction(secondAction)
        sortAlert.addAction(thirdAction)
        self.present(sortAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation Segues
    
    @IBAction func didTapSettingsButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SettingsTVC") as! SettingsTableViewController
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.navigationBar.tintColor = .white
        
        let rootController = self as UITableViewController
        rootController.present(destinationNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func didTapInfoButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "InfoTVC") as! InfoTableViewController
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.navigationBar.tintColor = .white
        
        let rootController = self as UITableViewController
        rootController.present(destinationNavigationController, animated: true, completion: nil)
    }
    
    
    // MARK: - Button Interaction
    
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        self.triggerSortAlert()
    }
}
