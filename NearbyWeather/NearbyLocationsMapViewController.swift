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
    
    @IBOutlet weak var buttonRowContainerView: UIView!
    @IBOutlet weak var buttonRowStackView: UIStackView!
    
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var focusUserLocationButton: UIButton!
    @IBOutlet weak var focusBookmarkedLocationButton: UIButton!
    
    
    /* Properties */
    
    var bookmarkedLocation: CLLocation!
    var weatherLocations: [CLLocation]!
    var weatherLocationMapAnnotations: [WeatherLocationMapAnnotation]!
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("NearbyLocationsMapVC_NavigationItemTitle", comment: "")
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        prepareMapAnnotations()
        prepareLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        focusOnAvailableLocation()
    }
    
    
    // MARK: - Private Helpers
    
    private func prepareMapAnnotations() {
        weatherLocationMapAnnotations = [WeatherLocationMapAnnotation]()
        
        if let singleLocationAnnotations = WeatherLocationMapAnnotation(weatherDTO: WeatherDataManager.shared.singleLocationWeatherData?.weatherDataDTO) {
            weatherLocationMapAnnotations.append(singleLocationAnnotations)
        }
        
        let multiLocationAnnotations = WeatherDataManager.shared.multiLocationWeatherData?.weatherDataDTOs?.flatMap {
            return WeatherLocationMapAnnotation(weatherDTO: $0)
        }
        weatherLocationMapAnnotations.append(contentsOf: multiLocationAnnotations ?? [WeatherLocationMapAnnotation]())
        
        mapView.addAnnotations(weatherLocationMapAnnotations)
    }
    
    private func prepareLocations() {
        weatherLocations = [CLLocation]()
        
        if let singleLocationWeatherDTO = WeatherDataManager.shared.singleLocationWeatherData?.weatherDataDTO {
            let location = CLLocation(latitude: singleLocationWeatherDTO.coordinates.latitude, longitude: singleLocationWeatherDTO.coordinates.longitude)
            weatherLocations.append(location)
            bookmarkedLocation = location
        }
        
        let multiLocations = WeatherDataManager.shared.multiLocationWeatherData?.weatherDataDTOs?.flatMap {
            return CLLocation(latitude: $0.coordinates.latitude, longitude: $0.coordinates.longitude)
        }
        weatherLocations.append(contentsOf: multiLocations ?? [CLLocation]())
    }
    
    private func focusOnAvailableLocation() {
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
            focusUserLocationButton.setImage(UIImage(named: "LocateUserActiveIcon"), for: .normal)
        }
    }
    private func focusMapOnBookmarkedLocation() {
        let region = MKCoordinateRegionMakeWithDistance(bookmarkedLocation.coordinate, 15000, 15000)
        mapView.setRegion(region, animated: true)
        focusBookmarkedLocationButton.setImage(UIImage(named: "LocateFavoriteActiveIcon"), for: .normal)
    }
    
    private func configure() {
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        mapView.mapType = .standard
        
        buttonRowContainerView.layer.cornerRadius = 10
        buttonRowContainerView.layer.backgroundColor = UIColor.nearbyWeatherStandard.cgColor
        buttonRowContainerView.addDropShadow(radius: 10)
        
        buttonRowContainerView.bringSubview(toFront: buttonRowStackView)
        
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
    
    @IBAction func focusUserLocationButtonTapped(_ sender: UIButton) {
        focusMapOnUserLocation()
    }
    
    @IBAction func focusBookmarkedLocationButtonTapped(_ sender: UIButton) {
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
        viewForCurrentAnnotation?.configure(withTitle: annotation.title ?? "<Not Set>", subtitle: annotation.subtitle ?? "<Not Set>", tapHandler: nil)
    
        return viewForCurrentAnnotation
        
//        if #available(iOS 11, *) {
//            var viewForCurrentAnnotation: MKMarkerAnnotationView?
//            if let dequeuedAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: kMapAnnotationIdentifier) as? MKMarkerAnnotationView {
//                dequeuedAnnotation.annotation = annotation
//                viewForCurrentAnnotation = dequeuedAnnotation
//            } else {
//                viewForCurrentAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: kMapAnnotationIdentifier)
//                viewForCurrentAnnotation?.canShowCallout = true
//                viewForCurrentAnnotation?.calloutOffset = CGPoint(x: -5, y: 5)
//            }
//            return viewForCurrentAnnotation
//        } else {
//            var viewForCurrentAnnotation: MKAnnotationView?
//            if let dequeuedAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: kMapAnnotationIdentifier) {
//                dequeuedAnnotation.annotation = annotation
//                viewForCurrentAnnotation = dequeuedAnnotation
//            } else {
//                viewForCurrentAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: kMapAnnotationIdentifier)
//                viewForCurrentAnnotation?.canShowCallout = true
//                viewForCurrentAnnotation?.calloutOffset = CGPoint(x: -5, y: 5)
//            }
//            return viewForCurrentAnnotation
//        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        focusUserLocationButton.setImage(UIImage(named: "LocateUserInactiveIcon"), for: .normal)
        focusBookmarkedLocationButton.setImage(UIImage(named: "LocateFavoriteInactiveIcon"), for: .normal)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if LocationService.shared.locationPermissionsGranted,
            let currentLocation = LocationService.shared.currentLocation,
            mapView.region.center.latitude == currentLocation.coordinate.latitude
                && mapView.region.center.longitude == currentLocation.coordinate.longitude {
            focusUserLocationButton.setImage(UIImage(named: "LocateUserActiveIcon"), for: .normal)
        }
        if mapView.region.center.latitude == bookmarkedLocation.coordinate.latitude
            && mapView.region.center.longitude == bookmarkedLocation.coordinate.longitude {
            focusBookmarkedLocationButton.setImage(UIImage(named: "LocateFavoriteActiveIcon"), for: .normal)
        }
    }
}
