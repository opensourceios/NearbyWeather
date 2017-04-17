//
//  LocationService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import CoreLocation

class LocationService: CLLocationManager, CLLocationManagerDelegate {
    
    // MARK: - Assets
    
    public static var current: LocationService!
    
    public var currentLatitude: Double
    public var currentLongitude: Double
    public var authorizationStatus: CLAuthorizationStatus
    
    
    // MARK: - Intialization
    
    private init(withLocation latitude: Double, longitude: Double) {
        currentLatitude = latitude
        currentLongitude = longitude
        authorizationStatus = CLLocationManager.authorizationStatus()
        super.init()
    }
    
    
    // MARK: - Public Methods
    
    public static func initializeService() {
        // initialize with example data
        current = LocationService(withLocation: 37.3318598, longitude: -122.0302485)
        
        LocationService.current.delegate = LocationService.current
        LocationService.current.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        LocationService.current.startUpdatingLocation()
    }
    
    
    // MARK: - Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.locationAuthorizationUpdated.rawValue), object: self)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocationCoordinate2D = manager.location!.coordinate
        //currentLatitude = currentLocation.latitude
        //currentLongitude = currentLocation.longitude
    }
}
