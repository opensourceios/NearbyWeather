//
//  OWMCityFilterTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import PKHUD

class OWMCityFilterTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredCities = [WeatherLocationDTO]()
    
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("OpenWeatherMapCityFilterTVC_NavigationBarTitle", comment: "")
        
        tableView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = NSLocalizedString("OpenWeatherMapCityFilterTVC_SearchBarPlaceholder", comment: "")
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        filteredCities = OWMCityService.shared.openWeatherMapCities
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        tableView.reloadData()
    }
    
    
    // MARK: - TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OWMCityCell", for: indexPath) as! OWMCityCell
        cell.contentLabel.text = "\(filteredCities[indexPath.row].name), \(filteredCities[indexPath.row].country)"
        return cell
    }
    
    
    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        WeatherDataManager.shared.bookmarkedLocation = filteredCities[indexPath.row]
        HUD.flash(.success, delay: 1.0)
        navigationController?.popViewController(animated: true)
    }
    
}

extension OWMCityFilterTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            filteredCities = [WeatherLocationDTO]()
            tableView.reloadData()
            return
        }
        filteredCities = OWMCityService.shared.openWeatherMapCities.filter {
            return $0.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

extension OWMCityFilterTableViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        filteredCities = OWMCityService.shared.openWeatherMapCities
        tableView.reloadData()
    }
}
