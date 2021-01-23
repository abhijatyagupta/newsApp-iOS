//
//  SignedOutViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 07/01/21.
//

import UIKit

class SignedOutViewController: UIViewController, SignedOutViewDelegate {
    
    @IBOutlet var signedOutView: SignedOutView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.overrideUserInterfaceStyle = .dark
        navigationController?.navigationBar.isHidden = true
        signedOutView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    func signInTapped() {
        let vc = SignInViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func signUpTapped() {
        
    }

}
