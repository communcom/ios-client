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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var userCoverImage: UIImageView!
    @IBOutlet weak var changeCoverButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var addBioButton: UIButton!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var communitiesCountLabel: UILabel!
    @IBOutlet weak var segmentio: Segmentio!
    @IBOutlet weak var sendPointsButton: UIButton!
    @IBOutlet weak var sendPointLabel: UILabel!
    @IBOutlet weak var changeSettingsButton: UIButton!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followLabel: UILabel!
    
    @IBOutlet weak var copyReferralLinkButton: UIButton!
    @IBOutlet weak var errorView: UIView!
    
    let disposeBag = DisposeBag()
    var viewModel: ProfilePageViewModel!
    var expandedIndexes = [Int]()
    
    // reconstruct headerView for parallax
    var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // construct view model
        if viewModel == nil { viewModel = ProfilePageViewModel() }
        
        // setup view
        setUpViews()
        
        // bind view model
        bindViewModel()
        
        // load profile
        viewModel.loadProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        if viewModel.isMyProfile {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        } else {
            showTitle(false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isTranslucent = true
        if viewModel.isMyProfile {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        } else {
            showTitle(true)
        }
    }
    
    func setUpViews() {
        // Avatar
        if viewModel.isMyProfile {
            userAvatarImage
                .observeCurrentUserAvatar()
                .disposed(by: disposeBag)
            sendPointsButton.isHidden = true
            sendPointLabel.isHidden = true
            followButton.isHidden = true
            followLabel.isHidden = true
        } else {
            // Hide edits button
            changeAvatarButton.isHidden = true
            changeCoverButton.isHidden = true
            addBioButton.isHidden = true
            changeSettingsButton.isHidden = true
            settingsLabel.isHidden = true
            
            // setup for buttons
            sendPointsButton.imageView?.contentMode = .scaleAspectFit
            followButton.imageView?.contentMode = .scaleAspectFit
        }
        
        userAvatarImage.addTapToViewer()
        userCoverImage.addTapToViewer()
        
        // Configure viewModel
        viewModel.profileLoadingHandler = { [weak self] loading in
            loading ? self?.view.showLoading(): self?.view.hideLoading()
        }
        
        viewModel.profileFetchingErrorHandler = {[weak self] error in
            self?.errorView.isHidden = (error == nil)
            if error != nil {
                self?.showTitle(true)
            }
        }
        
        viewModel.loadingHandler = {[weak self] in
            
        }
        
        viewModel.listEndedHandler = {[weak self] in
        }
        
        viewModel.fetchNextErrorHandler = {[weak self] error in
        }
        
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
    
    func showTitle(_ show: Bool, animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.3: 0) {
            self.navigationController?.navigationBar.setBackgroundImage(
                show ? nil: UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage =
                show ? nil: UIImage()
            self.navigationController?.view.backgroundColor =
                show ? .white: .clear
            self.navigationController?.navigationBar.setTitleFont(.boldSystemFont(ofSize: 17), color:
                show ? .black: .clear)
            self.navigationController?.navigationBar.tintColor =
                show ? .appMainColor: .white
        }
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
    
    @IBAction func followButtonDidTouch(_ sender: Any) {
        guard let userToFollow = viewModel.profile.value?.userId,
            userToFollow != Config.currentUser?.id else {
                return
        }
        
        self.onFollowTrigger()
    }
    
    @IBAction func btnRetryDidTouch(_ sender: Any) {
        refresh()
    }
}
