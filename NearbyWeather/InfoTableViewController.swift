//
//  InfoTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import SafariServices

class InfoTableViewController: UITableViewController {
    
    //MARK: - Assets

    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    @IBOutlet weak var supportNoteLabel: UILabel!
    @IBOutlet weak var supportAddressLabel: UILabel!
    
    @IBOutlet weak var sourceNoteLabel: UILabel!
    @IBOutlet weak var sourceAddressLabel: UILabel!
    
    @IBOutlet weak var developerName_0: UILabel!
    
    
    //MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("InfoTVC_NavigationItemTitle", comment: "")
        
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
        
        tableView.reloadData() // in case of preferred content size change
    }
    
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        var urlStringValue: String?
        if indexPath.section == 1 && indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "HelpTableViewController") as! HelpTableViewController
            navigationItem.removeTextFromBackBarButton()
            navigationController?.pushViewController(destinationViewController, animated: true)
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            urlStringValue = "http://www.erikmartens.de/portfolio.html"
        }
        if indexPath.section == 1 && indexPath.row == 2 {
            urlStringValue = "https://github.com/erikmartens/NearbyWeather"
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            urlStringValue = "http://www.erikmartens.de/contact.html"
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            urlStringValue = "https://github.com/pkluz/PKHUD"
        }
        if indexPath.section == 3 && indexPath.row == 1 {
            urlStringValue = "https://github.com/Onix-Systems/RainyRefreshControl"
        }
        if indexPath.section == 3 && indexPath.row == 2 {
            urlStringValue = "https://github.com/serralvo/TextFieldCounter"
        }
        
        guard let urlString = urlStringValue,
            let url = URL(string: urlString) else {
                return
        }
        let safariController = SFSafariViewController(url: url)
        if #available(iOS 10, *) {
            safariController.preferredControlTintColor = .nearbyWeatherStandard
        } else {
            safariController.view.tintColor = .nearbyWeatherStandard
        }
        present(safariController, animated: true, completion: nil)
    }
    
    
    // MARK: - TableView Data Source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return NSLocalizedString("InfoTVC_TableViewSectionHeader1", comment: "")
        case 2: return NSLocalizedString("InfoTVC_TableViewSectionHeader2", comment: "")
        case 3: return NSLocalizedString("InfoTVC_TableViewSectionHeader3", comment: "")
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
        appTitleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        appTitleLabel.text! = NSLocalizedString("InfoTVC_AppTitle", comment: "")
        
        appVersionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        appVersionLabel.text! = NSLocalizedString("InfoTVC_AppVersion", comment: "")
        
        supportNoteLabel.font = UIFont.preferredFont(forTextStyle: .body)
        supportNoteLabel.text! = NSLocalizedString("InfoTVC_Support", comment: "")
        
        supportAddressLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        supportAddressLabel.textColor = .nearbyWeatherStandard
        
        sourceNoteLabel.font = UIFont.preferredFont(forTextStyle: .body)
        sourceNoteLabel.text! = NSLocalizedString("InfoTVC_Source", comment: "")
        
        sourceAddressLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        sourceAddressLabel.textColor = .nearbyWeatherStandard
        
        developerName_0.font = UIFont.preferredFont(forTextStyle: .body)
    }
}
