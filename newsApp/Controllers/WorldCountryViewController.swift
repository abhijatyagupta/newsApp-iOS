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
    
    var didAppearRanOnce: Bool = false
    var parentCategory: Bool = false
    var apiToCall: String = ""
    var lastLoadedApi: String = Settings.worldApiURL
    private var loadNews: DispatchWorkItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        
        if apiToCall.count < 1 {
            apiToCall = Settings.worldApiURL
        }
        
        worldCountryCollectionView.delegate = self
        worldCountryCollectionView.dataSource = self
        worldCountryCollectionView.register(UINib(nibName: "NewsCell", bundle: nil), forCellWithReuseIdentifier: "newsCell")
        worldCountryCollectionView.isHidden = true
        
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
            self.newsManager.performRequest(self.apiToCall) { (data) in
                print("data received!!")
                self.fetchNews(data)
            }
        }
        DispatchQueue.main.async(execute: loadNews!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view appeared!")
        if !parentCategory && lastLoadedApi != Settings.worldApiURL && didAppearRanOnce {
            print("last loaded api was not equal to global api")
            worldCountryCollectionView.isHidden = true
            activityIndicator.isHidden = false
            navigationItem.title = Settings.isCountrySet ? Settings.currentCountry.name : "World"
            DispatchQueue.main.async {
                self.lastLoadedApi = Settings.worldApiURL
                self.newsManager.performRequest(Settings.worldApiURL) { (data) in
                    print("data received!!")
                    self.fetchNews(data)
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
    
    
    
    func fetchNews(_ data: Data?) {
        if let safeData = data {
            do {
                let newsJSON: JSON = try JSON(data: safeData)
                articles.removeAll()
                newsImages.removeAll()
                articles = newsJSON["articles"].arrayValue
            } catch { print(error) }
        }
        DispatchQueue.main.async {
            print("appear settings will apply")
            self.worldCountryCollectionView.reloadData()
            self.activityIndicator.isHidden = true
            self.worldCountryCollectionView.isHidden = false
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
            cell.newsImageView.image = image
            cell.activityIndicator.isHidden = true
        }
        else  {
            DispatchQueue.main.async {
                self.newsManager.performRequest(self.articles[indexPath.row]["urlToImage"].stringValue) { (data) in
                    DispatchQueue.main.async {
                        if let safeData = data {
                            cell.newsImageView.image = UIImage(data: safeData)
                        }
                        else {
                            cell.newsImageView.image = UIImage(imageLiteralResourceName: "xb1.png")
                        }
                        cell.activityIndicator.isHidden = true
                        self.newsImages[indexPath.row] = cell.newsImageView.image
                    }
                }
            }
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
                let alert = UIAlertController(title: "Unable to open article", message: "The news URL is invalid.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
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
