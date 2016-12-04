//
//  LocationsListTableViewController.swift
//  SimpleWeather
//
//  Created by Erik Maximilian Martens on 02.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NearbyLocationsTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    //MARK: - Assets
    //Intial (default) location values are set, will be used for loading sample data in case there is no access to the devices location
    private let locationManager = CLLocationManager()
    private var currentLatitude: Double = 49.2525
    private var currentLongitude: Double = 8.2236
    
    static var currentTableView: UITableView!
    static var activityIndicator = UIActivityIndicatorView()
    
    private static var weather: Weather!
    
    //MARK: - Override Functions
    /* General */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up tableView
        NearbyLocationsTableViewController.currentTableView = tableView
        tableView.delegate = self
        self.tableView.estimatedRowHeight = 100
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        //Set up activity indicator
        self.configureActivityIndicator()
        
        //Add refresh via pull down
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: NSLocalizedString("LocationsListTVC_RefreshPullHandle", comment: ""))
        refreshControl?.addTarget(self, action: #selector(NearbyLocationsTableViewController.refreshContent(refreshControl:)), for: UIControlEvents.valueChanged)
        
        //Set up location services
        self.locationManager.requestWhenInUseAuthorization()
        
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            self.triggerLocationAlert()
        }
        else {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //Initalize weather object or load data from persistence store
        //Load any saved events, otherwise load sample data
        if let weather: Weather = loadWeather() {
            NearbyLocationsTableViewController.weather = weather
        }
        else  {
            //Load the Sample Data
            NearbyLocationsTableViewController.weather = Weather(favoritedLocation: "Mannheim")
            
            //Load weather data from server - no local data was stored previously
            NearbyLocationsTableViewController.weather.fetchWeatherForNearbyLocations(for: currentLatitude, for: currentLongitude)
            NearbyLocationsTableViewController.weather.fetchWeatherForFavoritedLocation()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* TableView */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("LocationsListTVC_TableViewSectionHeader1", comment: "")
        case 1:
            return NSLocalizedString("LocationsListTVC_TableViewSectionHeader2", comment: "")
        default:
            //Will never be executed
            return ""
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            //Will return 0 if no data was loaded
            return NearbyLocationsTableViewController.weather.weatherForFavoritedLocation.count
        case 1:
            //Will return 0 if no data was loaded
            return NearbyLocationsTableViewController.weather.weatherForNearbyLocations.count
        default:
            //Will never be executed
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationWeatherCell", for: indexPath) as! LocationWeatherCell
        
        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0)
        
        cell.backgroundColorView.layer.borderWidth = 0
        cell.backgroundColorView.layer.cornerRadius = 5
        cell.backgroundColorView.layer.backgroundColor = UIColor(red: 39/255, green: 214/255, blue: 1, alpha: 1.0).cgColor
        
        cell.cityNameLabel.textColor = UIColor.white
        cell.cityNameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        
        cell.temperatureLabel.textColor = UIColor.white
        cell.temperatureLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        cell.cloudCoverLabel.textColor = UIColor.white
        cell.cloudCoverLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        cell.humidityLabel.textColor = UIColor.white
        cell.humidityLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        cell.windspeedLabel.textColor = UIColor.white
        cell.windspeedLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        switch indexPath.section {
        case 0:
            let weather = (NearbyLocationsTableViewController.weather.weatherForFavoritedLocation[indexPath.row]["weather"]! as! NSArray)[0] as! [String: AnyObject]
            let weatherConditionCode: Int = weather["id"]! as! Int
            let temperatureInUnit: String = convertToTemperatureUnit(rawTemperature: NearbyLocationsTableViewController.weather.weatherForFavoritedLocation[indexPath.row]["main"]!["temp"]!! as! Double)
            
            cell.weatherConditionLabel.text! = determineWeatherConditionSymbol(fromWeathercode: weatherConditionCode)
            cell.cityNameLabel.text! = NearbyLocationsTableViewController.weather.weatherForFavoritedLocation[indexPath.row]["name"]! as! String
            cell.temperatureLabel.text! = "🌡 " + temperatureInUnit
            cell.cloudCoverLabel.text! = "☁️ \(NearbyLocationsTableViewController.weather.weatherForFavoritedLocation[indexPath.row]["clouds"]!["all"]!!)%"
            cell.humidityLabel.text! = "💧 \(NearbyLocationsTableViewController.weather.weatherForFavoritedLocation[indexPath.row]["main"]!["humidity"]!!)%"
            cell.windspeedLabel.text! = "💨 \(NearbyLocationsTableViewController.weather.weatherForFavoritedLocation[indexPath.row]["wind"]!["speed"]!!) km/h"
            
            return cell
        case 1:
            let weather = (NearbyLocationsTableViewController.weather.weatherForNearbyLocations[indexPath.row]["weather"]! as! NSArray)[0] as! [String: AnyObject]
            let weatherConditionCode: Int = weather["id"]! as! Int
            let temperatureInUnit: String = convertToTemperatureUnit(rawTemperature: NearbyLocationsTableViewController.weather.weatherForNearbyLocations[indexPath.row]["main"]!["temp"]!! as! Double)
            
            cell.weatherConditionLabel.text! = determineWeatherConditionSymbol(fromWeathercode: weatherConditionCode)
            cell.cityNameLabel.text! = NearbyLocationsTableViewController.weather.weatherForNearbyLocations[indexPath.row]["name"]! as! String
            cell.temperatureLabel.text! = "🌡 " + temperatureInUnit
            cell.cloudCoverLabel.text! = "☁️ \(NearbyLocationsTableViewController.weather.weatherForNearbyLocations[indexPath.row]["clouds"]!["all"]!!)%"
            cell.humidityLabel.text! = "💧 \(NearbyLocationsTableViewController.weather.weatherForNearbyLocations[indexPath.row]["main"]!["humidity"]!!)%"
            cell.windspeedLabel.text! = "💨 \(NearbyLocationsTableViewController.weather.weatherForNearbyLocations[indexPath.row]["wind"]!["speed"]!!) km/h"
            
            return cell
        default:
            //Will never be executed
            return UITableViewCell()

        }
    }
    
    //MARK: - Helper Functions
    /* General */
    static func storeWeather() {
        _ = NSKeyedArchiver.archiveRootObject(NearbyLocationsTableViewController.weather, toFile: Weather.ArchiveURL.path)
    }
    fileprivate func loadWeather() -> Weather? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Weather.ArchiveURL.path) as? Weather
    }
    fileprivate func determineWeatherConditionSymbol(fromWeathercode: Int) -> String {
        switch fromWeathercode {
        case let x where (x >= 200 && x <= 202) || (x >= 230 && x <= 232):
            return "⛈"
        case let x where x >= 210 && x <= 211:
            return "🌩"
        case let x where x >= 212 && x <= 221:
            return "⚡️"
        case let x where x >= 300 && x <= 321:
            return "🌦"
        case let x where x >= 500 && x <= 531:
            return "🌧"
        case let x where x >= 600 && x <= 622:
            return "🌨"
        case let x where x >= 701 && x <= 771:
            return "🌫"
        case let x where x == 781 || x >= 958:
            return "🌪"
        case let x where x == 800:
            //Simulate day/night mode for clear skies condition -> sunset @ 18:00, sunrise @ 07:00
            let currentDateFormatter: DateFormatter = DateFormatter()
            currentDateFormatter.dateFormat = "ddMMyyyy"
            let currentDateString: String = currentDateFormatter.string(from: Date())
            
            let zeroHourDateFormatter: DateFormatter = DateFormatter()
            zeroHourDateFormatter.dateFormat = "ddMMyyyyHHmmss"
            let zeroHourDate = zeroHourDateFormatter.date(from: (currentDateString + "000000"))!
            
            if Date().timeIntervalSince(zeroHourDate) > 64800 || Date().timeIntervalSince(zeroHourDate) < 25200 {
               return "✨"
            }
            else {
                return "☀️"
            }
        case let x where x == 801:
            return "🌤"
        case let x where x == 802:
            return "⛅️"
        case let x where x == 803:
            return "🌥"
        case let x where x == 804:
            return "☁️"
        case let x where x >= 952 && x <= 958:
            return "💨"
        default:
            return "☀️"
        }
    }
    fileprivate func convertToTemperatureUnit(rawTemperature: Double) -> String {
        switch NearbyLocationsTableViewController.weather.temperatureUnit {
        case .celsius:
            return "\(String(format:"%.02f", rawTemperature - 273.15))°C"
        case . fahrenheit:
            return "\(String(format:"%.02f", rawTemperature * (9/5) - 459.67))°F"
        case .kelvin:
            return "\(String(format:"%.02f", rawTemperature))°K"
        }
    }
    func refreshContent(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        
        //Stop the activity indicator incase a previous one is still running
        NearbyLocationsTableViewController.activityIndicator.stopAnimating()
        
        //Reset previous data
        NearbyLocationsTableViewController.weather.weatherForFavoritedLocation = Array()
        NearbyLocationsTableViewController.weather.weatherForNearbyLocations = Array()
        self.tableView.reloadData()
        
        //Fetch new data
        NearbyLocationsTableViewController.weather.fetchWeatherForNearbyLocations(for: currentLatitude, for: currentLongitude)
        NearbyLocationsTableViewController.weather.fetchWeatherForFavoritedLocation()
        
        refreshControl.endRefreshing()
    }
    fileprivate func configureActivityIndicator() {
        NearbyLocationsTableViewController.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        NearbyLocationsTableViewController.activityIndicator.layer.cornerRadius = 10
        NearbyLocationsTableViewController.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        NearbyLocationsTableViewController.activityIndicator.center = self.view.center
        NearbyLocationsTableViewController.activityIndicator.hidesWhenStopped = true
        NearbyLocationsTableViewController.activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(NearbyLocationsTableViewController.activityIndicator)
    }
    
    /* Alerts */
    fileprivate func triggerLocationAlert() {
        let locationAlert: UIAlertController = UIAlertController(title: NSLocalizedString("LocationsListTVC_LocationAlert_Title", comment: ""), message: NSLocalizedString("LocationsListTVC_LocationAlert_Message", comment: ""), preferredStyle: .alert)
        
        let firstAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_LocationAlert_Action1", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        let secondAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_LocationAlert_Action2", comment: ""), style: UIAlertActionStyle.default, handler: {(paramAction:UIAlertAction!) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:])
        })
        
        locationAlert.addAction(firstAction)
        locationAlert.addAction(secondAction)
        self.present(locationAlert, animated: true, completion: nil)
    }
    fileprivate func triggerSortAlert() {
        let sortAlert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let firstAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        let secondAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Action1", comment: ""), style: UIAlertActionStyle.default, handler: {(paramAction:UIAlertAction!) in
            NearbyLocationsTableViewController.weather.weatherForNearbyLocations.sort() {($0["name"]! as! String) < ($1["name"]! as! String)}
            self.tableView.reloadData()
        })
        let thirdAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Action2", comment: ""), style: UIAlertActionStyle.default, handler: {(paramAction:UIAlertAction!) in
            NearbyLocationsTableViewController.weather.weatherForNearbyLocations.sort() {($0["main"]!["temp"]!! as AnyObject).doubleValue > ($1["main"]!["temp"]!! as AnyObject).doubleValue}
            self.tableView.reloadData()
        })
        
        sortAlert.addAction(firstAction)
        sortAlert.addAction(secondAction)
        sortAlert.addAction(thirdAction)
        self.present(sortAlert, animated: true, completion: nil)
    }
    
    //MARK: Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLatitude = currentLocation.latitude
        self.currentLongitude = currentLocation.longitude
    }
    
    //MARK: - Navigation Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openSettings" {
            let settingsTableViewController = segue.destination as! SettingsTableViewController
            settingsTableViewController.favoritedLocation = NearbyLocationsTableViewController.weather.favoritedLocation
            settingsTableViewController.chosenAmountResults = NearbyLocationsTableViewController.weather.amountResults
            settingsTableViewController.chosenTemperatureUnit = NearbyLocationsTableViewController.weather.temperatureUnit

            let backItem = UIBarButtonItem()
            backItem.title = NSLocalizedString("LocationsListTVC_BackButtonTitle", comment: "")
            navigationItem.backBarButtonItem = backItem
        }
    }
    @IBAction func unwindToNearbyLocationsTableViewController(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SettingsTableViewController, let favoritedLocation = sourceViewController.favoritedLocation, let chosenAmountResults = sourceViewController.chosenAmountResults, let chosenTemperatureUnit = sourceViewController.chosenTemperatureUnit {
            NearbyLocationsTableViewController.weather.favoritedLocation = favoritedLocation
            NearbyLocationsTableViewController.weather.amountResults = chosenAmountResults
            NearbyLocationsTableViewController.weather.temperatureUnit = chosenTemperatureUnit
            
            //Store the user's changes
            NearbyLocationsTableViewController.storeWeather()
            
            //Reload data to reflect new settings
            NearbyLocationsTableViewController.weather.fetchWeatherForNearbyLocations(for: currentLatitude, for: currentLongitude)
            NearbyLocationsTableViewController.weather.fetchWeatherForFavoritedLocation()
        }
    }
    
    //MARK: - Button Interaction
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        self.triggerSortAlert()
    }
}
