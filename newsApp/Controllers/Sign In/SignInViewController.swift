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
    @IBOutlet weak var passwordTextField: UITextField!
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
        addShowPasswordButton()
    }
    
    private func addShowPasswordButton() {
        let button = UIButton(frame: CGRect(x: 20, y: 0, width: ((passwordTextField.frame.height) * 0.70), height: ((passwordTextField.frame.height) * 0.70)))
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
        button.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(showPassword), for: .touchUpInside)
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: button.frame.width + 35, height: button.frame.height))
        rightView.backgroundColor = .clear
        rightView.addSubview(button)
        passwordTextField.rightViewMode = .always
        passwordTextField.rightView = rightView
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
    
    @objc private func showPassword() {
        if let rightView = passwordTextField.rightView, let button = rightView.subviews[0] as? UIButton {
            let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            passwordTextField.isSecureTextEntry = !(button.tintColor == white)
            button.setImage(UIImage(systemName: button.tintColor == white ? "eye" : "eye.slash"), for: .normal)
            button.tintColor = button.tintColor == white ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : white
        }
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
