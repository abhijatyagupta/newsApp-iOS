//
//  RealFakeViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 25/12/20.
//

import UIKit
import SafariServices

class RealFakeViewController: UIViewController {
    @IBOutlet weak var newsTitleView: UIView!
    @IBOutlet weak var newsTitleLabel: UILabel!
    
    @IBOutlet weak var markedViewContainer: UIStackView!
    @IBOutlet weak var unmarkedViewContainer: UIStackView!
    @IBOutlet weak var markedRealViewContainer: UIStackView!
    @IBOutlet weak var markedFakeViewContainer: UIStackView!
    
    @IBOutlet weak var markTheNewsLabel: UILabel!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    
    @IBOutlet weak var unmarkedRealView: UIView!
    @IBOutlet weak var unmarkedFakeView: UIView!
    @IBOutlet weak var unmarkedRealCount: UILabel!
    @IBOutlet weak var unmarkedFakeCount: UILabel!
    @IBOutlet weak var viewsAreHiddenView: UIView!
    @IBOutlet weak var markedRealView: UIView!
    @IBOutlet weak var markedRealCount: UILabel!
    @IBOutlet weak var shareButtonInRealView: UIButton!
    @IBOutlet weak var fakeCountLabelForRealView: UILabel!
    @IBOutlet weak var markedFakeView: UIView!
    @IBOutlet weak var markedFakeCount: UILabel!
    @IBOutlet weak var realCountLabelForFakeView: UILabel!
    @IBOutlet weak var publicViewsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let firestoreManager = FirestoreManager()
    private var timeInterval = 0.2
    var realCount = 0 {
        didSet {
            DispatchQueue.main.async {
                self.unmarkedRealCount.text = "\(self.realCount)"
                self.markedRealCount.text = "\(self.realCount)"
                self.cellForCurrentNews.realCount = self.realCount
                self.realCountLabelForFakeView.text = "\(self.realCount) \(K.UIText.realCountForFakeView)"
            }
        }
    }
    var fakeCount = 0 {
        didSet {
            DispatchQueue.main.async {
                self.unmarkedFakeCount.text = "\(self.fakeCount)"
                self.markedFakeCount.text = "\(self.fakeCount)"
                self.cellForCurrentNews.fakeCount = self.fakeCount
                self.fakeCountLabelForRealView.text = "\(self.fakeCount) \(K.UIText.fakeCountForRealView)"
            }
        }
    }
    
    var cellForCurrentNews: NewsCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.overrideUserInterfaceStyle = .dark
        overrideUserInterfaceStyle = .dark
        realCount = cellForCurrentNews.realCount
        fakeCount = cellForCurrentNews.fakeCount
        configureNewsTitle()
        configureUnmarkedView()
        configureRealMarkedView()
        configureFakeMarkedView()
        configurePublicViewsTableView()
        unmarkedViewContainer.isHidden = true
        markTheNewsLabel.isHidden = true
        decideWhichViewShouldAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //attach listener
        attachListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //detach listener
        firestoreManager.detachSnapshotListener()
    }
    
    //MARK: - IBActions
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func newsTitleTapped(_ sender: UIControl) {
        if let url = URL(string: cellForCurrentNews.newsURL!) {
            let vc = SFSafariViewController(url: url)
            vc.overrideUserInterfaceStyle = .dark
            present(vc, animated: true)
        }
        else {
            let alert = cellForCurrentNews.alertForUnavailableNews(title: K.UIText.articleOpenErrorTitle, message: K.UIText.shareErrorMessage)
            present(alert, animated: true)
        }
    }
    
    
    @IBAction func unmarkedRealViewTapped(_ sender: UIView) {
        hideUnmarkedAnd(markedFakeViewContainer) {
            self.toggleSpinner(shouldSpinnerAppear: true) {
                self.registerUpdate(isMarkReal: true) {
                    self.changeBarButtonAndLabelTo(originalState: false)
                    self.markTheNewsLabel.isHidden = false
                    UIView.animate(withDuration: self.timeInterval) {
                        self.markedViewContainer.alpha = 1
                        self.markTheNewsLabel.alpha = 1
                    }
                } failed: {
                    self.showUnmarkedView()
                }
            }
        }
    }                                       
    
    
    @IBAction func unmarkedFakeViewTapped(_ sender: UIView) {
        hideUnmarkedAnd(markedRealViewContainer) {
            self.toggleSpinner(shouldSpinnerAppear: true) {
                self.registerUpdate(isMarkReal: false) {
                    self.changeBarButtonAndLabelTo(originalState: false)
                    self.markTheNewsLabel.isHidden = false
                    UIView.animate(withDuration: self.timeInterval) {
                        self.markedViewContainer.alpha = 1
                        self.markTheNewsLabel.alpha = 1
                    }
                } failed: {
                    self.showUnmarkedView()
                }
            }
        }
    }
    
    
    @IBAction func shareButtonInRealViewTapped(_ sender: UIButton) {
        if let url = URL(string: cellForCurrentNews.newsURL!) {
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            vc.overrideUserInterfaceStyle = .dark
            present(vc, animated: true)
        }
        else {
            let alert = cellForCurrentNews.alertForUnavailableNews(title: K.UIText.shareErrorTitle, message: K.UIText.shareErrorMessage)
            present(alert, animated: true)
        }
    }
    
    @IBAction func leftBarButtonTapped(_ sender: UIBarButtonItem) {
        if leftBarButton.image == nil {
            toggleMarkedView(shouldViewAppear: false) { animationIsComplete in
                if animationIsComplete {
                    self.toggleSpinner(shouldSpinnerAppear: true) {
                        self.undoMark(wasMarkReal: self.markedFakeViewContainer.isHidden) {
                            self.showUnmarkedView()
                            self.changeBarButtonAndLabelTo(originalState: true)
                        } failed: {
                            self.toggleMarkedView(shouldViewAppear: true)
                        }
                    }
                }
            }
        }
        else {
            shareButtonInRealViewTapped(shareButtonInRealView)
        }
    }
    
    //MARK: - Firestore Methods
    
    private func registerUpdate(isMarkReal: Bool, succeeded: @escaping () -> Void, failed: @escaping () -> Void) {
        let document: [String : Any] = [
            K.API.url : cellForCurrentNews.newsURL as Any,
            K.FStore.fakeCount: fakeCount + (isMarkReal ? 0 : 1),
            K.FStore.realCount: realCount + (isMarkReal ? 1 : 0)
        ]
        let documentForUser: [String : Any] = [
            K.API.title: cellForCurrentNews.newsTitle.text as Any,
            K.API.description: cellForCurrentNews.newsDescription.text as Any,
            K.API.url: cellForCurrentNews.newsURL as Any,
            K.API.urlToImage: cellForCurrentNews.imageURL as Any,
            K.FStore.id: cellForCurrentNews.documentID as Any,
            K.FStore.markedAs: isMarkReal ? "real" : "fake",
            K.FStore.time: (Int64)(NSDate().timeIntervalSince1970 * 1000) as Any
        ]
        var addedToMarkedNews: Bool = false
        var addedToUserCollection: Bool = false
        
        firestoreManager.add(document: documentForUser, toCollection: Settings.userEmail, withName: cellForCurrentNews.documentID!) { (error) in
            addedToUserCollection = error == nil
            if error != nil {
                print("error occurred while adding to user collection")
            }
            else {
                print("successfully added to user collection: \(addedToUserCollection)")
            }
        }
        firestoreManager.add(document: document, withName: cellForCurrentNews.documentID!) { error in
            addedToMarkedNews = error == nil
            if error != nil {
                print("error occurred while adding to markedNews collection")
            }
            else {
                print("successfully added to markedNews collection: \(addedToUserCollection)")
            }
            self.finishUpdate(addingToMarkNewsSucceeded: addedToMarkedNews, addingToUserCollectionSucceded: addedToUserCollection, error: error, succeeded: succeeded, failed: failed)
        }
    }
    
    private func undoMark(wasMarkReal: Bool, succeeded: @escaping () -> Void, failed: @escaping () -> Void) {
        deleteDocument(fromCollection: Settings.userEmail, succeeded: succeeded, failed: failed)
        print("realCount: \(realCount)")
        print("fakeCount: \(fakeCount)")
        if (realCount == 0 && fakeCount == 1) || (realCount == 1 && fakeCount == 0) {
            deleteDocument(succeeded: succeeded, failed: failed)
            return
        }
        let data: [AnyHashable : Any] = [
            (wasMarkReal ? K.FStore.realCount : K.FStore.fakeCount) : (wasMarkReal ? realCount - 1 : fakeCount - 1)
        ]
        firestoreManager.update(document: cellForCurrentNews.documentID!, withData: data) { error in
            self.toggleSpinner(shouldSpinnerAppear: false)
            print("updating db..")
            if let error = error {
                failed()
                print(error)
                self.presentAlert(withTitle: K.UIText.errorString, message: error.localizedDescription)
            }
            else {
                print("mark undid")
                succeeded()
            }
        }
    }
    
    private func deleteDocument(fromCollection collection: String = "markedNews", succeeded: @escaping () -> Void, failed: @escaping () -> Void) {
        print("proceeding to delete document from \(collection)..")
        firestoreManager.delete(document: cellForCurrentNews.documentID!, fromCollection: collection) { error in
            self.toggleSpinner(shouldSpinnerAppear: false)
            if let error = error {
                failed()
                print(error)
                self.presentAlert(withTitle: K.UIText.errorString, message: error.localizedDescription)
            }
            else {
                print("data successfully deleted from \(collection)")
                succeeded()
            }
        }
    }
    
    
    //MARK: - Helper Methods
    
    private func decideWhichViewShouldAppear() {
        firestoreManager.get(document: cellForCurrentNews.documentID!, fromCollection: Settings.userEmail) { (document, error) in
            self.toggleSpinner(shouldSpinnerAppear: false, customInterval: 0)
            if let document = document, document.exists {
                if let data = document.data() {
                    if let mark = data["markedAs"] as? String {
                        if mark == "real" {
                            self.hideUnmarkedAnd(self.markedFakeViewContainer, customInterval: 0) {
                                self.changeBarButtonAndLabelTo(originalState: false)
                                self.markTheNewsLabel.isHidden = false
                                UIView.animate(withDuration: 0) {
                                    self.markedViewContainer.alpha = 1
                                    self.markTheNewsLabel.alpha = 1
                                }
                            }
                        }
                        else {
                            self.hideUnmarkedAnd(self.markedRealViewContainer, customInterval: 0) {
                                self.changeBarButtonAndLabelTo(originalState: false)
                                self.markTheNewsLabel.isHidden = false
                                UIView.animate(withDuration: 0) {
                                    self.markedViewContainer.alpha = 1
                                    self.markTheNewsLabel.alpha = 1
                                }
                            }
                        }
                        return
                    }
                }
                if let error = error {
                    self.presentAlert(withTitle: K.UIText.errorString, message: error.localizedDescription) {
                        self.dismiss(animated: true)
                    }
                }
            }
            else {
                self.markTheNewsLabel.isHidden = false
                self.unmarkedViewContainer.isHidden = false
            }
        }
    }
    
    
    private func finishUpdate(addingToMarkNewsSucceeded: Bool, addingToUserCollectionSucceded: Bool, error: Error? = nil, succeeded: @escaping () -> Void, failed: @escaping () -> Void) {
        print("finishing update..")
        self.toggleSpinner(shouldSpinnerAppear: false)
        if addingToMarkNewsSucceeded && addingToUserCollectionSucceded {
            succeeded()
            return
        }
        else if addingToMarkNewsSucceeded && !addingToUserCollectionSucceded {
            deleteDocument(succeeded: succeeded, failed: failed)
        }
        else if addingToUserCollectionSucceded && !addingToMarkNewsSucceeded {
            deleteDocument(fromCollection: Settings.userEmail, succeeded: succeeded, failed: failed)
        }
        if let error = error {
            print(error)
            presentAlert(withTitle: K.UIText.errorString, message: error.localizedDescription)
        }
        failed()
    }
    
    private func attachListener() {
        firestoreManager.addSnapshotListener(forDocument: cellForCurrentNews.documentID!) { (document, error) in
            if let error = error {
                print("listener detached due to error:")
                print(error)
                print("re-attaching listener..")
                self.attachListener()
            }
            else if let doesDocumentExists = document?.exists {
                if !doesDocumentExists {
                    print("document does not exist")
                    self.realCount = 0
                    self.fakeCount = 0
                }
                else if let data = document?.data() {
                    print("listened")
                    self.realCount = data["realCount"] as? Int ?? 0
                    self.fakeCount = data["fakeCount"] as? Int ?? 0
                }
            }
        }
    }
    
    private func toggleSpinner(shouldSpinnerAppear: Bool, customInterval: Double? = nil, callback: @escaping () -> Void = {}) {
        UIView.animate(withDuration: customInterval ?? timeInterval) {
            self.activityIndicator.alpha = shouldSpinnerAppear ? 1 : 0
        } completion: { (animationIsComplete) in
            self.activityIndicator.isHidden = !shouldSpinnerAppear
            callback()
        }
    }
    
    private func showUnmarkedView() {
        self.markedViewContainer.isHidden = true
        self.markedRealViewContainer.isHidden = false
        self.markedFakeViewContainer.isHidden = false
        self.unmarkedViewContainer.isHidden = false
        self.markTheNewsLabel.isHidden = false
        UIView.animate(withDuration: timeInterval) {
            self.unmarkedViewContainer.alpha = 1
            self.markTheNewsLabel.alpha = 1
        }
    }
    
    private func toggleMarkedView(shouldViewAppear: Bool, completion: @escaping ((Bool) -> Void) = { _ in }) {
        UIView.animate(withDuration: timeInterval) {
            self.markedViewContainer.alpha = shouldViewAppear ? 1 : 0
            self.markTheNewsLabel.alpha = shouldViewAppear ? 1 : 0
        } completion: { (animationIsComplete) in
            self.markTheNewsLabel.isHidden = shouldViewAppear
            completion(animationIsComplete)
        }

    }
    
    private func hideUnmarkedAnd(_ viewToHide: UIView, customInterval: Double? = nil, callback: @escaping () -> Void = {}) {
        UIView.animate(withDuration: customInterval ?? timeInterval) {
            self.unmarkedViewContainer.alpha = 0
            self.markTheNewsLabel.alpha = 0
        } completion: { (animationIsComplete) in
            if animationIsComplete {
                self.unmarkedViewContainer.isHidden = true
                self.markTheNewsLabel.isHidden = true
                viewToHide.isHidden = true
                self.markedViewContainer.isHidden = false
                callback()
            }
        }
    }
    
    private func changeBarButtonAndLabelTo(originalState: Bool) {
        markTheNewsLabel.text = originalState ? K.UIText.markThisNews : K.UIText.newsMarked
        leftBarButton.title = originalState ? nil : K.UIText.undoMark
        leftBarButton.image = originalState ? UIImage(systemName: "square.and.arrow.up") : nil
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
    
    //MARK: - Configure methods that run at viewDidLoad
    
    private func configureNewsTitle() {
        newsTitleView.layer.cornerRadius = 20
        newsTitleLabel.text = cellForCurrentNews.newsTitle.text
    }
    
    
    private func configureUnmarkedView() {
        configureViewBorder(view: unmarkedRealView, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        configureViewBorder(view: unmarkedFakeView, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        viewsAreHiddenView.layer.cornerRadius = 20
    }
    
    private func configureRealMarkedView() {
        configureViewBorder(view: markedRealView, color: #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1))
        shareButtonInRealView.layer.cornerRadius = 10
        
    }
    
    private func configureFakeMarkedView() {
        configureViewBorder(view: markedFakeView, color: #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1))
        
    }
    
    
    private func configurePublicViewsTableView() {
        publicViewsTableView.delegate = self
        publicViewsTableView.dataSource = self
    }
    
    
    private func configureViewBorder(view: UIView, color: CGColor) {
        view.layer.borderColor = color
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 20
    }

}

//MARK: - Table View Methods

extension RealFakeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "publicViews")!
        cell.textLabel?.text = K.UIText.publicViews
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return K.UIText.publicViewsFooter
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showPublicViews", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPublicViews" {
            let vc = segue.destination as! PublicViewsViewController
            vc.publicViewsID = cellForCurrentNews.documentID ?? ""
        }
    }
}
