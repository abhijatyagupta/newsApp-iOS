//
//  ViewsCell.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 09/02/21.
//

import UIKit

class ViewsCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var otherUsername: UILabel!
    @IBOutlet weak var myUsername: UILabel!
    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
