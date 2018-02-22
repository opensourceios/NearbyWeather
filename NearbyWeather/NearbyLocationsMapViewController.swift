//
//  NearbyLocationsMapViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 22.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit

class NearbyLocationsMapViewController: UIViewController {
    
    // MARK: - Assets
    
    /* Outlets */
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var focusUserLocationButton: UIBarButtonItem!
    @IBOutlet weak var focusBookmarkedLocationButton: UIBarButtonItem!
    
    
    /* Properties */
    
    var bookmarkedLocations = [CLLocation]()
    var nearbyLocations = [CLLocation]()
    var weatherLocationMapAnnotations: [WeatherLocationMapAnnotation]!
    
    private var previousRegion: MKCoordinateRegion?
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = mapTypeSegmentedControl
        navigationItem.rightBarButtonItems = [focusBookmarkedLocationButton, focusUserLocationButton]
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        prepareMapAnnotations()
        prepareLocations()
        focusOnAvailableLocation()
    }
    
    
    // MARK: - Private Helpers
    
    private func prepareMapAnnotations() {
        weatherLocationMapAnnotations = [WeatherLocationMapAnnotation]()
        
        let bookmarkedLocationAnnotations: [WeatherLocationMapAnnotation]? = WeatherDataManager.shared.bookmarkedWeatherDataObjects?.flatMap {
            guard let weatherDTO = $0.weatherInformationDTO else { return nil }
            return WeatherLocationMapAnnotation(weatherDTO: weatherDTO)
            }
        weatherLocationMapAnnotations.append(contentsOf: bookmarkedLocationAnnotations ?? [WeatherLocationMapAnnotation]())
        
        let nearbyocationAnnotations = WeatherDataManager.shared.nearbyWeatherDataObject?.weatherInformationDTOs?.flatMap {
            return WeatherLocationMapAnnotation(weatherDTO: $0)
        }
        weatherLocationMapAnnotations.append(contentsOf: nearbyocationAnnotations ?? [WeatherLocationMapAnnotation]())
        
        mapView.addAnnotations(weatherLocationMapAnnotations)
    }
    
    private func prepareLocations() {
        let bookmarkedLocations: [CLLocation]? = WeatherDataManager.shared.bookmarkedWeatherDataObjects?.flatMap {
            guard let weatherDTO = $0.weatherInformationDTO else { return nil }
            return CLLocation(latitude: weatherDTO.coordinates.latitude, longitude: weatherDTO.coordinates.longitude)
        }
        self.bookmarkedLocations.append(contentsOf: bookmarkedLocations ?? [CLLocation]())
        
        
        let nearbyLocations = WeatherDataManager.shared.nearbyWeatherDataObject?.weatherInformationDTOs?.flatMap {
            return CLLocation(latitude: $0.coordinates.latitude, longitude: $0.coordinates.longitude)
        }
        self.nearbyLocations.append(contentsOf: nearbyLocations ?? [CLLocation]())
    }
    
    private func focusOnAvailableLocation() {
        if let previousRegion = previousRegion {
            mapView.setRegion(previousRegion, animated: true)
            return
        }
        guard LocationService.shared.locationPermissionsGranted, LocationService.shared.currentLocation != nil else {
            focusMapOnBookmarkedLocation()
            return
        }
        focusMapOnUserLocation()
    }
    
    private func focusMapOnUserLocation() {
        if LocationService.shared.locationPermissionsGranted, let currentLocation = LocationService.shared.currentLocation {
            let region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 15000, 15000)
            mapView.setRegion(region, animated: true)
            focusUserLocationButton.image = UIImage(named: "LocateUserActiveIcon")
        }
    }
    
    private func focusMapOnBookmarkedLocation() {
        let region = MKCoordinateRegionMakeWithDistance(bookmarkedLocations[0].coordinate, 15000, 15000)
        mapView.setRegion(region, animated: true)
        focusBookmarkedLocationButton.image = UIImage(named: "LocateFavoriteActiveIcon")
    }
    
    private func configure() {
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        mapView.mapType = mapTypeSegmentedControl.selectedSegmentIndex == 0 ? .standard : .hybrid
        
        mapTypeSegmentedControl.tintColor = .white
        mapTypeSegmentedControl.setTitle(NSLocalizedString("NearbyLocationsMapVC_MapTypeSegmentedControl_Title_0", comment: ""), forSegmentAt: 0)
        mapTypeSegmentedControl.setTitle(NSLocalizedString("NearbyLocationsMapVC_MapTypeSegmentedControl_Title_1", comment: ""), forSegmentAt: 1)
        
        focusUserLocationButton.tintColor = .white
        
        let locationAvailable = LocationService.shared.locationPermissionsGranted
        focusUserLocationButton.isEnabled = locationAvailable
        focusUserLocationButton.tintColor = locationAvailable ? .white : .gray
        
        focusBookmarkedLocationButton.tintColor = .white
    }
    
    
    // MARK: - IBActions
    
    @IBAction func focusUserLocationButtonTapped(_ sender: UIBarButtonItem) {
        focusMapOnUserLocation()
    }
    
    @IBAction func focusBookmarkedLocationButtonTapped(_ sender: UIBarButtonItem) {
        focusMapOnBookmarkedLocation()
    }
    
    @IBAction func mapTypeSegmentedControlTapped(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
        case 0: mapView.mapType = .standard
        case 1: mapView.mapType = .hybrid
        default: break
        }
    }
}

extension NearbyLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? WeatherLocationMapAnnotation else {
            return nil
        }
        
        var viewForCurrentAnnotation: WeatherLocationMapAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kMapAnnotationViewIdentifier) as? WeatherLocationMapAnnotationView {
            viewForCurrentAnnotation = dequeuedAnnotationView
        } else {
            viewForCurrentAnnotation = WeatherLocationMapAnnotationView(frame: kMapAnnotationViewInitialFrame)
        }
        viewForCurrentAnnotation?.annotation = annotation
        viewForCurrentAnnotation?.configure(withTitle: annotation.title ?? "<Not Set>", subtitle: annotation.subtitle ?? "<Not Set>", fillColor: (annotation.isDayTime ?? true) ? .nearbyWeatherStandard : .nearbyWeatherNight, tapHandler: { [unowned self] sender in
            guard let weatherDTO = WeatherDataManager.shared.weatherDTO(forIdentifier: annotation.locationId) else {
                return
            }
            self.previousRegion = mapView.region
            
            let destinationViewController = WeatherDetailViewController.instantiateFromStoryBoard(withTitle: weatherDTO.cityName, weatherDTO: weatherDTO)
            let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
            destinationNavigationController.addVerticalCloseButton(withCompletionHandler: nil)
            self.navigationController?.present(destinationNavigationController, animated: true, completion: nil)
        })
        return viewForCurrentAnnotation
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        focusUserLocationButton.image = UIImage(named: "LocateUserInactiveIcon")
        focusBookmarkedLocationButton.image = UIImage(named: "LocateFavoriteInactiveIcon")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if LocationService.shared.locationPermissionsGranted,
            let currentLocation = LocationService.shared.currentLocation,
            mapView.region.center.latitude == currentLocation.coordinate.latitude
                && mapView.region.center.longitude == currentLocation.coordinate.longitude {
            focusUserLocationButton.image = UIImage(named: "LocateUserActiveIcon")
        }
        if mapView.region.center.latitude == bookmarkedLocations[0].coordinate.latitude
            && mapView.region.center.longitude == bookmarkedLocations[0].coordinate.longitude {
            focusBookmarkedLocationButton.image = UIImage(named: "LocateFavoriteActiveIcon")
        }
    }
}
