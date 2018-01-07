//
//  LocationService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import CoreLocation

let kLocationAuthorizationUpdated = "de.erikmartens.nearbyWeather.locationAuthorizationUpdated"

class LocationService: CLLocationManager, CLLocationManagerDelegate {
    
    // MARK: - Public Assets
    
    public static var shared: LocationService!
    
    public var currentLatitude: Double?
    public var currentLongitude: Double?
    public var authorizationStatus: CLAuthorizationStatus
    
    
    // MARK: - Intialization
    
    private override init() {
        authorizationStatus = CLLocationManager.authorizationStatus()
        super.init()
    }
    
    
    // MARK: - Public Methods
    
    public static func instantiateSharedInstance() {
        // initialize with example data
        shared = LocationService()
        
        LocationService.shared.delegate = LocationService.shared
        LocationService.shared.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        LocationService.shared.startUpdatingLocation()
    }
    
    
    // MARK: - Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            self.currentLatitude = nil
            self.currentLongitude = nil
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: kLocationAuthorizationUpdated), object: self)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocationCoordinate2D = manager.location!.coordinate
        currentLatitude = currentLocation.latitude
        currentLongitude = currentLocation.longitude
    }
}
