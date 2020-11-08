//
//  NewsCell.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 23/10/20.
//

import UIKit

protocol NewsCellDelegate: class {
    func presentShareScreen(_ cell: NewsCell)
}


class NewsCell: UICollectionViewCell {
    var delegate: NewsCellDelegate?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var realFakeButton: UIButton!
    var newsURL: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
        realFakeButton.layer.cornerRadius = 7.5
    
    }

    @IBAction func shareButtonPressed(_ sender: UIButton) {
        delegate?.presentShareScreen(self)
    }
}
