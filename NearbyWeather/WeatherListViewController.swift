//
//  WeatherListViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 20.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit
import SafariServices
import RainyRefreshControl

class WeatherListViewController: UIViewController {
    
    // MARK: - Properties
    
    private var refreshControl = RainyRefreshControl()
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separatoLineViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emptyListOverlayContainerView: UIView!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var emptyListTitleLabel: UILabel!
    @IBOutlet weak var emptyListDescriptionLabel: UILabel!
    
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    @IBOutlet weak var reloadButton: UIButton!
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherListViewController.reconfigureOnDidAppBecomeActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherListViewController.reconfigureOnWeatherDataServiceDidUpdate), name: Notification.Name(rawValue: kWeatherServiceDidUpdate), object: nil)
        
        if !WeatherDataManager.shared.hasDisplayableData {
            NotificationCenter.default.addObserver(self, selector: #selector(WeatherListViewController.reconfigureOnNetworkDidBecomeAvailable), name: Notification.Name(rawValue: kNetworkReachabilityChanged), object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: kIsInitialLaunch) == nil {
            UserDefaults.standard.set(false, forKey: kIsInitialLaunch)
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
        navigationController?.navigationBar.styleStandard(withBarTintColor: .nearbyWeatherStandard, isTransluscent: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        configureNavigationTitle()
        configureButtons()
        configureWeatherDataUnavailableElements()
        
        refreshControl.addTarget(self, action: #selector(WeatherListViewController.updateWeatherData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.isHidden = !WeatherDataManager.shared.hasDisplayableData
        emptyListOverlayContainerView.isHidden = WeatherDataManager.shared.hasDisplayableData
        separatoLineViewHeightConstraint.constant = 1/UIScreen.main.scale
    }
    
    @objc private func reconfigureOnDidAppBecomeActive() {
        configureButtons()
    }
    
    @objc private func reconfigureOnWeatherDataServiceDidUpdate() {
        configureNavigationTitle()
        configureButtons()
        tableView.isHidden = !WeatherDataManager.shared.hasDisplayableData
        tableView.reloadData()
    }
    
    @objc private func reconfigureOnNetworkDidBecomeAvailable() {
        UIView.animate(withDuration: 0.5) {
            self.reloadButton.isHidden = NetworkingService.shared.reachabilityStatus != .connected
        }
    }
    
    private func configureWeatherDataUnavailableElements() {
        emptyListImageView.tintColor = .lightGray
        emptyListTitleLabel.text = NSLocalizedString("LocationsListTVC_EmptyListTitle", comment: "")
        emptyListDescriptionLabel.text = NSLocalizedString("LocationsListTVC_EmptyListDescription", comment: "")
    }
    
    private func configureNavigationTitle() {
        let title = "NearbyWeather"
        if let lastRefreshDate = UserDefaults.standard.object(forKey: kWeatherDataLastRefreshDateKey) as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: lastRefreshDate)
            let subtitle = String(format: NSLocalizedString("LocationsListTVC_LastRefresh", comment: ""), dateString)
            navigationItem.setTitle(title, andSubtitle: subtitle)
        } else {
            navigationItem.title = title
        }
    }
    
    private func configureButtons() {
        let weatherDataAvailable = WeatherDataManager.shared.hasDisplayableWeatherData
        
        mapButton.isEnabled = weatherDataAvailable
        mapButton.tintColor = weatherDataAvailable ? .white : .darkGray
        
        settingsButton.tintColor = .white
        
        reloadButton.setTitle(NSLocalizedString("Reload", comment: "").uppercased(), for: .normal)
        reloadButton.setTitleColor(.nearbyWeatherStandard, for: .normal)
        reloadButton.layer.cornerRadius = 5.0
        reloadButton.layer.borderColor = UIColor.nearbyWeatherStandard.cgColor
        reloadButton.layer.borderWidth = 1.0
        
        reloadButton.isHidden = NetworkingService.shared.reachabilityStatus != .connected
    }
    
    @objc private func updateWeatherData() {
        refreshControl.beginRefreshing()
        WeatherDataManager.shared.update(withCompletionHandler: {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }
    
    @objc private func reloadTableView(_ notification: Notification) {
        tableView.reloadData()
    }
    
    
    // MARK: - Button Interaction
    
    @IBAction func didTapSettingsButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SettingsTVC") as! SettingsTableViewController
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.addVerticalCloseButton(withCompletionHandler: nil)
        navigationController?.present(destinationNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func didTapMapButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "NearbyLocationsMapViewController") as! NearbyLocationsMapViewController
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.addVerticalCloseButton(withCompletionHandler: nil)
        navigationController?.present(destinationNavigationController, animated: true, completion: nil)
    }

    @IBAction func didTapReloadButton(_ sender: UIButton) {
        updateWeatherData()
    }
    
    @IBAction func openWeatherMapButtonPressed(_ sender: UIButton) {
        guard let url = URL(string: "https://openweathermap.org") else {
            return
        }
        let safariController = SFSafariViewController(url: url)
        if #available(iOS 10, *) {
            safariController.preferredControlTintColor = .nearbyWeatherStandard
        } else {
            safariController.view.tintColor = .nearbyWeatherStandard
        }
        present(safariController, animated: true, completion: nil)
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
        if !WeatherDataManager.shared.hasDisplayableData
            || WeatherDataManager.shared.apiKeyUnauthorized {
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
        if !WeatherDataManager.shared.hasDisplayableData {
            return 0
        }
        if !LocationService.shared.locationPermissionsGranted
            || WeatherDataManager.shared.bookmarkedWeatherDataObjects == nil
            || WeatherDataManager.shared.nearbyWeatherDataObject == nil
            || WeatherDataManager.shared.apiKeyUnauthorized {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !WeatherDataManager.shared.hasDisplayableData {
            return 0
        }
        if WeatherDataManager.shared.apiKeyUnauthorized {
            return 1
        }
        switch section {
        case 0:
            if WeatherDataManager.shared.bookmarkedWeatherDataObjects == nil {
                return 0
            }
            return WeatherDataManager.shared.bookmarkedWeatherDataObjects?.count ?? 1
        case 1:
            if !LocationService.shared.locationPermissionsGranted {
                return 0
            }
            if WeatherDataManager.shared.nearbyWeatherDataObject == nil {
                return 0
            }
            return WeatherDataManager.shared.nearbyWeatherDataObject?.weatherInformationDTOs?.count ?? 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weatherCell = tableView.dequeueReusableCell(withIdentifier: "WeatherDataCell", for: indexPath) as! WeatherDataCell
        let alertCell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
        
        [weatherCell, alertCell].forEach {
            $0.backgroundColor = .clear
            $0.selectionStyle = .none
        }
        
        if WeatherDataManager.shared.apiKeyUnauthorized {
            let errorDataDTO = (WeatherDataManager.shared.bookmarkedWeatherDataObjects?.first { $0.errorDataDTO != nil})?.errorDataDTO ?? WeatherDataManager.shared.nearbyWeatherDataObject?.errorDataDTO
            alertCell.configureWithErrorDataDTO(errorDataDTO)
            return alertCell
        }
        
        switch indexPath.section {
        case 0:
            guard let weatherDTO = WeatherDataManager.shared.bookmarkedWeatherDataObjects?[indexPath.row].weatherInformationDTO else {
                    alertCell.configureWithErrorDataDTO(WeatherDataManager.shared.bookmarkedWeatherDataObjects?[indexPath.row].errorDataDTO)
                    return alertCell
            }
            weatherCell.configureWithWeatherDTO(weatherDTO)
            return weatherCell
        case 1:
            guard let weatherDTO = WeatherDataManager.shared.nearbyWeatherDataObject?.weatherInformationDTOs?[indexPath.row] else {
                alertCell.configureWithErrorDataDTO(WeatherDataManager.shared.nearbyWeatherDataObject?.errorDataDTO)
                return alertCell
            }
            weatherCell.configureWithWeatherDTO(weatherDTO)
            return weatherCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? WeatherDataCell,
            let weatherDataIdentifier = selectedCell.weatherDataIdentifier else {
                return
        }
        guard let weatherDTO = WeatherDataManager.shared.weatherDTO(forIdentifier: weatherDataIdentifier) else {
            return
        }
        let destinationViewController = WeatherDetailViewController.instantiateFromStoryBoard(withTitle: weatherDTO.cityName, weatherDTO: weatherDTO)
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.addVerticalCloseButton(withCompletionHandler: nil)
        navigationController?.present(destinationNavigationController, animated: true, completion: nil)
    }
}
