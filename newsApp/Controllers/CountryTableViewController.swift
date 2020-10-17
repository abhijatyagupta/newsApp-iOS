//
//  CountryTableViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 06/10/20.
//

import UIKit

class CountryTableViewController: UITableViewController {
    
    private let countries: [ String] = ["Argentina","Australia", "Austria", "Belgium", "Brazil", "Bulgaria", "Canada", "China", "Colombia", "Cuba", "Czechia", "Egypt", "France", "Germany", "Greece", "Hong Kong", "Hungary", "India", "Indonesia", "Ireland", "Israel", "Italy", "Japan", "Latvia", "Lithuania", "Malaysia", "Mexico", "Morocco", "Netherlands", "New Zealand", "Nigeria", "Norway", "Philippines", "Poland", "Portugal", "Romania", "Russia", "Saudi Arabia", "Serbia", "Singapore", "Slovakia", "Slovenia", "South Africa", "South Korea", "Sweden", "Switzerland", "Taiwan", "Thailand", "Turkey", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Venezuela"]
    
    
//    private let dofjd: [Country] = [Country("Argentina", "ar", false), Country("Australia", "au", false),
//                                    Country("Austria", "at", false), Country("Belgium", "be", false),
//                                    Country("Brazil", "br", false), Country("Bulgaria", "bg", false),
//                                    Country("Canada", "ca", false), Country("China", "cn", false),
//                                    Country("Colombia", "co", false), Country("Cuba", "cu", false),
//                                    Country("Czechia", "cz", false), Country("Egypt", "eg", false),
//                                    Country("France", "fr", false), Country("Germany", "de", false),
//                                    Country("Greece", "gr", false), Country("Hong Kong", "hk", false),
//                                    Country("Hungary", "hu", false), Country("India", "in", false),
//                                    Country("Indonesia", "id", false), Country("Ireland", "ie", false),
//                                    Country("Israel", "il", false), Country("Italy", "it", false),
//                                    Country("Japan", "jp", false), Country("Latvia", "lv", false),
//                                    Country("Lithuania", "lt", false), Country("Malaysia", "my", false),
//                                    Country("Mexico", "mx", false), Country("Morocco", "ma", false),
//                                    Country("Netherlands", "nl", false), Country("New Zealand", "nz", false),
//                                    Country("Nigeria", "ng", false), Country("Norway", "no", false),
//                                    Country("Philippines", "ph", false), Country("Poland", "pl", false),
//                                    Country("Portugal", "pt", false), Country("Romania", "ro", false),
//                                    Country("Russia", "ru", false), Country("Saudi Arabia", "sa", false),
//                                    Country("Serbia", "rs", false), Country("Singapore", "sg", false),
//                                    Country("Slovakia", "sk", false), Country("Slovenia", "si", false),
//                                    Country("South Africa", "za", false), Country("South Korea", "kr", false),
//                                    Country("Sweden", "se", false), Country("Switzerland", "ch", false),
//                                    Country("Taiwan", "tw", false), Country("Thailand", "th", false),
//                                    Country("Turkey", "tr", false), Country("Ukraine", "ua", false),
//                                    Country("United Arab Emirates", "ae", false), Country("United Kingdom", "gb", false),
//                                    Country("United States", "us", false), Country("Venezuela", "ve", false)
//                        ]
    
    let selected: String = "India"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonTitle = "Newsstand"
        navigationItem.hidesBackButton = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row]
        cell.accessoryType = cell.textLabel?.text == "India" ? .checkmark : .none
        
        return cell
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
