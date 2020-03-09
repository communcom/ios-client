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
            navigationItem.leftBarButtonItem = nil
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
                self.optionsButton.tintColor = !showNavBar ? .black : .white
                self.title = !showNavBar ? self.username : nil
            })
            .disposed(by: disposeBag)
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
    
    override func moreActionsButtonDidTouch(_ sender: CommunButton) {
        let headerView = UIView(height: 40)
                
        let avatarImageView = MyAvatarImageView(size: 40)
        avatarImageView.observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        headerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        let userNameLabel = UILabel.with(text: viewModel.profile.value?.username, textSize: 15, weight: .semibold)
        headerView.addSubview(userNameLabel)
        userNameLabel.autoPinEdge(toSuperviewEdge: .top)
        userNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userNameLabel.autoPinEdge(toSuperviewEdge: .trailing)

        let userIdLabel = UILabel.with(text: "@\(viewModel.profile.value?.userId ?? "")", textSize: 12, weight: .semibold, textColor: .appMainColor)
        headerView.addSubview(userIdLabel)
        userIdLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 3)
        userIdLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userIdLabel.autoPinEdge(toSuperviewEdge: .trailing)
        
        showCommunActionSheet(headerView: headerView, actions: [
            // remove from MVP
//            CommunActionSheet.Action(title: "saved".localized().uppercaseFirst, icon: UIImage(named: "profile_options_saved"), handle: {
//                #warning("change filter")
//                let vc = PostsViewController()
//                vc.title = "saved posts".localized().uppercaseFirst
//                self.show(vc, sender: self)
//            }),
            CommunActionSheet.Action(title: "liked".localized().uppercaseFirst,
                                     icon: UIImage(named: "profile_options_liked"),
                                     style: .profile,
                                     handle: {
                                        let vc = PostsViewController(filter: PostsListFetcher.Filter(feedTypeMode: .voted, feedType: .time, userId: Config.currentUser?.id))
                                        vc.title = "liked".localized().uppercaseFirst
                                        self.navigationItem.backBarButtonItem = UIBarButtonItem(customView: UIView(backgroundColor: .clear))
                                        self.baseNavigationController?.changeStatusBarStyle(.default)
                                        self.show(vc, sender: self)
            }),
            CommunActionSheet.Action(title: "blacklist".localized().uppercaseFirst,
                                     icon: UIImage(named: "profile_options_blacklist"),
                                     style: .profile,
                                     handle: {
                                        self.show(MyProfileBlacklistVC(), sender: self)
            }),
            CommunActionSheet.Action(title: "settings".localized().uppercaseFirst,
                                     icon: UIImage(named: "profile_options_settings"),
                                     style: .profile,
                                     marginTop: 14,
                                     handle: {
                                        let vc = MyProfileSettingsVC()
                                        self.show(vc, sender: self)
            })
//            CommunActionSheet.Action(title: "logout".localized().uppercaseFirst, icon: nil, handle: {
//                self.showAlert(title: "Logout".localized(), message: "Do you really want to logout?".localized(), buttonTitles: ["Ok".localized(), "cancel".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in
//
//                    if index == 0 {
//                        self.navigationController?.showIndetermineHudWithMessage("logging out".localized().uppercaseFirst)
//                        RestAPIManager.instance.logout()
//                            .subscribe(onCompleted: {
//                                self.navigationController?.hideHud()
//                                AppDelegate.reloadSubject.onNext(true)
//                            }, onError: { (error) in
//                                self.navigationController?.hideHud()
//                                self.navigationController?.showError(error)
//                            })
//                            .disposed(by: self.disposeBag)
//                    }
//                }
//            }, tintColor: UIColor(hexString: "#ED2C5B")!, marginTop: 14)
        ]) {
            
        }
    }
}
