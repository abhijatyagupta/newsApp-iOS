//
//  HeadlinesViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 18/12/20.
//

import UIKit

class HeadlinesViewController: UIViewController {
    @IBOutlet weak var headlinesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headlinesCollectionView.delegate = self
        headlinesCollectionView.dataSource = self
        headlinesCollectionView.register(UINib(nibName: "NewsCell", bundle: nil), forCellWithReuseIdentifier: "newsCell")
        
    }

}



extension HeadlinesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "newsCell", for: indexPath) as! NewsCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 345, height: 351)
    }
    
    
    
}
