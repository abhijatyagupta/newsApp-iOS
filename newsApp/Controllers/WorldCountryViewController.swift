//
//  WorldCountryViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 21/10/20.
//

import UIKit
import SwiftyJSON

class WorldCountryViewController: UIViewController {
    @IBOutlet weak var worldCountryCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let newsManager = NewsManager()
    private var newsImages = [Int : UIImage]()
    private var articles: [JSON] = []
    
    var parentCategory: Bool = false
    var apiToCall: String = Settings.worldApiURL
    var lastLoadedApi: String = Settings.worldApiURL
    private var loadNews: DispatchWorkItem?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        
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
        if !parentCategory && lastLoadedApi != Settings.worldApiURL {
            print("last loaded api was not equal to global api")
            worldCountryCollectionView.isHidden = true
            activityIndicator.isHidden = false
            navigationItem.title = Settings.currentCountry.name
            DispatchQueue.main.async {
                self.lastLoadedApi = Settings.worldApiURL
                self.newsManager.performRequest(Settings.worldApiURL) { (data) in
                    print("data received!!")
                    self.fetchNews(data)
                }
            }
        }
        
        tabBarController?.delegate = self
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
}


//MARK: - Custom News Cell Delegate Method

extension WorldCountryViewController: NewsCellDelegate {
    func presentShareScreen(_ cell: NewsCell) {
        let shareText = cell.newsURL
        let vc = UIActivityViewController(activityItems: [URL(string: shareText!)!], applicationActivities: [])
        present(vc, animated: true)
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


//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        let tabBarIndex = tabBarController.selectedIndex
//        print(tabBarIndex)
//        print("scrolled to top")
//        self.worldCountryCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionView.ScrollPosition(rawValue: 0), animated: true)
//    }
}
