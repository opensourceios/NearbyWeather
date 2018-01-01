//
//  WeatherListViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 20.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RainyRefreshControl

class WeatherListViewController: UIViewController {
    
    // MARK: - Properties
    
    private var refreshControl = RainyRefreshControl()
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonRowContainerView: UIView!
    @IBOutlet weak var buttonRowStackView: UIStackView!
    
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "NearbyWeather"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 75, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherListViewController.reloadTableViewDataWithDataPull(_:)), name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated_dataPullRequired.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherListViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherListViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: NotificationKeys.apiKeyUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherListViewController.reloadTableViewData(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: "nearby_weather.isInitialLaunch") == nil {
            UserDefaults.standard.set(false, forKey: "nearby_weather.isInitialLaunch")
            reload()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        refreshControl.endRefreshing()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Private Helpers
    
    private func configure() {
        buttonRowContainerView.layer.cornerRadius = 10
        buttonRowContainerView.layer.backgroundColor = UIColor.nearbyWeatherStandard.withAlphaComponent(0.9).cgColor
        buttonRowContainerView.addDropShadow(radius: 10)
        
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addRainDropAnimation(withVignetteSize: 10)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        buttonRowContainerView.addRainDropAnimation(withVignetteSize: 20)
        buttonRowContainerView.bringSubview(toFront: buttonRowStackView)
        
        reloadButton.tintColor = .white
        sortButton.tintColor = .white
        infoButton.tintColor = .white
        settingsButton.tintColor = .white
        
        refreshControl.addTarget(self, action: #selector(WeatherListViewController.refreshContent(refreshControl:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    private func reload() {
        refreshControl.beginRefreshing()
        WeatherService.current.fetchDataWith {
            UserDefaults.standard.set(false, forKey: "nearby_weather.isInitialLaunch")
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    @objc private func refreshContent(refreshControl: RainyRefreshControl) {
        reload()
    }
    
    @objc func reloadTableViewDataWithDataPull(_ notification: Notification) {
        reload()
    }
    
    @objc func reloadTableViewData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    private func triggerSortAlert() {
        let sortAlert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let firstAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Cancel", comment: ""), style: .cancel, handler: nil)
        let secondAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Action1", comment: ""), style: .default, handler: { paramAction in
            WeatherService.current.sortDataBy(orientation: .byName)
            self.tableView.reloadData()
        })
        let thirdAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Action2", comment: ""), style: .default, handler: { paramAction in
            WeatherService.current.sortDataBy(orientation: .byTemperature)
            self.tableView.reloadData()
        })
        
        sortAlert.addAction(firstAction)
        sortAlert.addAction(secondAction)
        sortAlert.addAction(thirdAction)
        self.present(sortAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - Button Interaction
    
    @IBAction func didTapSettingsButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SettingsTVC") as! SettingsTableViewController
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.addVerticalCloseButton(withCompletionHandler: nil)
        navigationController?.present(destinationNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func didTapInfoButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "InfoTVC") as! InfoTableViewController
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.addVerticalCloseButton(withCompletionHandler: nil)
        navigationController?.present(destinationNavigationController, animated: true, completion: nil)
    }

    @IBAction func sortButtonPressed(_ sender: UIButton) {
        triggerSortAlert()
    }
    
    @IBAction func didTapReloadButton(_ sender: UIButton) {
        reload()
    }
}

extension WeatherListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
}

extension WeatherListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let singleLocationWeatherData = WeatherService.current.singleLocationWeatherData,
            !singleLocationWeatherData.isEmpty,
            let multiLocationWeatherData = WeatherService.current.multiLocationWeatherData,
            !multiLocationWeatherData.isEmpty else {
                return nil
        }
        switch section {
        case 0:
            return NSLocalizedString("LocationsListTVC_TableViewSectionHeader1", comment: "")
        case 1:
            return NSLocalizedString("LocationsListTVC_TableViewSectionHeader2", comment: "")
        default:
            return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let singleLocationWeatherData = WeatherService.current.singleLocationWeatherData,
            !singleLocationWeatherData.isEmpty,
            let multiLocationWeatherData = WeatherService.current.multiLocationWeatherData,
            !multiLocationWeatherData.isEmpty else {
                return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let singleLocationWeatherData = WeatherService.current.singleLocationWeatherData,
            !singleLocationWeatherData.isEmpty,
            let multiLocationWeatherData = WeatherService.current.multiLocationWeatherData,
            !multiLocationWeatherData.isEmpty else {
                return 1
        }
        switch section {
        case 0:
            return singleLocationWeatherData.count
        case 1:
            return multiLocationWeatherData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let singleLocationWeatherData = WeatherService.current.singleLocationWeatherData,
            !singleLocationWeatherData.isEmpty,
            let multiLocationWeatherData = WeatherService.current.multiLocationWeatherData,
            !multiLocationWeatherData.isEmpty else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
                
                cell.selectionStyle = .none
                cell.backgroundColor = .clear
                
                cell.warningImageView.tintColor = .white
                
                cell.noticeLabel.text! = NSLocalizedString("LocationsListTVC_AlertNoData", comment: "")
                cell.backgroundColorView.layer.cornerRadius = 5.0
                cell.startAnimationTimer()
                return cell
        }
        var weatherData: WeatherDTO!
        if indexPath.section == 0 {
            weatherData = singleLocationWeatherData[indexPath.row]
        } else {
            weatherData = multiLocationWeatherData[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationWeatherCell", for: indexPath) as! LocationWeatherCell
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        cell.backgroundColorView.layer.cornerRadius = 5.0
        cell.backgroundColorView.layer.backgroundColor = UIColor.nearbyWeatherBubble.cgColor
        
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
        cell.temperatureLabel.text! = "🌡 \(weatherData.determineTemperatureForUnit())"
        cell.cloudCoverLabel.text! = "☁️ \(weatherData.cloudCoverage)%"
        cell.humidityLabel.text! = "💧 \(weatherData.humidity)%"
        cell.windspeedLabel.text! = "💨 \(weatherData.windspeed) km/h"
        return cell
    }
}
