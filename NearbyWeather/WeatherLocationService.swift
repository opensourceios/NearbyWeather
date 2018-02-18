//
//  OpenWeatherMapCityService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import FMDB

class WeatherLocationService {
    
    // MARK: - Public Assets
    
    public static var shared: WeatherLocationService!
    
    
    // MARK: - Private Assets
    
    private let openWeatherMapCityServiceBackgroundQueue = DispatchQueue(label: "de.erikmaximilianmartens.nearbyWeather.openWeatherMapCityService", qos: DispatchQoS.background, attributes: [DispatchQueue.Attributes.concurrent], autoreleaseFrequency: .inherit, target: nil)
    
    fileprivate let databaseQueue: FMDatabaseQueue
    
    
    // MARK: - Initialization
    
    private init() {
        let sqliteFilePath = Bundle.main.path(forResource: "locationsSQLite", ofType: "sqlite")! // crash app if not found, cannot run without db
        self.databaseQueue = FMDatabaseQueue(path: sqliteFilePath)
    }
    
    // MARK: - Public Properties & Methods
    
    public static func instantiateSharedInstance() {
        shared = WeatherLocationService()
    }
    
    public func locations(forSearchString searchString: String, completionHandler: @escaping (([WeatherLocationDTO]?)->())) {
        
        if searchString.count == 0 || searchString == "" { return completionHandler(nil) }
        
        databaseQueue.inDatabase { database in
            
            let query = "SELECT * FROM locations WHERE (lower(name) LIKE '%\(searchString.lowercased())%')"
            var queryResult: FMResultSet?
            
            do {
                queryResult = try database.executeQuery(query, values: nil)
            } catch {
                print(error.localizedDescription)
                return completionHandler(nil)
            }
            
            guard let result = queryResult else {
                completionHandler(nil)
                return
            }
            
            var retrievedLocations = [WeatherLocationDTO]()
            while result.next() {
                guard let location = WeatherLocationDTO(from: result) else {
                    return
                }
                retrievedLocations.append(location)
            }
            
            guard !retrievedLocations.isEmpty else {
                return completionHandler(nil)
            }
            completionHandler(retrievedLocations)
        }
    }
}
