//
//  RecentSearchesTableView.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 24/12/20.
//

import UIKit


protocol RecentSearchesCustomDelegate: class {
    func presentNewsFor(query: String)
}

class RecentSearchesTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    let recentSearches = RecentSearches()
    var recentSearchesCustomDelegate: RecentSearchesCustomDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
        dataSource = self
        keyboardDismissMode = .onDrag
    }
    
    convenience init() {
        self.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearch", for: indexPath)
        cell.textLabel?.text = recentSearches.array[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedQuery = tableView.cellForRow(at: indexPath)?.textLabel?.text {
            recentSearchesCustomDelegate?.presentNewsFor(query: selectedQuery)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return recentSearches.count == 0 ? "" : K.UIText.recentSearchHeader
    }
    
}
