//
//  MarkedViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 30/12/20.
//
//CONTAINS A LOT OF REPETITIVE CODE FROM WorldCountryViewController.swift
//NEEDS OPTIMIZATION


import UIKit
import SafariServices
import Firebase

class MarkedViewController: UIViewController {
    
    @IBOutlet weak var signedOutView: SignedOutView!
    @IBOutlet weak var markedCollectionView: UICollectionView!
    @IBOutlet weak var zeroResultsView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var titles = [String?]()
    private var descriptions = [String?]()
    private var urls = [String?]()
    private var imageUrls = [String?]()
    private var markedAses = [String]()
    private var ids = [String]()
    private var images = [Int : UIImage?]()
    private let firestoreManager = FirestoreManager()
    private let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signedOutView.delegate = self
        markedCollectionView.delegate = self
        markedCollectionView.dataSource = self
        markedCollectionView.register(UINib(nibName: "NewsCell", bundle: nil), forCellWithReuseIdentifier: "newsCell")
        addStateChangeListener()
    }
    
}



//MARK: - Collection View Methods

extension MarkedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsCell", for: indexPath) as! NewsCell
        cell.newsTitle.text = titles[indexPath.row]
        cell.newsDescription.text = descriptions[indexPath.row]
        cell.newsURL = urls[indexPath.row]
        cell.imageURL = imageUrls[indexPath.row]
        cell.documentID = ids[indexPath.row]
        cell.realLabel.textColor = markedAses[indexPath.row] == "real" ? #colorLiteral(red: 0, green: 0.4780980349, blue: 1, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.fakeLabel.textColor = markedAses[indexPath.row] == "real" ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0, green: 0.4780980349, blue: 1, alpha: 1)
        if let image = images[indexPath.row] {
            DispatchQueue.main.async {
                cell.newsImageView.image = image
                cell.activityIndicator.isHidden = true
            }
        }
        else {
            cell.newsImageView.image = nil
            cell.activityIndicator.isHidden = false
        }
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) as? NewsCell {
            if let url = URL(string: cell.newsURL!) {
                let vc = SFSafariViewController(url: url)
                vc.overrideUserInterfaceStyle = .dark
                present(vc, animated: true)
            }
            else {
                let alert = cell.alertForUnavailableNews(title: K.UIText.articleOpenErrorTitle, message: K.UIText.shareErrorMessage)
                present(alert, animated: true)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 345, height: calculateHeightofCellAt(indexPath: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("cell will display")
        if let cell = cell as? NewsCell {
            attachListenerTo(cell: cell)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("cell ended displaying")
        if let cell = cell as? NewsCell {
            cell.firestoreManagerForCell.detachSnapshotListener()
            cell.realFakeActivityIndicator.isHidden = false
            cell.realFakeStackView.isHidden = true
            cell.realFakeButton.isUserInteractionEnabled = false
        }
    }


}
    
//MARK: - Custom News Cell Delegate Method

extension MarkedViewController: NewsCellDelegate {
    func showSignedOutView(_ cell: NewsCell) {
        performSegue(withIdentifier: "signedOutSegue", sender: cell)
    }
    
    func showRealFakeScreen(_ cell: NewsCell) {
        performSegue(withIdentifier: "showRealFakeScreen", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRealFakeScreen" {
            let parentVC = segue.destination as! UINavigationController
            let vc = parentVC.children.first as! RealFakeViewController
            let cell = sender as! NewsCell
            vc.cellForCurrentNews = cell
        }
    }
    
    func presentShareScreen(_ cell: NewsCell) {
        if let url = URL(string: cell.newsURL!) {
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            vc.overrideUserInterfaceStyle = .dark
            present(vc, animated: true)
        }
        else {
            let alert = cell.alertForUnavailableNews(title: K.UIText.shareErrorTitle, message: K.UIText.shareErrorMessage)
            present(alert, animated: true)
        }
    }
    
    
}

//MARK: - Helper Methods

extension MarkedViewController {
    
    private func calculateHeightofCellAt(indexPath: IndexPath) -> CGFloat {
        let newsTitleHeight = computeFrameHeight(text: titles[indexPath.row] ?? "", isTitle: true).height
        let newsDescriptionHeight = computeFrameHeight(text: descriptions[indexPath.row] ?? "", isTitle: false).height
        return 309 + newsTitleHeight + newsDescriptionHeight
    }
    
    
    private func computeFrameHeight(text: String, isTitle: Bool) -> CGRect {
        let height: CGFloat = 9999
        let size = CGSize(width: 305, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: isTitle ? 20 : 15, weight: isTitle ? UIFont.Weight.semibold : UIFont.Weight.regular)]
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    
    private func attachListenerTo(cell: NewsCell) {
//        print("attempt to attach listener to cell")
        if let documentID = cell.documentID {
            cell.firestoreManagerForCell.addSnapshotListener(forDocument: documentID) { (document, error) in
                if let error = error {
                    print(error)
                    self.attachListenerTo(cell: cell)
                }
                else if let doesDocumentExists = document?.exists {
                    if !doesDocumentExists {
                        cell.realCount = 0
                        cell.fakeCount = 0
                    }
                    else if let data = document?.data() {
                        cell.realCount = data["realCount"] as? Int ?? 0
                        cell.fakeCount = data["fakeCount"] as? Int ?? 0
                    }
                }
                cell.realFakeActivityIndicator.isHidden = true
                cell.realFakeStackView.isHidden = false
                cell.realFakeButton.isUserInteractionEnabled = true
            }
        }
    }
    
    private func addStateChangeListener() {
        Auth.auth().addStateDidChangeListener { (Auth, user) in
            self.firestoreManager.detachSnapshotListener()
            self.markedCollectionView.isHidden = true
            self.zeroResultsView.isHidden = true
            self.toggleSignedOutView(shouldViewAppear: false)
            self.activityIndicator.isHidden = false
            if user == nil {
                self.activityIndicator.isHidden = true
                self.toggleSignedOutView(shouldViewAppear: true)
            }
            else {
                self.addListenerToCollection()
            }
        }
    }
    
    
    private func addListenerToCollection() {
        firestoreManager.addCollectionListener(forCollection: Settings.userEmail, andOrderBy: K.FStore.time) { (querySnapshot, error) in
            if error != nil {
                print("error")
                self.markedCollectionView.isHidden = true
                self.activityIndicator.isHidden = true
                self.zeroResultsView.isHidden = false
                self.presentAlert(withTitle: K.UIText.errorString, message: error!.localizedDescription)
                return
            }
            if let querySnapshot = querySnapshot {
                let imageArrayCountBeforeAppend = self.images.count
                var index = 0
                var indexPaths = [IndexPath]()
                querySnapshot.documentChanges.forEach { diff in
                    if diff.type == .added {
                        self.addDocument(document: diff.document.data())
                        indexPaths.append(IndexPath(row: imageArrayCountBeforeAppend + index, section: 0))
                        index += 1
                    }
                    if diff.type == .removed {
                        self.removeDocument(atIndex: self.ids.firstIndex(of: diff.document.documentID))
                    }
                }
                if !querySnapshot.isEmpty {
                    DispatchQueue.main.async {
                        self.zeroResultsView.isHidden = true
                        if indexPaths.count > 0 {
                            self.markedCollectionView.insertItems(at: indexPaths)
                        }
                        self.activityIndicator.isHidden = true
                        self.markedCollectionView.isHidden = false
                        self.loadImages(index: imageArrayCountBeforeAppend)
                        return
                    }
                }
                else {
                    self.markedCollectionView.isHidden = true
                    self.activityIndicator.isHidden = true
                    self.zeroResultsView.isHidden = false
                }
            }
            else {
                self.markedCollectionView.isHidden = true
                self.activityIndicator.isHidden = true
                self.zeroResultsView.isHidden = false
            }
        }
    }
    
    
    private func loadImages(index: Int) {
        if index >= imageUrls.count { return }
        if let imageURL = imageUrls[index] {
            networkManager.performRequest(imageURL) { (data) in
                DispatchQueue.main.async {
                    self.images[index] = data == nil ? UIImage(imageLiteralResourceName: "xb1.png") : UIImage(data: data!)
                    self.markedCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                }
            }
        }
        else {
            images[index] = UIImage(imageLiteralResourceName: "xb1.png")
            DispatchQueue.main.async {
                self.markedCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
        loadImages(index: index + 1)
    }
    
    private func addDocument(document: [String : Any]) {
        titles.append(document[K.API.title] as? String)
        descriptions.append(document[K.API.description] as? String)
        urls.append(document[K.API.url] as? String)
        imageUrls.append(document[K.API.urlToImage] as? String)
        markedAses.append(document[K.FStore.markedAs] as! String)
        ids.append(document[K.FStore.id] as! String)
    }
    
    private func removeDocument(atIndex: Int?) {
        if let index = atIndex {
            titles.remove(at: index)
            descriptions.remove(at: index)
            urls.remove(at: index)
            imageUrls.remove(at: index)
            markedAses.remove(at: index)
            ids.remove(at: index)
            images.removeValue(forKey: index)
            updateImageDictionary(startIndex: index+1)
            markedCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    //INEFFICIENT METHOD TO UPDATE KEYS IN DICTIONARY, MAYBE TRY USING SOME OTHER DATA STRUCTURE FOR STORING IMAGES
    private func updateImageDictionary(startIndex: Int) {
        var index = startIndex
        while(index <= images.count) {
            let image = images[index]
            images.removeValue(forKey: index)
            images[index-1] = image
            index += 1
        }
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
    
    private func toggleSignedOutView(shouldViewAppear: Bool) {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.isHidden = shouldViewAppear
            self.signedOutView.isHidden = !shouldViewAppear
        }
    }
    
}


//MARK: - Signed Out View Delegate Methods

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
