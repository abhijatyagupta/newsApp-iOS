//
//  File.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 23/12/20.
//

import UIKit

class RecentSearches {
    private let defaults = UserDefaults.standard
    
    var count: Int {
        get {
            return (defaults.array(forKey: K.recentSearchesKey) as! [String]).count
        }
    }
    
    var array: [String] {
        get {
            return defaults.array(forKey: K.recentSearchesKey) as! [String]
        }
        set {}
    }
    
    func add(search: String) {
        if !Settings.isSearchHistoryOn {
            return
        }
        
        var recentSearches = array
        if let index = recentSearches.firstIndex(of: search) {
            recentSearches.remove(at: index)
        }
        if count == 10 {
            recentSearches.remove(at: count - 1)
        }
        recentSearches.insert(search, at: 0)
        update(newArray: recentSearches)
    }
    
    func reset() {
        defaults.set([String](), forKey: K.recentSearchesKey)
    }
    
    
    private func update(newArray: [String]) {
        defaults.set(newArray, forKey: K.recentSearchesKey)
    }
    
    func resultsViewControllerFor(query: String) -> WorldCountryViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "worldCountryViewController") as WorldCountryViewController
        vc.navigationItem.title = query
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.parentCategory = true
        vc.isSearchResultInstance = true
        vc.apiToCall = Settings.searchApiURL + "&q=\(query)"
        return vc
    }
    
}

