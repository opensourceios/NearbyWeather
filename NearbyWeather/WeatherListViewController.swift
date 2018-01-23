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
    
    @IBOutlet weak var refreshButton: UIButton!
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
        
        tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherListViewController.reloadTableView(_:)), name: Notification.Name(rawValue: kWeatherServiceDidUpdate), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: "nearby_weather.isInitialLaunch") == nil {
            UserDefaults.standard.set(false, forKey: "nearby_weather.isInitialLaunch")
            updateWeatherData()
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
        buttonRowContainerView.layer.backgroundColor = UIColor.nearbyWeatherStandard.cgColor
        buttonRowContainerView.addDropShadow(radius: 10)
        
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        buttonRowContainerView.bringSubview(toFront: buttonRowStackView)
        
        refreshButton.tintColor = .white
        sortButton.tintColor = .white
        infoButton.tintColor = .white
        settingsButton.tintColor = .white
        
        refreshControl.addTarget(self, action: #selector(WeatherListViewController.updateWeatherData), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc private func updateWeatherData() {
        refreshControl.beginRefreshing()
        WeatherDataService.shared.update(withCompletionHandler: {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    @objc private func reloadTableView(_ notification: Notification) {
        tableView.reloadData()
    }
    
    private func triggerSortAlert() {
        let sortAlert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Cancel", comment: ""), style: .cancel, handler: nil)
        let sortByNameAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Action1", comment: ""), style: .default, handler: { paramAction in
            WeatherDataService.shared.sortDataBy(orientation: .byName)
            self.tableView.reloadData()
        })
        let sortByTemperatureAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Action2", comment: ""), style: .default, handler: { paramAction in
            WeatherDataService.shared.sortDataBy(orientation: .byTemperature)
            self.tableView.reloadData()
        })
        
        sortAlert.addAction(cancelAction)
        sortAlert.addAction(sortByNameAction)
        sortAlert.addAction(sortByTemperatureAction)
        present(sortAlert, animated: true, completion: nil)
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
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "NearbyLocationsMapViewController") as! NearbyLocationsMapViewController
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.addVerticalCloseButton(withCompletionHandler: nil)
        navigationController?.present(destinationNavigationController, animated: true, completion: nil)
    }

    @IBAction func sortButtonPressed(_ sender: UIButton) {
        triggerSortAlert()
    }
    
    @IBAction func didTapRefreshButton(_ sender: UIButton) {
        updateWeatherData()
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
        if !WeatherDataService.shared.hasSingleLocationWeatherData && !WeatherDataService.shared.hasMultiLocationWeatherData {
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
        if !WeatherDataService.shared.hasSingleLocationWeatherData && !WeatherDataService.shared.hasMultiLocationWeatherData {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !WeatherDataService.shared.hasSingleLocationWeatherData && !WeatherDataService.shared.hasMultiLocationWeatherData {
            return 1
        }
        switch section {
        case 0:
            return 1
        case 1:
            guard let multiLocationWeatherData = WeatherDataService.shared.multiLocationWeatherData else {
                return 1
            }
            return multiLocationWeatherData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !WeatherDataService.shared.hasSingleLocationWeatherData && !WeatherDataService.shared.hasMultiLocationWeatherData {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
                
                cell.selectionStyle = .none
                cell.backgroundColor = .clear
                
                cell.warningImageView.tintColor = .white
                
                cell.noticeLabel.text = NSLocalizedString("LocationsListTVC_AlertNoData", comment: "")
                cell.backgroundColorView.layer.cornerRadius = 5.0
                cell.startAnimationTimer()
                return cell
        }
        
        var weatherData: OWMWeatherDTO?
        var alertNotice: String?
        
        if indexPath.section == 0 {
            if let data = WeatherDataService.shared.singleLocationWeatherData?[indexPath.row] {
                weatherData = data
            } else {
                alertNotice = NSLocalizedString("LocationsListTVC_AlertIncorrectFavoritedCity", comment: "")
            }
        }
        if indexPath.section == 1 {
            if let data = WeatherDataService.shared.multiLocationWeatherData?[indexPath.row] {
                weatherData = data
            } else {
                alertNotice = NSLocalizedString("LocationsListTVC_AlertLocationUnavailable", comment: "")
            }
        }
        
        if let weatherData = weatherData {
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
            
            let weatherConditionSymbol = ConversionService.weatherConditionSymbol(fromWeathercode: weatherData.weatherCondition[0].identifier)
            cell.weatherConditionLabel.text = weatherConditionSymbol
            
            cell.cityNameLabel.text = weatherData.cityName
            
            let temperatureDescriptor = ConversionService.temperatureDescriptor(forTemperatureUnit: WeatherDataService.shared.temperatureUnit, fromRawTemperature: weatherData.atmosphericInformation.temperatureKelvin)
            cell.temperatureLabel.text = "🌡 \(temperatureDescriptor)"
            
            cell.cloudCoverLabel.text = "☁️ \(weatherData.cloudCoverage.coverage)%"
            
            cell.humidityLabel.text = "💧 \(weatherData.atmosphericInformation.humidity)%"
            
            let windspeedDescriptor = ConversionService.windspeedDescriptor(forWindspeedUnit: WeatherDataService.shared.windspeedUnit, forWindspeed: weatherData.windInformation.windspeed)
            cell.windspeedLabel.text = "💨 \(windspeedDescriptor)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            cell.warningImageView.tintColor = .white
            
            cell.noticeLabel.text = alertNotice
            cell.backgroundColorView.layer.cornerRadius = 5.0
            cell.startAnimationTimer()
            return cell
        }
    }
}
