//
//  SignInViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 31/12/20.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        navigationItem.rightBarButtonItem = cancelBarButtonForNavigationBar()
        setTitleImage()
        signInButton.layer.cornerRadius = 10
        configureTextFields()
    }
    
    func cancelBarButtonForNavigationBar() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
    
    private func setTitleImage() {
        let imageView = UIImageView(image: UIImage(imageLiteralResourceName: "logo.png"))
        imageView.contentMode = .scaleAspectFit
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        titleView.layer.cornerRadius = 10
        titleView.clipsToBounds = true
        navigationItem.titleView = titleView
    }
    
    private func configureTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func toggleSignInButtonAndSpinner(shouldButtonAppear: Bool) {
        self.signInButton.isHidden = !shouldButtonAppear
        self.signInSpinner.isHidden = shouldButtonAppear
    }
    
    private func refreshSignInButton() {
        if let emailCount = emailTextField.text?.count, let passCount = passwordTextField.text?.count {
            if emailCount > 4 && passCount > 5 {
                signInButton.isEnabled = true
                signInButton.alpha = 1
                return
            }
        }
        signInButton.isEnabled = false
        signInButton.alpha = 0.5
    }
    
    private func signIn() {
        if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let signInError = error {
                    DispatchQueue.main.async {
                        self.toggleSignInButtonAndSpinner(shouldButtonAppear: true)
                    }
                    self.presentSignInAlert(withMessage: signInError.localizedDescription)
                    print(signInError)
                }
                else {
                    self.dismiss(animated: true) {
                        
                    }
                }
            }
            DispatchQueue.main.async {
                self.toggleSignInButtonAndSpinner(shouldButtonAppear: false)
            }
        }
    }
    
    
    private func presentSignInAlert(withMessage: String) {
        let alert = UIAlertController(title: K.UIText.errorString, message: withMessage, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        alert.addAction(UIAlertAction(title: K.UIText.tryAgain, style: .default))
        present(alert, animated: true)
    }

    @IBAction func signInPressed(_ sender: UIButton) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        signIn()
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        refreshSignInButton()
    }
    
    
    
}



extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
            return true
        }
        else if textField == passwordTextField {
            if signInButton.isEnabled {
                textField.resignFirstResponder()
                signIn()
                return true
            }
        }
        return false
    }
}
