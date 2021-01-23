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
    @IBOutlet weak var signInBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var signInTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyboardAdjustView: UIView!
    private var keyboardManager = KeyboardManager()
    private var keyboardAppearedAgain: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        navigationController?.navigationBar.isHidden = false
        navigationItem.rightBarButtonItem = cancelBarButtonForNavigationBar()
        navigationItem.titleView = logoTitleView()
        signInButton.layer.cornerRadius = 10
        configureTextFields()
        NotificationCenter.default.addObserver(self, selector: #selector(calculateKeyboardHeight), name: UIResponder.keyboardWillShowNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyBoard()
    }
    
    func cancelBarButtonForNavigationBar() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
    }
    
    @objc private func dismissKeyBoard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
    
    @objc private func calculateKeyboardHeight(_ notification: Notification) {
        if keyboardAppearedAgain && navigationController?.topViewController is SignInViewController {
            keyboardAppearedAgain = false
            //could've instantiated keyboardManager in viewDidLoad, but for
            //some godforsaken reason keyboardAdjustView.frame.size.height
            //reported wrong height there.
            if keyboardManager.adjustmentViewHeight == 0 {
                keyboardManager = KeyboardManager(keyboardAdjustView.frame.size.height)
            }
            keyboardManager.calculateKeyboardHeight(notification)
            if keyboardManager.needsAdjustment {
                toggleView(shouldExpand: false)
            }
        }
    }
    
    private func logoTitleView() -> UIView {
        let imageView = UIImageView(image: UIImage(imageLiteralResourceName: "logo.png"))
        imageView.contentMode = .scaleAspectFit
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        titleView.layer.cornerRadius = 10
        titleView.clipsToBounds = true
        return titleView
    }
    
    private func configureTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func toggleView(shouldExpand: Bool) {
        signInBottomConstraint.constant += (shouldExpand ? keyboardManager.factor : -keyboardManager.factor)/2
        signInTopConstraint.constant += (shouldExpand ? keyboardManager.factor : -keyboardManager.factor)/2
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func toggleSignInButtonAndSpinner(shouldButtonAppear: Bool) {
        DispatchQueue.main.async {
            self.signInButton.isHidden = !shouldButtonAppear
            self.signInSpinner.isHidden = shouldButtonAppear
        }
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
        let vc = ForgotPasswordViewController()
        vc.navigationItem.titleView = logoTitleView()
        show(vc, sender: self)
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        refreshSignInButton()
    }
    
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !keyboardAppearedAgain {
            keyboardAppearedAgain = true
            if keyboardManager.needsAdjustment {
                toggleView(shouldExpand: true)
            }
        }
    }
    
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
