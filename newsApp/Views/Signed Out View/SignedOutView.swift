//
//  SignedOutView.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 30/12/20.
//

import UIKit

protocol SignedOutViewDelegate: class {
    func signInTapped()
    func signUpTapped()
}

class SignedOutView: UIView {

    @IBOutlet var superView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    var delegate: SignedOutViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("SignedOutView", owner: self, options: nil)
        addSubview(superView)
        
    }
    
    override func awakeFromNib() {
        logoImageView.layer.cornerRadius = 20
        signInButton.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    
    
    @IBAction func signInTapped(_ sender: UIButton) {
        delegate?.signInTapped()
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        delegate?.signUpTapped()
    }
    
    
}
