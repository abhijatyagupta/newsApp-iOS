//
//  WorldCountryViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 21/10/20.
//

import UIKit
import SwiftyJSON
import SafariServices

class WorldCountryViewController: UIViewController {
    @IBOutlet weak var worldCountryCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var recentSearchesTableView: RecentSearchesTableView!
    @IBOutlet weak var zeroResultsView: UIView!
    private let searchController = UISearchController()
    private let networkManager = NetworkManager()
    private var newsImages = [Int : UIImage]()
    private var articles: [JSON] = []
    private var currentPage: Int = 1
    private var maxPages: Int = 5
    private var didAppearRanOnce: Bool = false
    private var attachingListenerFirstTime: Bool = true
    var parentCategory: Bool = false
    var isSearchResultInstance = false
    var apiToCall: String = ""
    private var lastLoadedApi: String = Settings.worldApiURL
    private var loadMoreActivityIndicator: LoadMoreActivityIndicator!
    private let recentSearches = RecentSearches()
    private let firestoreManager = FirestoreManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        
        if apiToCall.count < 1 {
            apiToCall = Settings.worldApiURL
        }
        
        worldCountryCollectionView.delegate = self
        worldCountryCollectionView.dataSource = self
        if !isSearchResultInstance { setupSearch() }
        worldCountryCollectionView.register(UINib(nibName: "NewsCell", bundle: nil), forCellWithReuseIdentifier: "newsCell")
        toggleCollectionViewAndActivityIndicator(shouldViewAppear: false)
        loadMoreActivityIndicator = LoadMoreActivityIndicator(scrollView: worldCountryCollectionView, spacingFromLastCell: 10, spacingFromLastCellWhenLoadMoreActionStart: 60)
        
        setTitle()
        
        DispatchQueue.main.async {
            self.lastLoadedApi = self.apiToCall
            print("news request sent")
            self.requestPerformer(url: self.apiToCall) { (data) in
                print("data received!!")
                self.parseNewsData(data)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view appeared!")
        if !parentCategory && lastLoadedApi != Settings.worldApiURL && didAppearRanOnce {
            if !zeroResultsView.isHidden {
                DispatchQueue.main.async {
                    self.zeroResultsView.isHidden = true
                }
            }
            print("last loaded api was not equal to global api")
            currentPage = 1
            DispatchQueue.main.async {
                self.scrollToTop()
                self.toggleCollectionViewAndActivityIndicator(shouldViewAppear: false)
                self.loadMoreActivityIndicator.stop()
            }
            navigationItem.title = Settings.isCountrySet ? Settings.currentCountry.name : K.UIText.worldString
            DispatchQueue.main.async {
                self.lastLoadedApi = Settings.worldApiURL
                self.requestPerformer(url: Settings.worldApiURL) { (data) in
                    print("data received!!")
                    self.parseNewsData(data)
                }
            }
        }
        tabBarController?.delegate = self
        didAppearRanOnce = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !recentSearchesTableView.isHidden {
            print("search will become first responder")
            DispatchQueue.main.async {
                if self.recentSearches.count == 0 {
                    self.recentSearchesTableView.reloadData()
                }
                self.searchController.searchBar.becomeFirstResponder()
                self.setTitle()
            }
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
    }
    
    
    //MARK: - Scroll View Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if currentPage < maxPages {
            loadMoreActivityIndicator.start {
                DispatchQueue.global(qos: .utility).async {
                    self.currentPage += 1
                    self.loadNextPage(self.currentPage)
                }
            }
        }
    }
    
    //MARK: - Helper Methods
    
    
    private func setTitle() {
        if !parentCategory {
            navigationItem.title = Settings.isCountrySet ? Settings.currentCountry.name : K.UIText.worldString
        }
        else if Settings.isCountrySet, !isSearchResultInstance {
            navigationItem.title = "\(Settings.currentCountry.name)/\(navigationItem.title!)"
        }
    }
    
    private func scrollToTop() {
        worldCountryCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionView.ScrollPosition(rawValue: 0), animated: false)
    }
    
    
    private func setupSearch() {
        recentSearchesTableView.recentSearchesCustomDelegate = self
        searchController.searchBar.placeholder = K.UIText.searchPlaceholder
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func parseNewsData(_ data: Data?) {
        if let safeData = data {
            do {
                let newsJSON: JSON = try JSON(data: safeData)
                articles.removeAll()
                newsImages.removeAll()
                articles = newsJSON[K.API.articles].arrayValue
                print("number of articles: \(articles.count)")
                if articles.count == 0 {
                    DispatchQueue.main.async {
                        self.zeroResultsView.isHidden = false
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.loadImages(self.articles, 0, self.articles.count, self.newsImages.count)
                    print("appear settings will apply")
                    self.worldCountryCollectionView.reloadData()
                    self.toggleCollectionViewAndActivityIndicator(shouldViewAppear: true)
                }
                let totalResults: Double = newsJSON[K.API.totalResults].doubleValue
                maxPages = totalResults > 100 ? 5 : Int(ceil(totalResults/20))
            }
            catch { print("caught in parseNewsData: \(error)") }
        }
        else {
            DispatchQueue.main.async {
                self.zeroResultsView.isHidden = false
            }
        }
    }
    
    private func loadNextPage(_ page: Int) {
        requestPerformer(url: (parentCategory ? apiToCall : Settings.worldApiURL) + "&page=\(page)") { (data) in
            if let safeData = data {
                do {
                    let newsJSON: JSON = try JSON(data: safeData)
                    let articlesCountBeforeAppend = self.articles.count
                    let newArticles = newsJSON[K.API.articles].arrayValue
                    self.articles += newArticles
                    print("new articles: \(self.articles.count - articlesCountBeforeAppend)")
                    var indexPaths: [IndexPath] = []
                    for i in articlesCountBeforeAppend..<self.articles.count {
                        indexPaths.append(IndexPath(row: i, section: 0))
                    }
                    DispatchQueue.main.async {
                        self.loadMoreActivityIndicator.stop()
                        self.worldCountryCollectionView.insertItems(at: indexPaths)
                        self.loadImages(newArticles, 0, newArticles.count, articlesCountBeforeAppend)
                    }
                }
                catch {
                    print("error parsing json object for next page: \(error)")
                }
            }
            else {
                print("next page didn't load")
            }
        }
    }
    
    
    private func loadImages(_ articlesArray: [JSON], _ index: Int, _ newImagesCount: Int, _ imageArrayCount: Int) {
        let imageURL = articlesArray[index][K.API.urlToImage].stringValue
        let row = imageArrayCount + index
        requestPerformer(url: imageURL) { (data) in
            DispatchQueue.main.async {
                self.newsImages[row] = data == nil ? UIImage(imageLiteralResourceName: "xb1.png") : UIImage(data: data!)
                self.worldCountryCollectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
            }
            if index + 1 < newImagesCount {
                self.loadImages(articlesArray, index + 1, newImagesCount, imageArrayCount)
            }
        }
    }
    
    
    private func toggleCollectionViewAndActivityIndicator(shouldViewAppear: Bool) {
        activityIndicator.isHidden = shouldViewAppear
        worldCountryCollectionView.isHidden = !shouldViewAppear
    }
    
    
    private func requestPerformer(url: String, callback: @escaping (Data?) -> Void) {
        DispatchQueue.main.async {
            if self.navigationController?.topViewController is WorldCountryViewController {
                self.networkManager.performRequest(url) { (data) in
                    callback(data)
                }
            }
        }
    }

//    private func presentAlertWith(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: K.UIText.okString, style: .default))
//        self.present(alert, animated: true)
//    }
    
    private func calculateHeightofCellAt(indexPath: IndexPath) -> CGFloat {
        let newsTitleHeight = computeFrameHeight(text: articles[indexPath.row][K.API.title].stringValue, isTitle: true).height
        let newsDescriptionHeight = computeFrameHeight(text: articles[indexPath.row][K.API.description].stringValue, isTitle: false).height
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
//                    print("error attaching listener to cell")
                    print(error)
//                    print("re-attaching listener..")
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
    
    private func attachCellListenerToUserCollection(cell: NewsCell, indexPath: IndexPath) {
        cell.firestoreManagerForCell.secondListener = firestoreManager.getNewListener(forDocument: cell.documentID!, fromCollection: Settings.userEmail) { (document, error) in
            if let error = error {
                print("error attaching cell listener to user collection")
                print(error)
                return
            }
            if let document = document {
                if document.exists, let data = document.data() {
                    DispatchQueue.main.async {
                        cell.realLabel.textColor = data[K.FStore.markedAs] as? String == "real" ? #colorLiteral(red: 0, green: 0.4780980349, blue: 1, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                        cell.fakeLabel.textColor = data[K.FStore.markedAs] as? String == "real" ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0, green: 0.4780980349, blue: 1, alpha: 1)
                    }
                }
                else if !document.exists {
                    DispatchQueue.main.async {
                        cell.realLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                        cell.fakeLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    }
                }
            }
        }
    }
    
//    private func attachListener() {
//        firestoreManager.addCollectionListener(forCollection: K.FStore.markedNewsCollection) { (querySnapshot, error) in
//            if let error = error {
//                print("error attaching listener")
//                print(error.localizedDescription)
//            }
//            else {
//                if self.attachingListenerFirstTime {
//                    self.attachingListenerFirstTime = false
//                    print("listener ran for the first time")
//                    return
//                }
//                if let querySnapshot = querySnapshot {
//                    print("snapshot received")
//                    querySnapshot.documentChanges.forEach { diff in
//                        let data = diff.document.data()
//                        var index = 0
//                        for i in 0..<self.articles.count {
//                            if self.articles[i][K.API.url].string == data[K.API.url] as? String {
//                                index = i
//                                let realCount = diff.type == .removed ? 0 : data[K.FStore.realCount] as! Int
//                                let fakeCount = diff.type == .removed ? 0 : data[K.FStore.fakeCount] as! Int
//                                self.marks[index] = Mark(realCount: realCount, fakeCount: fakeCount)
//                                self.worldCountryCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
//                                break
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    
//    private func getRealFakeCountFor(documentId: String, index: Int, callback: @escaping () -> Void) {
//        print("updating count")
//        firestoreManager.get(document: documentId) { (document, error) in
//            if let error = error {
//                print("error getting document")
//                print(error.localizedDescription)
//                return
//            }
//            if let document = document {
//                if let data = document.data(), document.exists {
//                    let realCount = data[K.FStore.realCount] as! Int
//                    let fakeCount = data[K.FStore.fakeCount] as! Int
//                    let mark = Mark(realCount: realCount, fakeCount: fakeCount)
//                    self.marks[index] = mark
//                }
//                else if !document.exists {
//                    self.marks[index] = Mark(realCount: 0, fakeCount: 0)
//                }
//            }
//            callback()
//        }
//    }
    
}


//MARK: - CollectionView Methods

extension WorldCountryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsCell", for: indexPath) as! NewsCell
        let currentArticle = articles[indexPath.row]
        cell.documentID = currentArticle[K.API.publishedAt].stringValue + " " + currentArticle[K.API.source][K.API.name].stringValue
        cell.newsTitle.text = currentArticle[K.API.title].stringValue
        cell.newsDescription.text = currentArticle[K.API.description].stringValue
        cell.newsURL = currentArticle[K.API.url].string
        cell.imageURL = currentArticle[K.API.urlToImage].string
        if let image = newsImages[indexPath.row] {
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
        if let cell = cell as? NewsCell {
            attachListenerTo(cell: cell)
            if Settings.isUserSignedIn {
                attachCellListenerToUserCollection(cell: cell, indexPath: indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? NewsCell {
            cell.firestoreManagerForCell.detachSnapshotListener()
            cell.firestoreManagerForCell.detach(thisListener: cell.firestoreManagerForCell.secondListener)
            cell.realFakeActivityIndicator.isHidden = false
            cell.realFakeStackView.isHidden = true
            cell.realFakeButton.isUserInteractionEnabled = false
        }
    }
}


//MARK: - Custom News Cell Delegate Method

extension WorldCountryViewController: NewsCellDelegate {
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


//MARK: - TabBarController handling

extension WorldCountryViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("shouldSelect fired in worldCountryVC")
        if tabBarController.selectedViewController == viewController {
            if navigationController?.topViewController is WorldCountryViewController {
                scrollToTop()
                return false
            }
        }
        return true
    }
}


//MARK: - Custom Recent Searches Delegate Method

extension WorldCountryViewController: RecentSearchesCustomDelegate {
    func presentNewsFor(query: String) {
        navigationItem.title = K.UIText.searchString
        let vc = recentSearches.resultsViewControllerFor(query: query)
        show(vc, sender: self)
    }
}


//MARK: - Search Bar Methods

extension WorldCountryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let safeQuery = searchBar.searchTextField.text {
            let trimmedQuery = safeQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            recentSearches.add(search: trimmedQuery)
            presentNewsFor(query: trimmedQuery)
            recentSearchesTableView.reloadData()
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        recentSearchesTableView.reloadData()
        recentSearchesTableView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.recentSearchesTableView.alpha = 1
        } completion: { (animationIsComplete) in
            self.worldCountryCollectionView.alpha = 0
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        worldCountryCollectionView.alpha = 1
        UIView.animate(withDuration: 0.2) {
            self.recentSearchesTableView.alpha = 0
        } completion: { (animationIsComplete) in
            if animationIsComplete {
                self.recentSearchesTableView.isHidden = true
            }
        }
    }
    
}
