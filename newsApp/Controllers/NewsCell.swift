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
}


class NewsCell: UICollectionViewCell {
    var delegate: NewsCellDelegate?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var realFakeButton: UIButton!
    @IBOutlet weak var realLabel: UILabel!
    @IBOutlet weak var fakeLabel: UILabel!
    var realCount: Int = 0 {
        didSet {
            realLabel.text = "\(realCount) REAL"
        }
    }
    var fakeCount: Int = 0 {
        didSet {
            fakeLabel.text = "\(fakeCount) FAKE"
        }
    }
    var newsURL: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
        realFakeButton.layer.cornerRadius = 7.5
    }

    @IBAction func shareButtonPressed(_ sender: UIButton) {
        delegate?.presentShareScreen(self)
    }
    
    @IBAction func realFakeButtonPressed(_ sender: UIButton) {
        delegate?.showRealFakeScreen(self)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if !activityIndicator.isHidden {
            activityIndicator.startAnimating()
        }
    }
    
    func alertForUnavailableNews(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: K.UIText.okString, style: .default))
        return alert
    }
    
    
}
