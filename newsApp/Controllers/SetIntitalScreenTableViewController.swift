//
//  SetIntitalScreenTableViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 05/12/20.
//

import UIKit

class SetIntitalScreenTableViewController: UITableViewController {
    private let defaults = UserDefaults.standard
    var STVController: SettingsTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        STVController?.updateDisclosureText()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = indexPath.row == Settings.initialScreen ? .checkmark : .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentCell = tableView.cellForRow(at: indexPath)
        currentCell?.accessoryType = .checkmark
        Settings.initialScreen = indexPath.row
        tableView.reloadData()
    }

}
