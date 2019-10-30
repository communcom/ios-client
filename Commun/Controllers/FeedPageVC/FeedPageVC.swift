//
//  FeedPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift
import RxDataSources
import ESPullToRefresh

class FeedPageVC: PostsViewController, VCWithParallax {
    
    // MARK: - Properties
    var headerView: UIView! // for parallax
    var headerHeight: CGFloat = 151 // for parallax

    // MARK: - Outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var changeFeedTypeButton: UIButton!
    @IBOutlet weak var _tableView: UITableView!
    
    override var tableView: UITableView! {
        get {return _tableView}
        set {_tableView = newValue}
    }
    
    @IBOutlet weak var userAvatarImage: UIImageView!
    
    override func setUp() {
        super.setUp()
        // parallax
        constructParallax()
        
        // avatarImage
        userAvatarImage
            .observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        
        userAvatarImage.addTapToViewer()
        userAvatarImage.observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        // dismiss keyboard when dragging
        tableView.keyboardDismissMode = .onDrag
    }
    
    override func filterChanged(filter: PostsListFetcher.Filter) {
        super.filterChanged(filter: filter)
        // feedTypeMode
        switch filter.feedTypeMode {
        case .subscriptions:
            self.headerLabel.text = "my Feed".localized().uppercaseFirst
            self.changeFeedTypeButton.setTitle("trending".localized().uppercaseFirst, for: .normal)
        case .new:
            self.headerLabel.text = "trending".localized().uppercaseFirst
            
            self.changeFeedTypeButton.setTitle("my Feed".localized().uppercaseFirst, for: .normal)
        default:
            break
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
