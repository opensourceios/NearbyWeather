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
    
    @IBOutlet weak var legendEntryLabel_1: UILabel!
    @IBOutlet weak var legendEntryLabel_2: UILabel!
    @IBOutlet weak var legendEntryLabel_3: UILabel!
    @IBOutlet weak var legendEntryLabel_4: UILabel!
    
    
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
        legendEntryLabel_1.font = UIFont.preferredFont(forTextStyle: .subheadline)
        legendEntryLabel_1.text! = NSLocalizedString("InfoTVC_Legend_Temperature", comment: "")
        legendEntryLabel_2.font = UIFont.preferredFont(forTextStyle: .subheadline)
        legendEntryLabel_2.text! = NSLocalizedString("InfoTVC_Legend_CloudCover", comment: "")
        legendEntryLabel_3.font = UIFont.preferredFont(forTextStyle: .subheadline)
        legendEntryLabel_3.text! = NSLocalizedString("InfoTVC_Legend_Humidity", comment: "")
        legendEntryLabel_4.font = UIFont.preferredFont(forTextStyle: .subheadline)
        legendEntryLabel_4.text! = NSLocalizedString("InfoTVC_Legend_WindSpeed", comment: "")
    }
}
