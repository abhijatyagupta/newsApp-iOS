//
//  NewsCell.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 23/10/20.
//

import UIKit

protocol NewsCellDelegate: class {
    func presentShareScreen(_ cell: NewsCell)
    func showRealFakeScreen(_ cell: NewsCell)
    func showSignedOutView(_ cell: NewsCell)
}


class NewsCell: UICollectionViewCell {
    var delegate: NewsCellDelegate?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var realFakeActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var realFakeButton: UIButton!
    @IBOutlet weak var realFakeStackView: UIStackView!
    @IBOutlet weak var realLabel: UILabel!
    @IBOutlet weak var fakeLabel: UILabel!
    var realCount: Int = 0 {
        didSet {
            DispatchQueue.main.async { self.realLabel.text = "\(self.realCount) REAL" }
        }
    }
    var fakeCount: Int = 0 {
        didSet {
            DispatchQueue.main.async { self.fakeLabel.text = "\(self.fakeCount) FAKE" }
        }
    }
    var newsURL: String?
    var imageURL: String?
    var documentID: String?
    let firestoreManagerForCell = FirestoreManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
        realFakeButton.layer.cornerRadius = 7.5
    }

    @IBAction func shareButtonPressed(_ sender: UIButton) {
        delegate?.presentShareScreen(self)
    }
    
    @IBAction func realFakeButtonPressed(_ sender: UIButton) {
        Settings.isUserSignedIn ? delegate?.showRealFakeScreen(self) : delegate?.showSignedOutView(self)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if !activityIndicator.isHidden {
            activityIndicator.startAnimating()
        }
        if !realFakeActivityIndicator.isHidden {
            realFakeActivityIndicator.startAnimating()
        }
    }
    
    func alertForUnavailableNews(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        alert.addAction(UIAlertAction(title: K.UIText.okString, style: .default))
        return alert
    }
    
    
}
