//
//  PublicViewsViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 26/12/20.
//

import UIKit

class PublicViewsViewController: UIViewController {
    
    @IBOutlet weak var publicViewsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var noViewsView: UIView!
    @IBOutlet weak var typingViewBottomConstraint: NSLayoutConstraint!
    private var views = [Int : String]()
    private var usernames = [Int : String]()
    private var times = [Int : String]()
    var publicViewsID: String = ""
    private var duration: Double = 0.350
    private var keyboardHeight: CGFloat?
    private var firestoreManager = FirestoreManager()
    private var addedOnce: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        isModalInPresentation = true
        textView.layer.cornerRadius = 15
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        textView.delegate = self
        publicViewsTableView.delegate = self
        publicViewsTableView.dataSource = self
        publicViewsTableView.register(UINib(nibName: "ViewsCell", bundle: nil), forCellReuseIdentifier: "viewsCell")
        NotificationCenter.default.addObserver(self, selector: #selector(calculateKeyboardHeight), name: UIResponder.keyboardWillShowNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        addListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    
    @IBAction func postButtonPressed(_ sender: UIButton) {
        let message = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if message != "" {
            let currentTime = (Int64)(NSDate().timeIntervalSince1970 * 1000)
            let data: [String : Any] = [
                "user": Settings.userEmail,
                "message": message,
                "time": currentTime
            ]
            firestoreManager.add(document: data, toCollection: "\(K.FStore.pathtoPublicViewsCollection)/\(publicViewsID)/", withName: "\(currentTime)") { (error) in
                if let error = error {
                    self.presentAlert(withTitle: K.UIText.errorString, message: error.localizedDescription)
                    print("error adding your view")
                    print(error)
                }
                else {
                    print("document updated successfully")
                    self.textView.text = ""
                }
            }
        }
    }
    
    
    //MARK: - Helper Methods
    
    @objc private func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    private func presentAlert(withTitle: String, message: String, callback: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        alert.addAction(UIAlertAction(title: K.UIText.tryAgain, style: .default, handler: { (action) in
            alert.dismiss(animated: true) {
                callback()
            }
        }))
        present(alert, animated: true)
    }
    
    @objc private func calculateKeyboardHeight(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.keyboardHeight = keyboardHeight
            if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                self.duration = duration
                publicViewsTableView.setContentOffset(CGPoint(x: publicViewsTableView.contentOffset.x, y: publicViewsTableView.contentOffset.y + keyboardHeight - publicViewsTableView.safeAreaInsets.bottom), animated: false)
                self.typingViewBottomConstraint.constant = keyboardHeight
                UIView.animate(withDuration: self.duration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    private func addListener() {
        firestoreManager.addCollectionListener(forCollection: "\(K.FStore.pathtoPublicViewsCollection)/\(publicViewsID)", andOrderBy: K.FStore.time, descending: false) { (querySnapshot, error) in
            if let error = error {
                print("error attaching listener to collection")
                print(error)
            }
            else if let querySnapshot = querySnapshot {
                if querySnapshot.isEmpty || querySnapshot.documents.isEmpty {
                    self.activityIndicator.isHidden = true
                    self.noViewsView.isHidden = false
                }
                else {
                    let viewsCurrentCount = self.views.count
                    var indexPaths = [IndexPath]()
                    var index = 0
                    querySnapshot.documentChanges.forEach { diff in
                        let data = diff.document.data()
                        if diff.type == .added {
                            let message = data["message"] as! String
                            let user = data["user"] as! String
                            let time = "\(data["time"] as! Int)"
                            indexPaths.append(IndexPath(row: viewsCurrentCount + index, section: 0))
                            self.views[viewsCurrentCount + index] = message
                            self.usernames[viewsCurrentCount + index] = user
                            self.times[viewsCurrentCount + index] = time
                            index += 1
                        }
                        else if diff.type == .removed {
                            if let time = data["time"] as? Int, let message = data["message"] as? String {
                                self.findAndDeleteView(postedAt: "\(time)", withMessage: message)
                            }
                        }
                    }
                    if indexPaths.count > 0 {
                        self.publicViewsTableView.insertRows(at: indexPaths, with: .fade)
                        if self.addedOnce {
                            self.publicViewsTableView.scrollToRow(at: IndexPath(row: self.times.count-1, section: 0), at: .bottom, animated: true)
                        } else { self.addedOnce = true }
                    }
                    self.noViewsView.isHidden = true
                    self.activityIndicator.isHidden = true
                    self.publicViewsTableView.isHidden = false
                }
            }
            else {
                self.activityIndicator.isHidden = true
                self.noViewsView.isHidden = false
            }
        }
    }
    
    private func findAndDeleteView(postedAt time: String, withMessage message: String) {
        for i in 0..<times.count {
            if times[i] == time {
                views.removeValue(forKey: i)
                usernames.removeValue(forKey: i)
                times.removeValue(forKey: i)
                updateDictionaries(startIndex: i+1)
                publicViewsTableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .none)
                break
            }
        }
    }
    
    private func updateDictionaries(startIndex: Int) {
        var index = startIndex
        while(index <= times.count) {
            let time = times[index]
            let username = usernames[index]
            let view = views[index]
            views.removeValue(forKey: index)
            usernames.removeValue(forKey: index)
            times.removeValue(forKey: index)
            times[index - 1] = time
            usernames[index - 1] = username
            views[index - 1] = view
            index += 1
        }
    }
    
    private func calculateHeightForCellAt(indexPath: IndexPath) -> CGFloat {
        return 76 + computeFrameHeight(text: views[indexPath.row]!).height
    }
    
    private func computeFrameHeight(text: String) -> CGRect {
        let height: CGFloat = 9999
        let size = CGSize(width: 312, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    

}

//MARK: - Table View Methods

extension PublicViewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return views.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewsCell", for: indexPath) as! ViewsCell
        if usernames[indexPath.row] == Settings.userEmail {
            cell.otherUsername.isHidden = true
            cell.myUsername.isHidden = false
            cell.myUsername.text = self.usernames[indexPath.row]
            cell.message.textAlignment = .right
            cell.containerView.backgroundColor = #colorLiteral(red: 0.05561823398, green: 0.05572734773, blue: 0.06055086851, alpha: 1)
        }
        else {
            cell.myUsername.isHidden = true
            cell.otherUsername.isHidden = false
            cell.otherUsername.text = self.usernames[indexPath.row]
            cell.message.textAlignment = .left
            cell.containerView.backgroundColor = #colorLiteral(red: 0.2195822597, green: 0.2196257114, blue: 0.2195765674, alpha: 1)
        }
        cell.message.text = views[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let cell = self.publicViewsTableView.cellForRow(at: indexPath) as! ViewsCell
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            let copyAction = UIAction(
              title: "Copy",
              image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = cell.message.text
            }
            let deleteAction = UIAction(
              title: "Delete",
              image: UIImage(systemName: "trash"),
              attributes: .destructive) { _ in
                self.firestoreManager.delete(document: self.times[indexPath.row]!, fromCollection: "\(K.FStore.pathtoPublicViewsCollection)/\(self.publicViewsID)") { (error) in
                    if let error = error {
                        self.presentAlert(withTitle: K.UIText.errorString, message: error.localizedDescription)
                        print("error deleting view")
                        print(error)
                    }
                    else {
                        print("successfully deleted view")
                    }
                }
            }
            var children = [UIMenuElement]()
            children.append(copyAction)
            if cell.myUsername.text == Settings.userEmail { children.append(deleteAction) }
            return UIMenu(title: "", children: children)
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return calculateHeightForCellAt(indexPath: indexPath)
//    }
    
}

//MARK: - TextView Delegate Method

extension PublicViewsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if let keyboardHeight = keyboardHeight {
            publicViewsTableView.setContentOffset(CGPoint(x: publicViewsTableView.contentOffset.x, y: publicViewsTableView.contentOffset.y - keyboardHeight + publicViewsTableView.safeAreaInsets.bottom), animated: false)
        }
        self.typingViewBottomConstraint.constant = 0
        UIView.animate(withDuration: self.duration) {
            self.view.layoutIfNeeded()
        }
    }
}

//extension PublicViewsViewController: UIContextMenuInteractionDelegate {
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
//            let children = [UIMenuElement]()
//            return UIMenu(title: "", children: children)
//        }
//    }
//
//
//}
