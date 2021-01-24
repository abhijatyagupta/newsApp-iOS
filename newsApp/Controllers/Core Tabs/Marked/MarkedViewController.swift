//
//  MarkedViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 30/12/20.
//

import UIKit

class MarkedViewController: UIViewController {
    
    @IBOutlet weak var signedOutView: SignedOutView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Settings.isUserSignedIn {
            navigationController?.navigationBar.isHidden = true
            signedOutView.delegate = self
            signedOutView.isHidden = false
        }
    }
}


extension MarkedViewController: SignedOutViewDelegate {
    func signInTapped() {
        let nvc = UINavigationController()
        nvc.overrideUserInterfaceStyle = .dark
        let vc = SignInViewController()
        nvc.viewControllers.append(vc)
        present(nvc, animated: true)
    }
    
    func signUpTapped() {
        let nvc = UINavigationController()
        nvc.overrideUserInterfaceStyle = .dark
        let vc = SignInViewController()
        nvc.viewControllers.append(vc)
        vc.isSignUpController = true
        present(nvc, animated: true)
    }
    
    
    
}
