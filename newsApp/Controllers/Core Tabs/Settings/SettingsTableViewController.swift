//
//  SettingsTableViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 28/11/20.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var rememberCountrySettingsSwitch: UISwitch!
    @IBOutlet weak var searchHistorySwitch: UISwitch!
    @IBOutlet weak var initialScreenDisclosureText: UILabel!
    private let defaults = UserDefaults.standard
    private let initialScreens: [String] = ["Newsstand", "World/Country", "Headlines"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        updateDisclosureText()
        rememberCountrySettingsSwitch.setOn(Settings.rememberCountrySettings, animated: false)
        searchHistorySwitch.setOn(Settings.isSearchHistoryOn, animated: false)
    }
    
    @IBAction func rememberCountrySettingsSwitchDidToggle(_ sender: UISwitch) {
        defaults.set(rememberCountrySettingsSwitch.isOn, forKey: K.rCSKey)
    }
    
    
    @IBAction func searchHistorySwitchDidToggle(_ sender: UISwitch) {
        if searchHistorySwitch.isOn {
            defaults.set(searchHistorySwitch.isOn, forKey: K.searchHistoryKey)
        }
        else {
            searchHistoryTurnOffPrompt()
        }
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                promptForConfirmation()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return K.UIText.historyFooter
        }
        return ""
    }
    
    
    private func searchHistoryTurnOffPrompt() {
        let alert = UIAlertController(title: K.UIText.turnOffHistoryTitle, message: K.UIText.turnOffHistoryMessage, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: K.UIText.turnOff, style: .default, handler: { (action) in
            self.defaults.set(false, forKey: K.searchHistoryKey)
        }))
        alert.addAction(UIAlertAction(title: K.UIText.turnOffAndDelete, style: .destructive, handler: { (action) in
            self.defaults.set(false, forKey: K.searchHistoryKey)
            RecentSearches().reset()
        }))
        alert.addAction(UIAlertAction(title: K.UIText.cancelString, style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
            self.searchHistorySwitch.setOn(true, animated: true)
        }))
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
    
    
    private func promptForConfirmation() {
        let alert = UIAlertController(title: K.UIText.clearHistoryTitle, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: K.UIText.deleteString, style: .destructive, handler: { (action) in
            RecentSearches().reset()
        }))
        alert.addAction(UIAlertAction(title: K.UIText.cancelString, style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
}
