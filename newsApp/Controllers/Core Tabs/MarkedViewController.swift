//
//  MarkedViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 30/12/20.
//

import UIKit
import Firebase

class MarkedViewController: UIViewController {
    
    @IBOutlet weak var signedOutView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Settings.isUserSignedIn {
            setupSignUp()
        }
    }
    
    
    
    private func setupSignUp() {
        navigationController?.navigationBar.isHidden = true
        logoImageView.layer.cornerRadius = 20
        signInButton.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }
    @IBAction func signInTapped(_ sender: UIButton) {
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
    }
}
