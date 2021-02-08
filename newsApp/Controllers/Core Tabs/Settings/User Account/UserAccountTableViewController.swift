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
    private let firestoreManager = FirestoreManager()
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
    
    private func startDeletingDataOfAccount() {
        firestoreManager.getAllDocuments(fromCollection: Settings.userEmail) { (querySnapshot, error) in
            var documentsToDecrementFrom = [String]()
            var marks = [String]()
            if let error = error {
                print("error deleting account")
                print(error)
            }
            else if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                print("processing querySnapshot")
                for document in querySnapshot.documents {
                    documentsToDecrementFrom.append(document.documentID)
                    marks.append(document.data()[K.FStore.markedAs] as! String)
                    self.firestoreManager.delete(document: document.documentID, fromCollection: Settings.userEmail) { (error) in
                        if let error = error {
                            print("error deleting document \"\(document.documentID)\"")
                            print(error.localizedDescription)
                        }
                        else {
                            print("document \"\(document.documentID)\" successfully deleted")
                        }
                    }
                }
                self.undoMarksFromMainDB(documentsToUndoFrom: documentsToDecrementFrom, marksToUndo: marks, index: 0)
            }
            else {
                self.undoMarksFromMainDB(documentsToUndoFrom: documentsToDecrementFrom, marksToUndo: marks, index: 0)
            }
        }
    }
    
    private func undoMarksFromMainDB(documentsToUndoFrom: [String], marksToUndo: [String], index: Int) {
        if (index >= marksToUndo.count) {
            self.actualDeleteAccount()
            return
        }
        firestoreManager.get(document: documentsToUndoFrom[index]) { (document, error) in
            if let error = error {
                print("error fetching document to update")
                print(error.localizedDescription)
            }
            else if let document = document, let data = document.data(), document.exists {
                let realCount = data[K.FStore.realCount] as! Int
                let fakeCount = data[K.FStore.fakeCount] as! Int
                if (realCount == 0 && fakeCount == 1) || (realCount == 1 && fakeCount == 0) {
                    self.firestoreManager.delete(document: document.documentID) { (error) in 
                        if let error = error {
                            print("error deleting document \(document.documentID)")
                            print(error.localizedDescription)
                        }
                        else {
                            print("document \(document.documentID) successfully deleted")
                        }
                        self.undoMarksFromMainDB(documentsToUndoFrom: documentsToUndoFrom, marksToUndo: marksToUndo, index: index+1)
                        if index == marksToUndo.count - 1 {
                            self.actualDeleteAccount()
                        }
                    }
                    
                }
                else {
                    let updatedData: [AnyHashable: Any] = [
                        (marksToUndo[index] == "real" ? K.FStore.realCount : K.FStore.fakeCount): (marksToUndo[index] == "real" ? realCount - 1 : fakeCount - 1)
                    ]
                    self.firestoreManager.update(document: document.documentID, withData: updatedData) { (error) in
                        if let error = error {
                            print("error updating document")
                            print(error.localizedDescription)
                        }
                        else {
                            print("document \(document.documentID) successfully updated")
                        }
                        self.undoMarksFromMainDB(documentsToUndoFrom: documentsToUndoFrom, marksToUndo: marksToUndo, index: index+1)
                    }
                }
            }
            else {
                self.undoMarksFromMainDB(documentsToUndoFrom: documentsToUndoFrom, marksToUndo: marksToUndo, index: index+1)
                if index == marksToUndo.count - 1 {
                    self.actualDeleteAccount()
                }
            }
        }
    }
    
    
    private func actualDeleteAccount() {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                self.toggleDeleteAccountSpinner(spinnerShouldAppear: false)
                if let error = error {
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
    
    private func reauthenticaticate(withCredential credential: AuthCredential) {
        if let user = Auth.auth().currentUser {
            user.reauthenticate(with: credential) { (authResult, error) in
                if let error = error {
                    self.toggleDeleteAccountSpinner(spinnerShouldAppear: false)
                    self.presentAlert(withTitle: K.UIText.errorString, message: error.localizedDescription)
                    print("error occured while reauthentication")
                    print(error)
                }
                else {
                    self.startDeletingDataOfAccount()
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
            self.confirmDelete()
            self.toggleDeleteAccountSpinner(spinnerShouldAppear: true)
        }))
        alert.addAction(UIAlertAction(title: K.UIText.cancelString, style: .cancel, handler: { (action) in
            alert.dismiss(animated: true)
        }))
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
    
    private func confirmDelete() {
        let alert = UIAlertController(title: K.UIText.confirmDeleteTitle, message: K.UIText.confirmDeleteMessage, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = K.UIText.passwordPlaceholder
            textField.addTarget(self, action: #selector(self.textDidChange), for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: K.UIText.cancelString, style: .cancel, handler: { (action) in
            alert.dismiss(animated: true) {
                self.toggleDeleteAccountSpinner(spinnerShouldAppear: false)
            }
        }))
        alert.addAction(UIAlertAction(title: K.UIText.deleteString, style: .destructive, handler: { (action) in
            let password = alert.textFields!.first!.text!
            let credential = EmailAuthProvider.credential(withEmail: Settings.userEmail, password: password)
            self.reauthenticaticate(withCredential: credential)
            alert.dismiss(animated: true)
        }))
        alert.actions[1].isEnabled = false
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        var responder: UIResponder! = textField
        while !(responder is UIAlertController) {
            responder = responder.next
        }
        let alert = responder as? UIAlertController
        alert?.actions[1].isEnabled = textField.text!.count > 5
    }
    

}

