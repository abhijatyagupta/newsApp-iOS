//
//  AppDelegate.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 04/10/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: K.rCSKey) as? Bool == nil {
            defaults.set(true, forKey: K.rCSKey)
            defaults.set(nil, forKey: K.countryKey)
            defaults.set(0, forKey: K.initialScreenKey)
        }
        else if !defaults.bool(forKey: K.rCSKey) {
            defaults.set(nil, forKey: K.countryKey)
            
        }
        else if let countryName = defaults.object(forKey: K.countryKey) as? String? {
            if countryName != nil {
                Settings.isCountrySet = true
                let countryToSet = Country(countryName!, defaults.string(forKey: K.countryCodeKey)!)
                Settings.currentCountry = countryToSet
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

