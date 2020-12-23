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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
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
    
    
    private func promptForConfirmation() {
        let alert = UIAlertController(title: K.UIText.clearHistoryMessage, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: K.UIText.deleteString, style: .destructive, handler: { (action) in
            RecentSearches().reset()
        }))
        alert.addAction(UIAlertAction(title: K.UIText.cancelString, style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
}
