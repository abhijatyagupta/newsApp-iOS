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
//    private var newsTitles: [String] = []
//    private var newsDescriptions: [String] = []
    private var articles: [JSON] = []
    
    
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
        
        newsManager.performRequest(Settings.worldApiURL) { (data) in
            print("data received!!")
            self.fetchNews(data)
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view appeared!")
        
    }
    
    func fetchNews(_ data: Data?) {
        if let safeData = data {
            do {
                let newsJSON: JSON = try JSON(data: safeData)
                articles = newsJSON["articles"].arrayValue
            } catch { print(error) }
        }
        DispatchQueue.main.async {
            self.worldCountryCollectionView.reloadData()
            self.activityIndicator.isHidden = true
            self.worldCountryCollectionView.isHidden = false
        }
        
    }

}

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
                        self.newsImages[indexPath.row] = cell.newsImageView.image
                    }
                }
                cell.activityIndicator.isHidden = true
            }
        }
        cell.delegate = self
        return cell
    }
    
    
}


extension WorldCountryViewController: NewsCellDelegate {
    func presentShareScreen(_ cell: NewsCell) {
        activityIndicator.isHidden = false
        let shareText = cell.newsURL
        let vc = UIActivityViewController(activityItems: [URL(string: shareText!)!], applicationActivities: [])
        present(vc, animated: true)
        activityIndicator.isHidden = true
        
    }
}
