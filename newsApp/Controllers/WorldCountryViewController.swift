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
    
    private var newsImages: [String] = []
    private var newsTitles: [String] = []
    private var newsDescriptions: [String] = []
    
    
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
        
        newsManager.performRequest(Settings.worldApiURL) { (response) in
            print("response received!!")
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.worldCountryCollectionView.isHidden = false
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view appeared!")
        
        
        
    }


}



extension WorldCountryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsCell", for: indexPath) as! NewsCell
//        cell.newsTitle.text = arr[0]
//        cell.newsDescription.text = arr[arr.count - 2]
        cell.newsImageView.image = UIImage(imageLiteralResourceName: indexPath.row == 0 ? "ps5.png" : "xb1.png")
        
        return cell
    }
    
    
}
