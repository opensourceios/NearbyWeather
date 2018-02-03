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
    
    @IBOutlet weak var rateVersionLabel: UILabel!
    @IBOutlet weak var sourceNoteLabel: UILabel!
    @IBOutlet weak var sourceAddressLabel: UILabel!
    
    @IBOutlet weak var developerName_0: UILabel!
    @IBOutlet weak var developerNameSubtitle_0: UILabel!
    @IBOutlet weak var howToContributeLabel: UILabel!
    
    
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        var urlStringValue: String?
        if indexPath.section == 0 && indexPath.row == 0 {
            let urlString = "https://itunes.apple.com/app/id1227313069?action=write-review&mt=8"
            UIApplication.shared.openURL(URL(string: urlString)!)
            return
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            urlStringValue = "https://github.com/erikmartens/NearbyWeather"
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            urlStringValue = "http://www.erikmartens.de/contact.html"
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            urlStringValue = "https://github.com/erikmartens/NearbyWeather/blob/master/CONTRIBUTING.md"
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
        case 0: return NSLocalizedString("InfoTVC_TableViewSectionHeader1", comment: "")
        case 1: return NSLocalizedString("InfoTVC_TableViewSectionHeader2", comment: "")
        case 2: return nil
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
        appTitleLabel.text = NSLocalizedString("InfoTVC_AppTitle", comment: "")
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "#UNDEFINED"
        let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "#UNDEFINED"
        appVersionLabel.text = "Version \(appVersion) Build #\(appBuild)"
        rateVersionLabel.text = NSLocalizedString("InfoTVC_RateVersion", comment: "")
        sourceNoteLabel.text = NSLocalizedString("InfoTVC_Source", comment: "")
        sourceAddressLabel.textColor = .nearbyWeatherStandard
        developerName_0.text = "Erik Maximilian Martens"
        howToContributeLabel.text = NSLocalizedString("InfoTVC_HowToContribute", comment: "")
        developerNameSubtitle_0.text = NSLocalizedString("InfoTVC_DeveloperNameSubtitle_0", comment: "")
    }
}
