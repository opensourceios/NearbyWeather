//
//  Weather.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class Weather: NSObject, NSCoding {
    
    //MARK: - Assets
    private static let openWeather_SingleLocationBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private static let openWeather_MultiLocationBaseURL = "http://api.openweathermap.org/data/2.5/find"
    private static let openWeatherMapAPIKey = "4d49c9e06157e2ef4d84ec35bf1f3779"
    
    //MARK: - Properties
    var temperatureUnit: TemperatureUnit
    var favoritedLocation: String
    var amountResults: Int
    var weatherForFavoritedLocation: [[String: AnyObject]]
    var weatherForNearbyLocations: [[String: AnyObject]]
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("NearbyWeatherData")
    
    //MARK: - Initialization
    init?(favoritedLocation: String) {
        
        //Initialize stored properties
        self.temperatureUnit = .celsius
        self.favoritedLocation = favoritedLocation
        self.amountResults = 10
        self.weatherForFavoritedLocation = Array()
        self.weatherForNearbyLocations = Array()
        
        super.init()
        
        // Initialization should fail if there is no favorited location set
        if favoritedLocation.isEmpty {
            return nil
        }
    }
    
    //MARK: - Public Methods
    func fetchWeatherForFavoritedLocation() {
        //Reset previous data
        weatherForFavoritedLocation = Array()
        
        //Start Activity Indicator (first load action to be called)
        NearbyLocationsTableViewController.activityIndicator.startAnimating()
        
        //Fetch new data
        let session = URLSession.shared
        
        let requestedCity: String = self.favoritedLocation.replacingOccurrences(of: " ", with: "")
        let requestURL = NSMutableURLRequest(url: URL(string: "\(Weather.openWeather_SingleLocationBaseURL)?APPID=\(Weather.openWeatherMapAPIKey)&q=\(requestedCity)")!)
        
        let request = session.dataTask(with: requestURL as URLRequest, completionHandler: {
            (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response  , error == nil else {
                return
            }
            //let dataString = String(data: data!, encoding: String.Encoding.utf8)
            //print("Clear Text Data:\n\(dataString!)")
            self.extractSingleLocation(json: data!)
        })
        request.resume()
    }
    func fetchWeatherForNearbyLocations(for latitude: Double, for longitude: Double) {
        //Reset previous data
        weatherForNearbyLocations = Array()
        
        //Fetch new data
        let session = URLSession.shared
        
        let requestURL = NSMutableURLRequest(url: URL(string: "\(Weather.openWeather_MultiLocationBaseURL)?APPID=\(Weather.openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)&cnt=\(amountResults)")!)
        
        let request = session.dataTask(with: requestURL as URLRequest, completionHandler: {
            (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response  , error == nil else {
                return
            }
            //let dataString = String(data: data!, encoding: String.Encoding.utf8)
            //print("Clear Text Data:\n\(dataString!)")
            self.extractMultiLocation(json: data!)
        })
        request.resume()
    }
    
    //MARK: - Private Helper Methods
    fileprivate func extractSingleLocation(json: Data) {
        do {
            let externalWeatherData = try JSONSerialization.jsonObject(with: json, options: .mutableContainers) as! [String: AnyObject]
            
            self.weatherForFavoritedLocation.append(externalWeatherData)
        }
        catch let jsonError as NSError {
            print("JSON error description: \(jsonError.description)")
            return
        }
        DispatchQueue.main.async(execute: {
            
            NearbyLocationsTableViewController.currentTableView.reloadData()
        })
    }
    fileprivate func extractMultiLocation(json: Data) {
        do {
            let externalWeatherData = try JSONSerialization.jsonObject(with: json, options: .mutableContainers) as! [String: AnyObject]
            
            for i in 0..<externalWeatherData["list"]!.count {
                self.weatherForNearbyLocations.append((externalWeatherData["list"]! as! NSArray)[i] as! [String: AnyObject])
            }
        }
        catch let jsonError as NSError {
            print("JSON error description: \(jsonError.description)")
            return
        }
        //Last action to be done in the cycle before displaying all loaded data
        DispatchQueue.main.async(execute: {
            NearbyLocationsTableViewController.storeWeather()
            
            //Stop the activity indicator
            NearbyLocationsTableViewController.activityIndicator.stopAnimating()
            
            NearbyLocationsTableViewController.currentTableView.reloadData()
        })
    }
    
    
    //MARK: - Types
    struct PropertyKey {
        static let temperatureUnitKey = "temperatureUnit"
        static let favoritedLocationKey = "favoritedLocation"
        static let amountResultsKey = "chosenAmountResults"
        static let favoritedLocationWeatherKey = "weatherForFavoritedLocation"
        static let nearbyLocationsWeatherKey = "weatherForNearbyLocations"
    }
    
    //MARK: - NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(temperatureUnit.rawValue, forKey: PropertyKey.temperatureUnitKey)
        aCoder.encode(favoritedLocation, forKey: PropertyKey.favoritedLocationKey)
        aCoder.encode(amountResults, forKey: PropertyKey.amountResultsKey)
        aCoder.encode(weatherForFavoritedLocation, forKey: PropertyKey.favoritedLocationWeatherKey)
        aCoder.encode(weatherForNearbyLocations, forKey: PropertyKey.nearbyLocationsWeatherKey)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let unit = aDecoder.decodeObject(forKey: PropertyKey.temperatureUnitKey) as! String
        let favorite = aDecoder.decodeObject(forKey: PropertyKey.favoritedLocationKey) as! String
        let amount = aDecoder.decodeInteger(forKey: PropertyKey.amountResultsKey)
        let weatherFavoriteLocation = aDecoder.decodeObject(forKey: PropertyKey.favoritedLocationWeatherKey) as! [[String: AnyObject]]
        let weatherNearbyLocations = aDecoder.decodeObject(forKey: PropertyKey.nearbyLocationsWeatherKey) as! [[String: AnyObject]]
        
        //Must call designated initilizer
        self.init(favoritedLocation: favorite)
        self.temperatureUnit = TemperatureUnit(rawValue: unit)!
        self.amountResults = amount
        self.weatherForFavoritedLocation = weatherFavoriteLocation
        self.weatherForNearbyLocations = weatherNearbyLocations
    }
}
