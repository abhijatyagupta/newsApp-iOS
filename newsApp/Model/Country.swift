//
//  Country.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 15/10/20.
//

import UIKit

class Country {
    let country: String
    let code: String
    let selected: Bool
    
    init(_ country:String, _ code: String, _ selected: Bool) {
        self.country = country
        self.code = code
        self.selected = selected
    }
    
    func isSelected() -> Bool {
        return selected
    }
}
