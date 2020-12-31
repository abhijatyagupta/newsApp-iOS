//
//  MarkedViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 30/12/20.
//

import UIKit
import Firebase

class MarkedViewController: UIViewController {
    
    @IBOutlet weak var signedOutView: SignedOutView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Settings.isUserSignedIn {
            navigationController?.navigationBar.isHidden = true
            signedOutView.isHidden = false
        }
    }
}
