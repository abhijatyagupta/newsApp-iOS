//
//  Settings.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 13/10/20.
//

import UIKit

class Settings {
    
    //MARK: - API Settings
    
    public static var apiURL: String {
        get {
            return "https://newsapi.org/v2/top-headlines?\(API_KEY)"
        }
    }
    
    public static var worldApiURL: String {
        get {
            return "https://newsapi.org/v2/top-headlines?\(API_KEY)&q=%2A"
        }
    }
    
    
    private static var API_KEY: String {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            if let key = NSDictionary(contentsOfFile: path)?.object(forKey: "API_KEY") as? String {
                return "apiKey=\(key)"
            }
            else {
                return "apiKey="
            }
        }
        else {
            return "apiKey="
        }
    }
    
    fileprivate let API_COUNTRY: String = "&country=\(currentCountry.code)"
    
//    var country: String
    
    static var isCountrySet: Bool = false {
        didSet {
            if !isCountrySet {
                
            }
        }
    }
    
    static var currentCountry: Country = Country("", "") {
        didSet {
            isCountrySet = true
        }
    }
    
    
    
}
