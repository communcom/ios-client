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

class ProfilePageVC: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var userCoverImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var addBioButton: UIButton!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var communitiesCountLabel: UILabel!
    @IBOutlet weak var segmentio: Segmentio!
    
    @IBOutlet weak var copyReferralLinkButton: UIButton!
    
    let bag = DisposeBag()
    let viewModel = ProfilePageViewModel()
    
    // reconstruct headerView for parallax
    var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup view
        setUpViews()
        
        // bind view model
        bindViewModel()
        
        // load profile
        viewModel.loadProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setUpViews() {
        // Indicator settings
        activityIndicator.hidesWhenStopped = true
        
        // Configure tableView
        tableView.register(UINib(nibName: "PostCardCell", bundle: nil), forCellReuseIdentifier: "PostCardCell")
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        tableView.register(UINib(nibName: "EmptyCell", bundle: nil), forCellReuseIdentifier: "EmptyCell")
        tableView.rowHeight = UITableView.automaticDimension
        
        // RefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
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
        
        // Parallax
        self.constructParallax()
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func changeCoverBtnDidTouch(_ sender: Any) {
        openActionSheet(cover: true)
    }
    
    @IBAction func changeAvatarBtnDidTouch(_ sender: Any) {
        openActionSheet(cover: false)
    }
    
    @IBAction func addBioButtonDidTouch(_ sender: Any) {
        self.onUpdateBio(new: true)
    }
    
    @IBAction func bioLableDidTouch(_ sender: Any) {
        self.showActionSheet(title: "Change".localized() + "profile description".localized(), actions: [
            UIAlertAction(title: "Edit".localized(), style: .default, handler: { (_) in
                self.onUpdateBio()
            }),
            UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { (_) in
                self.onUpdateBio(delete: true)
            }),
        ])
    }
    
    @IBAction func settingsButtonDidTouch(_ sender: Any) {
        let settingsVC = controllerContainer.resolve(SettingsVC.self)!
        self.show(settingsVC, sender: nil)
    }
}
