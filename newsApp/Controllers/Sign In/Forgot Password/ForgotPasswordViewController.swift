//
//  ForgotPasswordViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 07/01/21.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var explainationLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendLinkButton: UIButton!
    @IBOutlet weak var sendSpinner: UIActivityIndicatorView!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var explanationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyboardAdjustView: UIView!
    private var keyboardManager = KeyboardManager()
    private var keyboardAppearedAgain: Bool = true
    private var sendSuccessful: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        sendLinkButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        sendLinkButton.layer.borderWidth = 1
        sendLinkButton.layer.cornerRadius = 10
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(calculateKeyboardHeight), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyBoard()
    }

    @IBAction func sendLinkPressed(_ sender: UIButton) {
        dismissKeyBoard()
        toggleSendButtonAndSpinner(shouldButtonAppear: false)
        if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let sendError = error {
                    self.toggleSendButtonAndSpinner(shouldButtonAppear: true)
                    self.presentAlert(withTitle: K.UIText.errorString, message: sendError.localizedDescription, okText: K.UIText.tryAgain)
                }
                else {
                    self.presentAlert(withTitle: K.UIText.sentString, message: K.UIText.sentSuccessful, okText: K.UIText.okString) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.toggleSendButtonAndSpinner(shouldButtonAppear: true)
                }
            }
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendLinkPressed(sendLinkButton)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !keyboardAppearedAgain {
            keyboardAppearedAgain = true
            if keyboardManager.needsAdjustment {
                toggleView(shouldExpand: true)
            }
        }
    }
    
    @objc private func dismissKeyBoard() {
        emailTextField.resignFirstResponder()
    }
    
    @objc private func calculateKeyboardHeight(_ notification: Notification) {
        if keyboardAppearedAgain && navigationController?.topViewController is ForgotPasswordViewController {
            keyboardAppearedAgain = false
            if keyboardManager.adjustmentViewHeight == 0 {
                keyboardManager = KeyboardManager(keyboardAdjustView.frame.size.height)
            }
            keyboardManager.calculateKeyboardHeight(notification)
            if keyboardManager.needsAdjustment {
                toggleView(shouldExpand: false)
            }
        }
    }
    
    private func toggleView(shouldExpand: Bool) {
        titleBottomConstraint.constant += (shouldExpand ? keyboardManager.factor : -keyboardManager.factor)/3
        titleTopConstraint.constant += (shouldExpand ? keyboardManager.factor : -keyboardManager.factor)/3
        explanationBottomConstraint.constant += (shouldExpand ? keyboardManager.factor : -keyboardManager.factor)/3
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func presentAlert(withTitle title: String, message: String, okText: String, callback: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        alert.addAction(UIAlertAction(title: okText, style: .default, handler: { _ in
            callback()
        }))
        present(alert, animated: true)
    }
    
    private func toggleSendButtonAndSpinner(shouldButtonAppear: Bool) {
        DispatchQueue.main.async {
            self.sendLinkButton.isHidden = !shouldButtonAppear
            self.sendSpinner.isHidden = shouldButtonAppear
        }
    }
    
}
