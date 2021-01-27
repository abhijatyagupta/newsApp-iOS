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
            self.toggleSignedOutView(shouldViewAppear: user == nil)
        }
    }
    
    
    private func toggleSignedOutView(shouldViewAppear: Bool) {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.isHidden = shouldViewAppear
            self.signedOutView.isHidden = !shouldViewAppear
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
