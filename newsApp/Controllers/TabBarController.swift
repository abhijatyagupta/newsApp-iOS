//
//  TabBarController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 08/12/20.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = UserDefaults.standard.integer(forKey: K.initialScreenKey)
    }
}
