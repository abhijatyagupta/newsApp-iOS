//
//  Settings.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 13/10/20.
//

import UIKit

class Settings {
    
    //MARK: - Initializer
    
    init() {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            print(path)
            if let key = NSDictionary(contentsOfFile: path)?.object(forKey: "API_KEY") as? String {
                API_KEY = "apiKey=\(key)"
            }
            else {
                API_KEY = "apiKey="
            }
        }
        else {
            API_KEY = "apiKey="
        }
        
        
        
    }
    
    //MARK: - API Settings
    
    public var apiURL: String {
        get {
            return "https://newsapi.org/v2/sources?\(API_KEY)"
        }
    }
    
    private let API_KEY: String
    private let API_COUNTRY: String = "&q="
    
//    var country: String
    
    static var isCountrySet: Bool = false {
        didSet {
            if !isCountrySet {
                
            }
        }
    }
    
    static var currentCountry: String = "" {
        didSet {
            isCountrySet = true
        }
    }
    
}
