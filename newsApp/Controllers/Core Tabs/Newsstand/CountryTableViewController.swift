//
//  CountryTableViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 06/10/20.
//

import UIKit

class CountryTableViewController: UITableViewController {
    
    private var NSTVController: NewsstandTableViewController?
    
    private let countries: [Country] = [Country("Argentina", "ar"), Country("Australia", "au"),
                                    Country("Austria", "at"), Country("Belgium", "be"),
                                    Country("Brazil", "br"), Country("Bulgaria", "bg"),
                                    Country("Canada", "ca"), Country("China", "cn"),
                                    Country("Colombia", "co"), Country("Cuba", "cu"),
                                    Country("Czechia", "cz"), Country("Egypt", "eg"),
                                    Country("France", "fr"), Country("Germany", "de"),
                                    Country("Greece", "gr"), Country("Hong Kong", "hk"),
                                    Country("Hungary", "hu"), Country("India", "in"),
                                    Country("Indonesia", "id"), Country("Ireland", "ie"),
                                    Country("Israel", "il"), Country("Italy", "it"),
                                    Country("Japan", "jp"), Country("Latvia", "lv"),
                                    Country("Lithuania", "lt"), Country("Malaysia", "my"),
                                    Country("Mexico", "mx"), Country("Morocco", "ma"),
                                    Country("Netherlands", "nl"), Country("New Zealand", "nz"),
                                    Country("Nigeria", "ng"), Country("Norway", "no"),
                                    Country("Philippines", "ph"), Country("Poland", "pl"),
                                    Country("Portugal", "pt"), Country("Romania", "ro"),
                                    Country("Russia", "ru"), Country("Saudi Arabia", "sa"),
                                    Country("Serbia", "rs"), Country("Singapore", "sg"),
                                    Country("Slovakia", "sk"), Country("Slovenia", "si"),
                                    Country("South Africa", "za"), Country("South Korea", "kr"),
                                    Country("Sweden", "se"), Country("Switzerland", "ch"),
                                    Country("Taiwan", "tw"), Country("Thailand", "th"),
                                    Country("Turkey", "tr"), Country("Ukraine", "ua"),
                                    Country("United Arab Emirates", "ae"), Country("United Kingdom", "gb"),
                                    Country("United States", "us"), Country("Venezuela", "ve")
                        ]
     
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.overrideUserInterfaceStyle = .dark
        overrideUserInterfaceStyle = .dark
        NSTVController = self.presentingViewController?.children[0].children[0] as? NewsstandTableViewController
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !Settings.isCountrySet {
            DispatchQueue.main.async {
                self.NSTVController?.countrySwitch.setOn(false, animated: true)
                self.NSTVController?.countrySwitchDidToggle((self.NSTVController?.countrySwitch)!)
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row].name
        cell.accessoryType = cell.textLabel?.text == Settings.currentCountry.name ? .checkmark : .none
        return cell
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Settings.isCountrySet = true
        Settings.currentCountry = countries[indexPath.row]
        UserDefaults.standard.set(Settings.currentCountry.name, forKey: K.countryKey)
        UserDefaults.standard.set(Settings.currentCountry.code, forKey: K.countryCodeKey)
        tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.async {
            self.NSTVController?.countryRefresh()
        }
        self.dismiss(animated: true)
    }
}
