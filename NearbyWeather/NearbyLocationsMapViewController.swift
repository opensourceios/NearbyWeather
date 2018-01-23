//
//  NearbyLocationsMapViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 22.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit

private let kMapAnnotationIdentifier = "de.nearbyWeather.mkAnnotation"

class WeatherLocationMapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(weatherDTO: OWMWeatherDTO) {
        let temperatureDescriptor = ConversionService.temperatureDescriptor(forTemperatureUnit: WeatherDataService.shared.temperatureUnit, fromRawTemperature: weatherDTO.atmosphericInformation.temperatureKelvin)
        let weatherCondition = weatherDTO.weatherCondition.first?.conditionName ?? "<unavailable>"
        let lat = weatherDTO.coordinates.latitude
        let lon = weatherDTO.coordinates.longitude
        
        title = weatherDTO.cityName
        subtitle = "\(temperatureDescriptor), \(weatherCondition)"
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

class NearbyLocationsMapViewController: UIViewController {
    
    // MARK: - Assets
    
    /* Outlets */
    
    @IBOutlet weak var mapView: MKMapView!
    
    /* Properties */
    
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
    }
    
    
    // MARK: - Private Helpers
    
    private func prepareMapAnnotations() {
        
        let singleLocationAnnotations = WeatherDataService.shared.singleLocationWeatherData?.flatMap {
            return WeatherLocationMapAnnotation(weatherDTO: $0)
        }
        let multiLocationAnnotations = WeatherDataService.shared.multiLocationWeatherData?.flatMap {
            return WeatherLocationMapAnnotation(weatherDTO: $0)
        }
        
        weatherLocationMapAnnotations = [WeatherLocationMapAnnotation]()
        weatherLocationMapAnnotations.append(contentsOf: singleLocationAnnotations ?? [WeatherLocationMapAnnotation]())
        weatherLocationMapAnnotations.append(contentsOf: multiLocationAnnotations ?? [WeatherLocationMapAnnotation]())
        
        mapView.addAnnotations(weatherLocationMapAnnotations)
    }
    
    private func configure() {
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
    }
}

extension NearbyLocationsMapViewController: MKMapViewDelegate {
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? WeatherLocationMapAnnotation else {
//            return nil
//        }
//        var viewForCurrentAnnotation: MKAnnotationView?
//        if let dequeuedAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: kMapAnnotationIdentifier) {
//            dequeuedAnnotation.annotation = annotation
//            viewForCurrentAnnotation = dequeuedAnnotation
//        } else {
//            viewForCurrentAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: kMapAnnotationIdentifier)
//            viewForCurrentAnnotation?.canShowCallout = true
//            viewForCurrentAnnotation?.calloutOffset = CGPoint(x: -5, y: 5)
//        }
//        return viewForCurrentAnnotation
//    }
}
