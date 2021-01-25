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
        signedOutView.delegate = self
        Auth.auth().addStateDidChangeListener { (Auth, user) in
            if user != nil {
                DispatchQueue.main.async {
                    self.navigationController?.navigationBar.isHidden = false
                    self.signedOutView.isHidden = true
                }
            }
            else {
                DispatchQueue.main.async {
                    self.navigationController?.navigationBar.isHidden = true
                    self.signedOutView.isHidden = false
                }
            }
        }
        
//        if !Settings.isUserSignedIn {
//            navigationController?.navigationBar.isHidden = true
//            signedOutView.delegate = self
//            signedOutView.isHidden = false
//        }
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
