//
//  UserAccountTableViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 25/01/21.
//

import UIKit
import Firebase

class UserAccountTableViewController: UITableViewController {

    @IBOutlet weak var passwordSpinner: UIActivityIndicatorView!
    @IBOutlet weak var resetPasswordLabel: UILabel!
    @IBOutlet weak var deleteAccountSpinner: UIActivityIndicatorView!
    @IBOutlet weak var deleteAccountLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        navigationItem.title = Settings.userEmail
    }
    
    //MARK: - Table View Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                resetPassword()
                togglePasswordSpinner(spinnerShouldAppear: true)
            }
            if indexPath.row == 1 {
                signOutAlert()
            }
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            deleteAlert()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 1 ? K.UIText.deleteAccountFooter : nil
    }
    
    //MARK: - Other Methods
    
    private func togglePasswordSpinner(spinnerShouldAppear: Bool) {
        resetPasswordLabel.isHidden = spinnerShouldAppear
        passwordSpinner.isHidden = !spinnerShouldAppear
    }
    
    private func toggleDeleteAccountSpinner(spinnerShouldAppear: Bool) {
        deleteAccountLabel.isHidden = spinnerShouldAppear
        deleteAccountSpinner.isHidden = !spinnerShouldAppear
    }
    
    private func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: Settings.userEmail) { error in
            self.togglePasswordSpinner(spinnerShouldAppear: false)
            if let error = error {
                self.presentAlert(withTitle: K.UIText.errorString, message: error.localizedDescription)
            }
            else {
                self.presentAlert(withTitle: K.UIText.sentString, message: K.UIText.passwordResetMessage)
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        }
        catch let signOutError as NSError {
            presentAlert(withTitle: K.UIText.errorString, message: signOutError.localizedDescription)
            print("Error signing out: %@", signOutError)
        }
    }
    
    private func deleteAccount() {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                self.toggleDeleteAccountSpinner(spinnerShouldAppear: false)
                if let error = error {
                    self.presentAlert(withTitle: K.UIText.errorString, message: error.localizedDescription)
                    print("error deleting account")
                    print(error)
                }
                else {
                    self.presentAlert(withTitle: "", message: K.UIText.deleteSuccess) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func presentAlert(withTitle: String, message: String, callback: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        alert.addAction(UIAlertAction(title: K.UIText.okString, style: .default, handler: { (action) in
            callback()
        }))
        present(alert, animated: true)
    }
    
    private func signOutAlert() {
        let alert = UIAlertController(title: K.UIText.areYouSure, message: K.UIText.signOutMessage, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: K.UIText.signOutString, style: .destructive, handler: { (action) in
            self.signOut()
        }))
        alert.addAction(UIAlertAction(title: K.UIText.cancelString, style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
    
    private func deleteAlert() {
        let alert = UIAlertController(title: K.UIText.areYouSure, message: K.UIText.deleteAccountFooter, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: K.UIText.deleteAndSignOut, style: .destructive, handler: { (action) in
            self.deleteAccount()
            self.toggleDeleteAccountSpinner(spinnerShouldAppear: true)
        }))
        alert.addAction(UIAlertAction(title: K.UIText.cancelString, style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }

}
