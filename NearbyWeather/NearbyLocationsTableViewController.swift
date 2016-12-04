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
    
    private var chosenAmountResults: Int = 10
    private var chosenTemperatureUnit: TemperatureUnit = .celsius
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/find"
    private let openWeatherMapAPIKey = "4d49c9e06157e2ef4d84ec35bf1f3779"
    private var weatherForNearbyLocations: [[String: AnyObject]] = Array()
    
    private var indicator = UIActivityIndicatorView()
    
    //MARK: - Override Functions
    /* General */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up tableView
        tableView.delegate = self
        self.tableView.estimatedRowHeight = 100
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
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
    
        //Load weather data
        self.fetchWeatherForNearbyLocations()
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
        return ""
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherForNearbyLocations.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyLocationCell", for: indexPath) as! NearbyLocationCell
        
        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0)
        
        cell.backgroundColorView.layer.borderWidth = 0
        cell.backgroundColorView.layer.cornerRadius = 5
        cell.backgroundColorView.layer.backgroundColor = UIColor(red: 39/255, green: 214/255, blue: 1, alpha: 1.0).cgColor
        
        let weather = (weatherForNearbyLocations[indexPath.row]["weather"]! as! NSArray)[0] as! [String: AnyObject]
        let weatherConditionCode: Int = weather["id"]! as! Int
        cell.weatherConditionLabel.text! = determineWeatherConditionSymbol(fromWeathercode: weatherConditionCode)
        
        cell.cityNameLabel.textColor = UIColor.white
        cell.cityNameLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.cityNameLabel.text! = weatherForNearbyLocations[indexPath.row]["name"]! as! String
        
        cell.temperatureLabel.textColor = UIColor.white
        cell.temperatureLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        let temperatureInUnit: String = convertToTemperatureUnit(rawTemperature: weatherForNearbyLocations[indexPath.row]["main"]!["temp"]!! as! Double)
        cell.temperatureLabel.text! = "🌡 " + temperatureInUnit
        
        cell.cloudCoverLabel.textColor = UIColor.white
        cell.cloudCoverLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        cell.cloudCoverLabel.text! = "☁️ \(weatherForNearbyLocations[indexPath.row]["clouds"]!["all"]!!)%"
        
        cell.humidityLabel.textColor = UIColor.white
        cell.humidityLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        cell.humidityLabel.text! = "💧 \(weatherForNearbyLocations[indexPath.row]["main"]!["humidity"]!!)%"
        
        cell.windspeedLabel.textColor = UIColor.white
        cell.windspeedLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        cell.windspeedLabel.text! = "💨 \(weatherForNearbyLocations[indexPath.row]["wind"]!["speed"]!!) km/h"
        
        return cell
    }
    
    //MARK: - Helper Functions
    /* General */
    fileprivate func fetchWeatherForNearbyLocations() {
        //Reset previous data
        weatherForNearbyLocations = Array()
        
        //Start Activity Indicator
        self.showActivityIndicator()
        
        //Fetch new data
        let session = URLSession.shared
        
        let requestURL = NSMutableURLRequest(url: URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(currentLatitude)&lon=\(currentLongitude)&cnt=\(chosenAmountResults)")!)
        
        let request = session.dataTask(with: requestURL as URLRequest, completionHandler: {
            (data, response, error) in
                guard let _: Data = data, let _: URLResponse = response  , error == nil else {
                    return
                }
            //let dataString = String(data: data!, encoding: String.Encoding.utf8)
            //print("Clear Text Data:\n\(dataString!)")
            self.extract(json: data!)
        })
        request.resume()
    }
    fileprivate func extract(json: Data) {
        do {
            let externalWeatherData = try JSONSerialization.jsonObject(with: json, options: .mutableContainers) as! [String: AnyObject]
            
            for i in 0..<externalWeatherData["list"]!.count {
                weatherForNearbyLocations.append((externalWeatherData["list"]! as! NSArray)[i] as! [String: AnyObject])
            }
        }
        catch let jsonError as NSError {
            print("JSON error description: \(jsonError.description)")
            return
        }
        DispatchQueue.main.async(execute: {
            //Stop the activity indicator
            self.indicator.stopAnimating()
            
            self.tableView.reloadData()
        })
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
            //Simulate day/night mode for clear skies condition -> sunset @ 18:00
            let currentDateFormatter: DateFormatter = DateFormatter()
            currentDateFormatter.dateFormat = "ddMMyyyy"
            let currentDateString: String = currentDateFormatter.string(from: Date())
            
            let zeroHourDateFormatter: DateFormatter = DateFormatter()
            zeroHourDateFormatter.dateFormat = "ddMMyyyyHHmmss"
            let zeroHourDate = zeroHourDateFormatter.date(from: (currentDateString + "000000"))!
            
            if Date().timeIntervalSince(zeroHourDate) > 64800 {
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
        switch chosenTemperatureUnit {
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
        self.indicator.stopAnimating()
        
        //Reset previous data
        weatherForNearbyLocations = Array()
        self.tableView.reloadData()
        
        //Fetch new data
        self.fetchWeatherForNearbyLocations()
        
        refreshControl.endRefreshing()
    }
    fileprivate func showActivityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicator.layer.cornerRadius = 10
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.view.addSubview(indicator)
        
        indicator.startAnimating()
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
            self.weatherForNearbyLocations.sort() {($0["name"]! as! String) < ($1["name"]! as! String)}
            self.tableView.reloadData()
        })
        let thirdAction = UIAlertAction(title: NSLocalizedString("LocationsListTVC_SortAlert_Action2", comment: ""), style: UIAlertActionStyle.default, handler: {(paramAction:UIAlertAction!) in
            self.weatherForNearbyLocations.sort() {($0["main"]!["temp"]!! as AnyObject).doubleValue > ($1["main"]!["temp"]!! as AnyObject).doubleValue}
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
            settingsTableViewController.chosenAmountResults = chosenAmountResults
            settingsTableViewController.chosenTemperatureUnit = chosenTemperatureUnit

            let backItem = UIBarButtonItem()
            backItem.title = NSLocalizedString("LocationsListTVC_BackButtonTitle", comment: "")
            navigationItem.backBarButtonItem = backItem
        }
    }
    @IBAction func unwindToNearbyLocationsTableViewController(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SettingsTableViewController, let chosenAmountResults = sourceViewController.chosenAmountResults, let chosenTemperatureUnit = sourceViewController.chosenTemperatureUnit {
            self.chosenAmountResults = chosenAmountResults
            self.chosenTemperatureUnit = chosenTemperatureUnit
            
            //Reload data to reflect new settings
            self.fetchWeatherForNearbyLocations()
        }
    }
    
    //MARK: - Button Interaction
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        self.triggerSortAlert()
    }
}
