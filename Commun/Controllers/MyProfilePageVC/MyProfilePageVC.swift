//
//  MyProfilePageVC.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class MyProfilePageVC: UserProfilePageVC {
    // MARK: - Properties
    var shouldHideBackButton = true
    
    // MARK: - Subviews
    lazy var changeCoverButton: UIButton = {
        let button = UIButton(width: 24, height: 24, backgroundColor: UIColor.black.withAlphaComponent(0.3), cornerRadius: 12, contentInsets: UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        button.tintColor = .white
        button.setImage(UIImage(named: "photo_solid")!, for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(inset: -10)
        return button
    }()
    
    // MARK: - Initializers
    override func createViewModel() -> ProfileViewModel<ResponseAPIContentGetProfile> {
        MyProfilePageViewModel(userId: userId)
    }
    
    init() {
        super.init(userId: Config.currentUser?.id ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - Custom Functions
    override func setUp() {
        super.setUp()
        
        // hide back button
        if shouldHideBackButton {
            backButton.alpha = 0
            backButton.isUserInteractionEnabled = false
        }
        
        // layout subview
        view.addSubview(changeCoverButton)
        changeCoverButton.autoPinEdge(.bottom, to: .bottom, of: coverImageView, withOffset: -60)
        changeCoverButton.autoPinEdge(.trailing, to: .trailing, of: coverImageView, withOffset: -16)
        
        changeCoverButton.addTarget(self, action: #selector(changeCoverBtnDidTouch(_:)), for: .touchUpInside)
        
        // wallet
        let tap = UITapGestureRecognizer(target: self, action: #selector(walletDidTouch))
        (headerView as! MyProfileHeaderView).walletView.isUserInteractionEnabled = true
        (headerView as! MyProfileHeaderView).walletView.addGestureRecognizer(tap)
    }
    
    override func bind() {
        super.bind()
        
        bindBalances()
        
        let offSetY = tableView.rx.contentOffset
            .map {$0.y}.share()
            
        offSetY
            .map { $0 < -140 }
            .subscribe(onNext: { show in
                self.changeCoverButton.isHidden = !show
            })
            .disposed(by: disposeBag)
        
        offSetY
            .map { $0 < -43 }
            .subscribe(onNext: { showNavBar in
                self.optionsButton.tintColor = !showNavBar ? .appBlackColor : .white
                self.title = !showNavBar ? self.username : nil
            })
            .disposed(by: disposeBag)
    }
    
    override func setUp(profile: ResponseAPIContentGetProfile) {
        super.setUp(profile: profile)
        ResponseAPIContentGetProfile.current = profile
        
        if profile.createdCommunities == nil {
            RestAPIManager.instance.getCreatedCommunities()
                .subscribe(onSuccess: { (result) in
                    var profile = ResponseAPIContentGetProfile.current
                    profile?.createdCommunities = result.communities
                    ResponseAPIContentGetProfile.current = profile
                })
                .disposed(by: disposeBag)
        }
    }
    
    override func createHeaderView() -> UserProfileHeaderView {
        let headerView = MyProfileHeaderView(tableView: tableView)
        
        headerView.changeAvatarButton.addTarget(self, action: #selector(changeAvatarBtnDidTouch(_:)), for: .touchUpInside)
        headerView.addBioButton.addTarget(self, action: #selector(addBioButtonDidTouch(_:)), for: .touchUpInside)
        headerView.descriptionLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(bioLabelDidTouch(_:)))
        headerView.descriptionLabel.addGestureRecognizer(tap)
        return headerView
    }
    
    override func actionsForMoreButton() -> [CMActionSheet.Action] {
        guard let profile = viewModel.profile.value else { return []}
        return [
            .iconFirst(
                title: "share".localized().uppercaseFirst,
                iconName: "icon-share-circle-white",
                handle: {
                    ShareHelper.share(urlString: self.shareWith(name: profile.username ?? "", userID: profile.userId))
            },
                bottomMargin: 15
            ),
            .iconFirst(
                title: "saved souls".localized().uppercaseFirst,
                iconName: "profile_options_referral",
                handle: {
                    let vc = ReferralUsersVC()
                    vc.title = "saved souls".localized().uppercaseFirst
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(customView: UIView(backgroundColor: .clear))
                    self.show(vc, sender: self)
            },
                showNextButton: true
            ),
            .iconFirst(
                title: "liked".localized().uppercaseFirst,
                iconName: "profile_options_liked",
                handle: {
                    let vc = PostsViewController(filter: PostsListFetcher.Filter(type: .voted, sortBy: .time, userId: Config.currentUser?.id))
                    vc.title = "liked".localized().uppercaseFirst
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(customView: UIView(backgroundColor: .clear))
                    self.show(vc, sender: self)
            },
                showNextButton: true
            ),
            .iconFirst(
                title: "blacklist".localized().uppercaseFirst,
                iconName: "profile_options_blacklist",
                handle: {
                    self.show(MyProfileBlacklistVC(), sender: self)
            },
                bottomMargin: 15,
                showNextButton: true
            ),
            .iconFirst(
                title: "settings".localized().uppercaseFirst,
                iconName: "profile_options_settings",
                handle: {
                    let vc = MyProfileSettingsVC()
                    self.show(vc, sender: self)
            },
                showNextButton: true
            )
        ]
    }
    
    override func handleListEmpty() {
        var title = "empty"
        var description = "not found"
        
        switch (viewModel as! UserProfilePageViewModel).segmentedItem.value {
        case .posts:
            title = "no posts".localized().uppercaseFirst
            description = "you haven't created any posts yet".localized().uppercaseFirst

            tableView.addEmptyPlaceholderFooterView(title: title, description: description, buttonLabel: String(format: "%@ %@", "create".localized().uppercaseFirst, "post".localized())) {
                if let tabBarVC = self.tabBarController as? TabBarVC {
                    tabBarVC.buttonAddTapped()
                }
            }

        case .comments:
            title = "no comments".localized().uppercaseFirst
            description = "you haven't created any comments yet".localized().uppercaseFirst

            tableView.addEmptyPlaceholderFooterView(title: title, description: description)
            
        case .about:
            title = "no info".localized().uppercaseFirst
            description = "you haven't added any information about your self yet".localized().uppercaseFirst

            tableView.addEmptyPlaceholderFooterView(title: title, description: description)
        }
    }
}
