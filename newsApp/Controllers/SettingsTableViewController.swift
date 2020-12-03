//
//  SettingsTableViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 28/11/20.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var rememberCountrySettingsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
    }
    
    @IBAction func rememberCountrySettingsSwitchTapped(_ sender: UISwitch) {
        UserDefaults.standard.set(rememberCountrySettingsSwitch.isOn ? true : false, forKey: "rememberCountrySettings")
    }
    
}
