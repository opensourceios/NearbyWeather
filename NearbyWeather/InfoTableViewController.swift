//
//  InfoTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {
    //MARK: - Assets
    
    /* Labels */
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    @IBOutlet weak var legendEntryLabel_1: UILabel!
    @IBOutlet weak var legendEntryLabel_2: UILabel!
    @IBOutlet weak var legendEntryLabel_3: UILabel!
    @IBOutlet weak var legendEntryLabel_4: UILabel!
    
    
    @IBOutlet weak var supportNoteLabel: UILabel!
    @IBOutlet weak var supportAddressLabel: UILabel!
    
    @IBOutlet weak var sourceNoteLabel: UILabel!
    @IBOutlet weak var sourceAddressLabel: UILabel!
    
    @IBOutlet weak var developerName_0: UILabel!
    
    
    //MARK: - Override Functions
    
    /* View */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("InfoTVC_NavigationItemTitle", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InfoTableViewController.didTapDoneButton(_:)))
        
        tableView.delegate = self
        
        configureText()
        
        tableView.estimatedRowHeight = 61
        tableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(InfoTableViewController.preferredTextSizeChanged(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    /* TableView */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 && indexPath.row == 0 {
            UIApplication.shared.open(URL(string: "http://www.erikmartens.de/nearby-weather.html")!, options: [:], completionHandler: nil)
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            UIApplication.shared.open(URL(string: "https://github.com/erikmartens/NearbyWeather")!, options: [:], completionHandler: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return NSLocalizedString("InfoTVC_TableViewSectionHeader2", comment: "")
        case 2: return NSLocalizedString("InfoTVC_TableViewSectionHeader3", comment: "")
        case 3: return NSLocalizedString("InfoTVC_TableViewSectionHeader4", comment: "")
        default: return nil
        }
    }
    
    /* Deinitializer */
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Handle NSNotification
    
    @objc func preferredTextSizeChanged(_ notification: Notification) {
        configureText()
        tableView.reloadSections(IndexSet(integer: 0), with: .none)
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        tableView.reloadSections(IndexSet(integer: 2), with: .none)
        tableView.reloadSections(IndexSet(integer: 3), with: .none)
    }
    
    
    // MARK: - Interface Setup
    
    private func configureText() {
        appTitleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        appTitleLabel.text! = NSLocalizedString("InfoTVC_AppTitle", comment: "")
        
        legendEntryLabel_1.font = UIFont.preferredFont(forTextStyle: .subheadline)
        legendEntryLabel_1.text! = NSLocalizedString("InfoTVC_Legend_Temperature", comment: "")
        legendEntryLabel_2.font = UIFont.preferredFont(forTextStyle: .subheadline)
        legendEntryLabel_2.text! = NSLocalizedString("InfoTVC_Legend_CloudCover", comment: "")
        legendEntryLabel_3.font = UIFont.preferredFont(forTextStyle: .subheadline)
        legendEntryLabel_3.text! = NSLocalizedString("InfoTVC_Legend_Humidity", comment: "")
        legendEntryLabel_4.font = UIFont.preferredFont(forTextStyle: .subheadline)
        legendEntryLabel_4.text! = NSLocalizedString("InfoTVC_Legend_WindSpeed", comment: "")
        
        
        appVersionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        appVersionLabel.text! = NSLocalizedString("InfoTVC_AppVersion", comment: "")
        
        supportNoteLabel.font = UIFont.preferredFont(forTextStyle: .body)
        supportNoteLabel.text! = NSLocalizedString("InfoTVC_Support", comment: "")
        
        supportAddressLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        sourceNoteLabel.font = UIFont.preferredFont(forTextStyle: .body)
        sourceNoteLabel.text! = NSLocalizedString("InfoTVC_Source", comment: "")
        
        sourceAddressLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        developerName_0.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    
    // MARK: - Button Interaction
    
    @objc private func didTapDoneButton(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
