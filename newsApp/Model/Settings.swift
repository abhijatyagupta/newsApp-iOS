//
//  Settings.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 13/10/20.
//

import UIKit
import Firebase

class Settings {
    
    //MARK: - API Settings
    
    
    public static var apiURL: String {
        get {
            return "https://newsapi.org/v2/top-headlines?apiKey=\(API_KEY)"
        }
    }
    
    public static var worldApiURL: String {
        get {
            return "https://newsapi.org/v2/top-headlines?apiKey=\(API_KEY)&language=en" + (isCountrySet ? "\(API_COUNTRY)" : "")
        }
    }
    
    public static var searchApiURL: String {
        get {
            return "https://newsapi.org/v2/everything?apiKey=\(API_KEY)"
        }
    }
    
    
    private static var API_KEY: String {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            if let key = NSDictionary(contentsOfFile: path)?.object(forKey: "API_KEY") as? String {
                return "\(key)"
            }
            else {
                return ""
            }
        }
        else {
            return ""
        }
    }
    
    private static var API_COUNTRY: String {
        return "&country=\(currentCountry.code)"
    }
    
//    var country: String
    
    static var isCountrySet: Bool = false
    
    static var currentCountry: Country = Country("", "")
    
    static var initialScreen: Int {
        get {
            return UserDefaults.standard.integer(forKey: K.initialScreenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.initialScreenKey)
        }
        
    }
    
    static var rememberCountrySettings: Bool {
        return UserDefaults.standard.bool(forKey: K.rCSKey)
    }
    
    static var isSearchHistoryOn: Bool {
        return UserDefaults.standard.bool(forKey: K.searchHistoryKey)
    }
    
    
    static var isUserSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    
}
