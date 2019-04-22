//
//  ProfilePageVC.swift
//  Commun
//
//  Created by Chung Tran on 17/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import SDWebImage
import UIImageView_Letters
import RxMediaPicker

class ProfilePageVC: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var userCoverImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var communitiesCountLabel: UILabel!
    @IBOutlet weak var segmentio: Segmentio!
    @IBOutlet weak var coverSelectButton: UIButton!
    @IBOutlet weak var avatarSelectButton: UIButton!
    
    @IBOutlet weak var copyReferralLinkButton: UIButton!
    
    let bag = DisposeBag()
    let viewModel = ProfilePageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup view
        setUpViews()
        
        // bind view model
        bindViewModel()
        
        // load profile
        viewModel.loadProfile()
    }
    
    func setUpViews() {
        // Indicator settings
        activityIndicator.hidesWhenStopped = true
        
        // Configure tableView
        tableView.register(UINib(nibName: "PostCardCell", bundle: nil), forCellReuseIdentifier: "PostCardCell")
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        tableView.register(UINib(nibName: "ProfilePageEmptyCell", bundle: nil), forCellReuseIdentifier: "ProfilePageEmptyCell")
        tableView.rowHeight = UITableView.automaticDimension
        
        // RefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Segmentio
        let segmentedItems = ProfilePageSegmentioItem.allCases
        let items: [SegmentioItem] = segmentedItems.map {SegmentioItem(title: $0.rawValue.localized(), image: nil)}
        
        segmentio.setup(
            content: items,
            style: SegmentioStyle.onlyLabel,
            options: SegmentioOptions.default)
        
        segmentio.selectedSegmentioIndex = 0
        
        segmentio.valueDidChange = {_, index in
            self.viewModel.segmentedItem.accept(segmentedItems[index])
        }
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
