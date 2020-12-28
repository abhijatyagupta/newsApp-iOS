//
//  HeadlinesViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 18/12/20.
//

import UIKit

class HeadlinesViewController: UIViewController {
    @IBOutlet weak var testTableView: UITableView!
    private let searchController = UISearchController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        searchController.searchBar.placeholder = "Search topic"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        testTableView.delegate = self
        testTableView.dataSource = self
        
    }

}

extension HeadlinesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath)
        cell.textLabel?.text = "test text"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath.row)
    }
    
}


extension HeadlinesViewController: UISearchBarDelegate {
    
}

