//
//  SettingsTableViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 28/11/20.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var rememberCountrySettingsSwitch: UISwitch!
    @IBOutlet weak var initialScreenDisclosureText: UILabel!
    
    private let initialScreens: [String] = ["Newsstand", "World/Country", "Headlines"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        updateDisclosureText()
        rememberCountrySettingsSwitch.setOn(UserDefaults.standard.bool(forKey: K.rCSKey), animated: false)
    }
    
    @IBAction func rememberCountrySettingsSwitchDidToggle(_ sender: UISwitch) {
        UserDefaults.standard.set(rememberCountrySettingsSwitch.isOn ? true : false, forKey: K.rCSKey)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSetInitialScreen" {
            if let vc = segue.destination as? SetIntitalScreenTableViewController {
                vc.STVController = self
            }
        }
    }
    
    func updateDisclosureText() {
        initialScreenDisclosureText.text = initialScreens[Settings.initialScreen]
    }
    
}
