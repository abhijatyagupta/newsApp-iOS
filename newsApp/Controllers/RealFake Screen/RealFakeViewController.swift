//
//  RealFakeViewController.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 25/12/20.
//

import UIKit
import SafariServices

class RealFakeViewController: UIViewController {
    @IBOutlet weak var newsTitleView: UIView!
    @IBOutlet weak var newsTitleLabel: UILabel!
    
    @IBOutlet weak var markedViewContainer: UIStackView!
    @IBOutlet weak var unmarkedViewContainer: UIStackView!
    @IBOutlet weak var markedRealViewContainer: UIStackView!
    @IBOutlet weak var markedFakeViewContainer: UIStackView!
    
    @IBOutlet weak var markTheNewsLabel: UILabel!
    
    @IBOutlet weak var unmarkedRealView: UIView!
    @IBOutlet weak var unmarkedFakeView: UIView!
    @IBOutlet weak var unmarkedRealCount: UILabel!
    @IBOutlet weak var unmarkedFakeCount: UILabel!
    @IBOutlet weak var viewsAreHiddenView: UIView!
    @IBOutlet weak var markedRealView: UIView!
    @IBOutlet weak var markedRealCount: UILabel!
    @IBOutlet weak var shareButtonInRealView: UIButton!
    @IBOutlet weak var fakeCountLabelForRealView: UILabel!
    @IBOutlet weak var markedFakeView: UIView!
    @IBOutlet weak var markedFakeCount: UILabel!
    @IBOutlet weak var realCountLabelForFakeView: UILabel!
    @IBOutlet weak var publicViewsTableView: UITableView!
    var cellForCurrentNews: NewsCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        configureNewsTitle()
        configureUnmarkedView()
        configureRealMarkedView()
        configureFakeMarkedView()
        configurePublicViewsTableView()
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func newsTitleTapped(_ sender: UIControl) {
        if let url = URL(string: cellForCurrentNews.newsURL!) {
            let vc = SFSafariViewController(url: url)
            vc.overrideUserInterfaceStyle = .dark
            present(vc, animated: true)
        }
        else {
            let alert = cellForCurrentNews.alertForUnavailableNews(title: K.UIText.articleOpenErrorTitle, message: K.UIText.shareErrorMessage)
            present(alert, animated: true)
        }
    }
    
    
    
    @IBAction func unmarkedRealViewTapped(_ sender: UIView) {
        markTheNewsLabel.text = K.UIText.newsMarked
        hideUnmarkedAnd(markedFakeViewContainer)

    }
    
    
    @IBAction func unmarkedFakeViewTapped(_ sender: UIView) {
        markTheNewsLabel.text = K.UIText.newsMarked
        hideUnmarkedAnd(markedRealViewContainer)
    }
    
    
    @IBAction func shareButtonInRealViewTapped(_ sender: UIButton) {
        if let url = URL(string: cellForCurrentNews.newsURL!) {
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            vc.overrideUserInterfaceStyle = .dark
            present(vc, animated: true)
        }
        else {
            let alert = cellForCurrentNews.alertForUnavailableNews(title: K.UIText.shareErrorTitle, message: K.UIText.shareErrorMessage)
            present(alert, animated: true)
        }
    }
    
    
    private func hideUnmarkedAnd(_ viewToHide: UIView) {
        UIView.animate(withDuration: 0.3) {
            self.unmarkedViewContainer.alpha = 0
        } completion: { (animationIsComplete) in
            if animationIsComplete {
                self.unmarkedViewContainer.isHidden = true
                viewToHide.isHidden = true
                UIView.animate(withDuration: 0.3) {
                    self.markedViewContainer.isHidden = false
                    self.markedViewContainer.alpha = 1
                }
            }
        }
    }
    
    
    private func configureNewsTitle() {
        newsTitleView.layer.cornerRadius = 20
        newsTitleLabel.text = cellForCurrentNews.newsTitle.text
    }
    
    
    private func configureUnmarkedView() {
        unmarkedRealCount.text = "\(cellForCurrentNews.realCount)"
        unmarkedFakeCount.text = "\(cellForCurrentNews.fakeCount)"
        configureViewBorder(view: unmarkedRealView, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        configureViewBorder(view: unmarkedFakeView, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        viewsAreHiddenView.layer.cornerRadius = 20
    }
    
    private func configureRealMarkedView() {
        configureViewBorder(view: markedRealView, color: #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1))
        shareButtonInRealView.layer.cornerRadius = 10
        
    }
    
    private func configureFakeMarkedView() {
        configureViewBorder(view: markedFakeView, color: #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1))
        
    }
    
    
    private func configurePublicViewsTableView() {
        publicViewsTableView.delegate = self
        publicViewsTableView.dataSource = self
    }
    
    
    private func configureViewBorder(view: UIView, color: CGColor) {
        view.layer.borderColor = color
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 20
    }

}

//MARK: - Table View Methods

extension RealFakeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "publicViews")!
        cell.textLabel?.text = K.UIText.publicViews
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return K.UIText.publicViewsFooter
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
