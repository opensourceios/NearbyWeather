//
//  HelpTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class HelpTableViewController: UITableViewController {
    
    // MARK: - Assets
    
    @IBOutlet weak var weatherConditionLabel_0: UILabel!
    @IBOutlet weak var weatherConditionLabel_1: UILabel!
    @IBOutlet weak var weatherConditionLabel_2: UILabel!
    @IBOutlet weak var weatherConditionLabel_3: UILabel!
    @IBOutlet weak var weatherConditionLabel_4: UILabel!
    @IBOutlet weak var weatherConditionLabel_5: UILabel!
    @IBOutlet weak var weatherConditionLabel_6: UILabel!
    @IBOutlet weak var weatherConditionLabel_7: UILabel!
    @IBOutlet weak var weatherConditionLabel_8: UILabel!
    @IBOutlet weak var weatherConditionLabel_9: UILabel!
    @IBOutlet weak var weatherConditionLabel_10: UILabel!
    @IBOutlet weak var weatherConditionLabel_11: UILabel!
    @IBOutlet weak var weatherConditionLabel_12: UILabel!
    @IBOutlet weak var weatherConditionLabel_13: UILabel!
    @IBOutlet weak var weatherConditionLabel_14: UILabel!
    
    @IBOutlet weak var weatherDataEntryLabel_0: UILabel!
    @IBOutlet weak var weatherDataEntryLabel_1: UILabel!
    @IBOutlet weak var weatherDataEntryLabel_2: UILabel!
    @IBOutlet weak var weatherDataEntryLabel_3: UILabel!
    
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("HelpTVC_NavigationItemTitle", comment: "")
        
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        tableView.reloadData() // in case of preferred content size change
    }
    
    
    // MARK: - TableView Data Source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("InfoTVC_TableViewSectionHeader0", comment: "")
        case 1: return NSLocalizedString("InfoTVC_TableViewSectionHeader1", comment: "")
        default: return nil
        }
    }
    
    
    // MARK: - Private Helpers
    
    private func configure() {
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        configureText()
    }
    
    private func configureText() {
        weatherConditionLabel_0.text = NSLocalizedString("HelpTVC_Legend_Thunderstorm", comment: "")
        weatherConditionLabel_1.text = NSLocalizedString("HelpTVC_Legend_ThunderstormWithRain", comment: "")
        weatherConditionLabel_2.text = NSLocalizedString("HelpTVC_Legend_HeavyThunderstorm", comment: "")
        weatherConditionLabel_3.text = NSLocalizedString("HelpTVC_Legend_Drizzle", comment: "")
        weatherConditionLabel_4.text = NSLocalizedString("HelpTVC_Legend_Rain", comment: "")
        weatherConditionLabel_5.text = NSLocalizedString("HelpTVC_Legend_Atmosphere", comment: "")
        weatherConditionLabel_6.text = NSLocalizedString("HelpTVC_Legend_HeavyStorm", comment: "")
        weatherConditionLabel_7.text = NSLocalizedString("HelpTVC_Legend_SunnyClear", comment: "")
        weatherConditionLabel_8.text = NSLocalizedString("HelpTVC_Legend_FewClouds", comment: "")
        weatherConditionLabel_9.text = NSLocalizedString("HelpTVC_Legend_ScatteredClouds", comment: "")
        weatherConditionLabel_10.text = NSLocalizedString("HelpTVC_Legend_BrokenClouds", comment: "")
        weatherConditionLabel_11.text = NSLocalizedString("HelpTVC_Legend_OvercastClouds", comment: "")
        weatherConditionLabel_12.text = NSLocalizedString("HelpTVC_Legend_Breeze", comment: "")
        weatherConditionLabel_13.text = NSLocalizedString("HelpTVC_Legend_Snow", comment: "")
        weatherConditionLabel_14.text = NSLocalizedString("HelpTVC_Legend_SnowAndRain", comment: "")
        
        weatherDataEntryLabel_0.text = NSLocalizedString("InfoTVC_Legend_Temperature", comment: "")
        weatherDataEntryLabel_1.text = NSLocalizedString("InfoTVC_Legend_CloudCover", comment: "")
        weatherDataEntryLabel_2.text = NSLocalizedString("InfoTVC_Legend_Humidity", comment: "")
        weatherDataEntryLabel_3.text = NSLocalizedString("InfoTVC_Legend_WindSpeed", comment: "")
    }
}
