//
//  SettingsTableViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 28/11/20.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var rememberCountrySettingsSwitch: UISwitch!
    @IBOutlet weak var searchHistorySwitch: UISwitch!
    @IBOutlet weak var initialScreenDisclosureText: UILabel!
    @IBOutlet weak var userAccountLabel: UILabel!
    private let defaults = UserDefaults.standard
    private let initialScreens: [String] = ["Newsstand", "World/Country", "Headlines"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        updateDisclosureText()
        rememberCountrySettingsSwitch.setOn(Settings.rememberCountrySettings, animated: false)
        searchHistorySwitch.setOn(Settings.isSearchHistoryOn, animated: false)
        Auth.auth().addStateDidChangeListener { (Auth, user) in
            self.toggleUserAccountRow()
        }
    }
    
    //MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: Settings.isUserSignedIn ? "accountOptionsSegue" : "signedOutSegue", sender: self)
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 1 {
                promptForConfirmation()
            }
        }
    }
    
    //MARK: - Switch Toggle Methods and IBActions
    
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
    
    //MARK: - Other methods
    
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
    
    private func toggleUserAccountRow() {
        userAccountLabel.text = Settings.isUserSignedIn ? Settings.userEmail : K.UIText.signInString
        userAccountLabel.textColor = Settings.isUserSignedIn ? .white : #colorLiteral(red: 0, green: 0.4780980349, blue: 1, alpha: 1)
        tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.accessoryType = Settings.isUserSignedIn ? .disclosureIndicator : .none
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
