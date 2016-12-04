//
//  SettingsInputTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class SettingsInputTableViewController: UITableViewController, UITextFieldDelegate {
    
    //MARK: - Assets
    /* General */
    var favoritedLocation: String?

    /* Outlets */
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //MARK: - Override Functions
    /* General */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("SettingsInputTVC_NavigationBarTitle", comment: "")
        
        //Set up tableview
        tableView.delegate = self
        
        //Handle the text field’s user input through delegate callbacks
        inputTextField.delegate = self
        
        //Set up view
        inputTextField.text! = favoritedLocation!
        
        //Enable the Save button only if the text field has a valid city name
        self.checkValidCityTitle()
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.inputTextField.resignFirstResponder()
    }
    
    /* TableView */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("InputSettingsTVC_SectionTitle", comment: "")
    }
    
    //MARK: - Private Helper Methods
    fileprivate func checkValidCityTitle() {
        // Disable the Save, Export and Flag buttons if the text field is empty
        let text = inputTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    //MARK: - Input Interaction
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        favoritedLocation = inputTextField.text!
        performSegue(withIdentifier: "unwindToSettingsTVC", sender: self)
    }
    @IBAction func inputTextFieldEditingChanged(_ sender: Any) {
        self.checkValidCityTitle()
    }
}
