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
    private let searchController = UISearchController(searchResultsController: nil)
    private let newsManager = NewsManager()
    private var newsImages = [Int : UIImage]()
    private var articles: [JSON] = []
    private var currentPage: Int = 1
    private var maxPages: Int = 5
    private var didAppearRanOnce: Bool = false
    var parentCategory: Bool = false
    var apiToCall: String = ""
    private var lastLoadedApi: String = Settings.worldApiURL
    private var loadNews: DispatchWorkItem?
    private var backgroundActivitiesToSuspend: [DispatchWorkItem] = []
    
    fileprivate var loadMoreActivityIndicator: LoadMoreActivityIndicator!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        
        if apiToCall.count < 1 {
            apiToCall = Settings.worldApiURL
        }
        
        worldCountryCollectionView.delegate = self
        worldCountryCollectionView.dataSource = self
        worldCountryCollectionView.register(UINib(nibName: "NewsCell", bundle: nil), forCellWithReuseIdentifier: "newsCell")
        toggleCollectionViewAndActivityIndicator(shouldViewAppear: false)
        loadMoreActivityIndicator = LoadMoreActivityIndicator(scrollView: worldCountryCollectionView, spacingFromLastCell: 10, spacingFromLastCellWhenLoadMoreActionStart: 60)
        
        searchController.searchBar.placeholder = "Search topic"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        
        if !parentCategory {
            navigationItem.title = Settings.isCountrySet ? Settings.currentCountry.name : "World"
        }
        else if Settings.isCountrySet {
            navigationItem.title = "\(Settings.currentCountry.name)/\(navigationItem.title!)"
        }
        
        loadNews = DispatchWorkItem {
            self.lastLoadedApi = self.apiToCall
            self.requestPerformer(url: self.apiToCall) { (data) in
                print("data received!!")
                self.parseNewsData(data)
            }
        }
        
        DispatchQueue.main.async(execute: loadNews!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view appeared!")
        if !parentCategory && lastLoadedApi != Settings.worldApiURL && didAppearRanOnce {
            print("last loaded api was not equal to global api")
            currentPage = 1
            DispatchQueue.main.async {
                self.worldCountryCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionView.ScrollPosition(rawValue: 0), animated: false)
                self.toggleCollectionViewAndActivityIndicator(shouldViewAppear: false)
            }
            navigationItem.title = Settings.isCountrySet ? Settings.currentCountry.name : "World"
            DispatchQueue.main.async {
                self.lastLoadedApi = Settings.worldApiURL
                self.requestPerformer(url: Settings.worldApiURL) { (data) in
                    print("data received!!")
                    self.parseNewsData(data)
                }
            }
//            lastLoadedApi = Settings.worldApiURL
//            apiToCall = Settings.worldApiURL
//            viewDidLoad()
        }
        tabBarController?.delegate = self
        didAppearRanOnce = true
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadNews?.cancel()
    }
    
    func parseNewsData(_ data: Data?) {
        if let safeData = data {
            do {
                let newsJSON: JSON = try JSON(data: safeData)
                articles.removeAll()
                newsImages.removeAll()
                articles = newsJSON["articles"].arrayValue
                DispatchQueue.main.async {
                    self.loadImages(articlesArray: self.articles, index: 0, newImagesCount: self.articles.count, imageArrayCount: self.newsImages.count)
                    print("appear settings will apply")
                    self.worldCountryCollectionView.reloadData()
                    self.toggleCollectionViewAndActivityIndicator(shouldViewAppear: true)
                }
                maxPages = Int(ceil(newsJSON["totalResults"].doubleValue/20))
            }
            catch { print("caught in parseNewsData: \(error)") }
        }
    }
    
    func loadNextPage(_ page: Int) {
        requestPerformer(url: (parentCategory ? apiToCall : Settings.worldApiURL) + "&page=\(page)") { (data) in
            if let safeData = data {
                do {
                    let newsJSON: JSON = try JSON(data: safeData)
                    let articlesCountBeforeAppend = self.articles.count
                    self.articles += newsJSON["articles"].arrayValue
                    DispatchQueue.main.async {
                        self.loadImages(articlesArray: newsJSON["articles"].arrayValue, index: 0, newImagesCount: newsJSON["articles"].arrayValue.count, imageArrayCount: articlesCountBeforeAppend)
                    }
                    var indexPaths: [IndexPath] = []
                    for i in articlesCountBeforeAppend..<self.articles.count {
                        indexPaths.append(IndexPath(row: i, section: 0))
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.loadMoreActivityIndicator.stop()
                    }
                    DispatchQueue.main.async {
                        self.worldCountryCollectionView.insertItems(at: indexPaths)
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
    
    
    func loadImages(articlesArray: [JSON], index: Int, newImagesCount: Int, imageArrayCount: Int) {
        requestPerformer(url: articlesArray[index]["urlToImage"].stringValue) { (data) in
            if let safeData = data {
                self.newsImages[imageArrayCount + index] = UIImage(data: safeData)
            }
            else {
                self.newsImages[imageArrayCount + index] = UIImage(imageLiteralResourceName: "xb1.png")
            }
            DispatchQueue.main.async {
                self.worldCountryCollectionView.reloadItems(at: [IndexPath(row: imageArrayCount + index, section: 0)])
            }
            if index + 1 < newImagesCount {
                self.loadImages(articlesArray: articlesArray, index: index + 1, newImagesCount: newImagesCount, imageArrayCount: imageArrayCount)
            }
        }
    }
    
    
    func toggleCollectionViewAndActivityIndicator(shouldViewAppear: Bool) {
        activityIndicator.isHidden = shouldViewAppear ? true : false
        worldCountryCollectionView.isHidden = shouldViewAppear ? false : true
    }
    
    
    func requestPerformer(url: String, callback: @escaping (Data?) -> Void) {
        DispatchQueue.main.async {
            if self.navigationController?.topViewController is WorldCountryViewController {
                self.newsManager.performRequest(url) { (data) in
                    callback(data)
                }
            }
        }
    }
}


//MARK: - CollectionView Methods

extension WorldCountryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsCell", for: indexPath) as! NewsCell
        cell.newsTitle.text = articles[indexPath.row]["title"].stringValue
        cell.newsDescription.text = articles[indexPath.row]["description"].stringValue
        cell.newsURL = articles[indexPath.row]["url"].stringValue
        
        if let image = newsImages[indexPath.row] {
            DispatchQueue.main.async {
                cell.newsImageView.image = image
                cell.activityIndicator.isHidden = true
            }
        }
//        else  {
//            DispatchQueue.main.async {
//                self.requestPerformer(url: self.articles[indexPath.row]["urlToImage"].stringValue) { (data) in
//                    DispatchQueue.main.async {
//                        if let safeData = data {
//                            cell.newsImageView.image = UIImage(data: safeData)
//                        }
//                        else {
//                            cell.newsImageView.image = UIImage(imageLiteralResourceName: "xb1.png")
//                        }
//                        cell.activityIndicator.isHidden = true
//                        self.newsImages[indexPath.row] = cell.newsImageView.image
//                    }
//                }
//            }
//        }
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
                let alert = UIAlertController(title: "Unable to open article", message: "The news URL is invalid.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 345, height: calculateHeightofCellAt(indexPath: indexPath))
    }
    
    func calculateHeightofCellAt(indexPath: IndexPath) -> CGFloat {
        let newsTitleHeight = computeFrameHeight(text: articles[indexPath.row]["title"].stringValue, isTitle: true).height
        let newsDescriptionHeight = computeFrameHeight(text: articles[indexPath.row]["description"].stringValue, isTitle: false).height
        return 309 + newsTitleHeight + newsDescriptionHeight
    }
    
    
    func computeFrameHeight(text: String, isTitle: Bool) -> CGRect {
        let height: CGFloat = 9999
        let size = CGSize(width: 305, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: isTitle ? 20 : 15, weight: isTitle ? UIFont.Weight.semibold : UIFont.Weight.regular)]
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    
    

    //MARK: - Scroll View Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMoreActivityIndicator.start {
            DispatchQueue.global(qos: .utility).async {
                if self.currentPage < self.maxPages {
                    self.currentPage += 1
                    self.loadNextPage(self.currentPage)
                }
                else {
                    DispatchQueue.main.async { [weak self] in
                        self?.loadMoreActivityIndicator.stop()
                    }
                }
//                sleep(10)
            }
        }
    }
    
}


//MARK: - Custom News Cell Delegate Method

extension WorldCountryViewController: NewsCellDelegate {
    func presentShareScreen(_ cell: NewsCell) {
        if let url = URL(string: cell.newsURL!) {
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            vc.overrideUserInterfaceStyle = .dark
            present(vc, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Error sharing article", message: "The news URL is invalid.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

//MARK: - TabBarController handling

extension WorldCountryViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("shouldSelect fired in worldCountryVC")
        if tabBarController.selectedViewController == viewController {
            if navigationController?.topViewController is WorldCountryViewController {
                worldCountryCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionView.ScrollPosition(rawValue: 0), animated: true)
                return false
            }
        }
        return true
    }
}
