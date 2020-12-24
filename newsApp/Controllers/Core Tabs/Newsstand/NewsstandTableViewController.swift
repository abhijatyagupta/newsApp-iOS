//
//  NewsstandTableViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 06/10/20.
//

import UIKit

class NewsstandTableViewController: UITableViewController, UISearchBarDelegate {
    
    private let categories: [String] = ["Sports", "Entertainment", "Business", "Technology", "Health", "Science", "General"]
    private var selectedCategory: String = ""
    private let searchController = UISearchController()
    
    @IBOutlet weak var countrySwitch: UISwitch!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var countryDisclosureText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.sizeToFit()
        searchController.searchBar.placeholder = K.UIText.searchPlaceholder
        searchController.searchBar.delegate = self
        
        if Settings.isCountrySet {
            countrySwitch.setOn(true, animated: false)
            countrySwitchDidToggle(countrySwitch)
        }
        else {
            countrySwitch.setOn(false, animated: false)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.delegate = self
    }
    
    @IBAction func countrySwitchDidToggle(_ sender: UISwitch) {
        if countrySwitch.isOn {
            tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            countryRefresh()
        }
        else {
            Settings.isCountrySet = false
            UserDefaults.standard.setValue(nil, forKey: K.countryKey)
            Settings.currentCountry = Country("", "")
            tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
    }
    
    
    func countryRefresh() {
        if Settings.isCountrySet {
            countryDisclosureText.isHidden = false
            countryDisclosureText.text = Settings.currentCountry.name
        }
        else {
            countryDisclosureText.isHidden = true
            performSegue(withIdentifier: "segueToCountry", sender: self)
        }
    }
    
    
    //MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countrySwitch.isOn ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - CollectionView Methods

extension NewsstandTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cat1", for: indexPath)
        if let catCell = cell as? CustomCatCell {
            catCell.layer.cornerRadius = 20
            catCell.layer.borderWidth = 2
            catCell.layer.borderColor = #colorLiteral(red: 0.1725490196, green: 0.1725490196, blue: 0.1725490196, alpha: 1)
            catCell.catTitle.text = Category(indexPath.row).title
            catCell.backgroundImage.image = UIImage(imageLiteralResourceName: "\(catCell.catTitle.text ?? "Sports").png")
            return catCell
        }
        return cell
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 165, height: 165)
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedCategory = categories[indexPath.row]
        performSegue(withIdentifier: "categorySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categorySegue" {
            let vc = segue.destination as! WorldCountryViewController
            vc.navigationItem.title = selectedCategory
            vc.parentCategory = true
            vc.apiToCall = Settings.worldApiURL + "&category=\(selectedCategory)&country=us"
            
        }
    }
    
    
}

//MARK: - Custom category cell class

class CustomCatCell: UICollectionViewCell {
    @IBOutlet fileprivate weak var catTitle: UILabel!
    @IBOutlet fileprivate weak var backgroundImage: UIImageView!
}



extension NewsstandTableViewController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        print("shouldSelect fired in newsstandTableVC")
////        print("children count -->\(navigationController?.children.count)")
//
//        if navigationController?.topViewController is WorldCountryViewController {
//            print("presenting vc is indeed wcvc")
//            if let WCVC = navigationController?.topViewController as? WorldCountryViewController {
//                print("scrolled to top")
//                WCVC.worldCountryCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionView.ScrollPosition(rawValue: 0), animated: true)
//                print("will return false")
//                return false
//            }
//        }
//        return true
//    }
    
    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        let tabBarIndex = tabBarController.selectedIndex
//        print(tabBarIndex)
//
//
//        self.tableView.setContentOffset(CGPoint(x: 0.0, y: additionalSafeAreaInsets.top), animated: true)
//
//        self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: UITableView.ScrollPosition(rawValue: 0)!, animated: true)
//
//        if let currentViewController = self.presentingViewController as? UICollectionViewController {
//
//            currentViewController.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionView.ScrollPosition(rawValue: 0), animated: true)
//        }
//    }
    
    
}
