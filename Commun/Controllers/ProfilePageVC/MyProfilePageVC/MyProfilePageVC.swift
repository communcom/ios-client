//
//  MyProfilePageVC.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class MyProfilePageVC: UserProfilePageVC {
    // MARK: - Subviews
    
    lazy var changeCoverButton: UIButton = {
        let button = UIButton(width: 24, height: 24, backgroundColor: UIColor.black.withAlphaComponent(0.3), cornerRadius: 12, contentInsets: UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        button.tintColor = .white
        button.setImage(UIImage(named: "photo_solid")!, for: .normal)
        return button
    }()
    
    // MARK: - Initializers
    init() {
        super.init(userId: Config.currentUser?.id ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        
        // hide back button
        navigationItem.leftBarButtonItem = nil
        
        // layout subview
        view.addSubview(changeCoverButton)
        changeCoverButton.autoPinEdge(.bottom, to: .bottom, of: coverImageView, withOffset: -60)
        changeCoverButton.autoPinEdge(.trailing, to: .trailing, of: coverImageView, withOffset: -16)
        
        changeCoverButton.addTarget(self, action: #selector(changeCoverBtnDidTouch(_:)), for: .touchUpInside)
    }
    
    override func bind() {
        super.bind()
        
        let offSetY = tableView.rx.contentOffset
            .map {$0.y}.share()
            
        offSetY
            .map {$0 < -140}
            .subscribe(onNext: { show in
                self.changeCoverButton.isHidden = !show
            })
            .disposed(by: disposeBag)
        
        offSetY
            .map {$0 < -43}
            .subscribe(onNext: { showNavBar in
                self.optionsButton.tintColor = !showNavBar ? .black : .white
            })
            .disposed(by: disposeBag)
    }
    
    override func setHeaderView() {
        headerView = MyProfileHeaderView(tableView: tableView)
        
        let myHeader = headerView as! MyProfileHeaderView
        myHeader.changeAvatarButton.addTarget(self, action: #selector(changeAvatarBtnDidTouch(_:)), for: .touchUpInside)
        myHeader.addBioButton.addTarget(self, action: #selector(addBioButtonDidTouch(_:)), for: .touchUpInside)
        myHeader.descriptionLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(bioLabelDidTouch(_:)))
        myHeader.descriptionLabel.addGestureRecognizer(tap)
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

        let userIdLabel = UILabel.with(text: "@\(viewModel.profile.value?.userId ?? "")", textSize: 12, textColor: .appMainColor)
        headerView.addSubview(userIdLabel)
        userIdLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 3)
        userIdLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userIdLabel.autoPinEdge(toSuperviewEdge: .trailing)
        
        showCommunActionSheet(style: .profile, headerView: headerView, actions: [
            // remove from MVP
//            CommunActionSheet.Action(title: "saved".localized().uppercaseFirst, icon: UIImage(named: "profile_options_saved"), handle: {
//                #warning("change filter")
//                let vc = PostsViewController()
//                vc.title = "saved posts".localized().uppercaseFirst
//                self.show(vc, sender: self)
//            }),
            CommunActionSheet.Action(title: "liked".localized().uppercaseFirst, icon: UIImage(named: "profile_options_liked"), handle: {
                #warning("change filter")
                let vc = PostsViewController()
                vc.title = "liked posts".localized().uppercaseFirst
                self.show(vc, sender: self)
            }, style: .profile),
            CommunActionSheet.Action(title: "blacklist".localized().uppercaseFirst, icon: UIImage(named: "profile_options_blacklist"), handle: {
                self.show(MyProfileBlacklistVC(), sender: self)
            }, style: .profile),
            CommunActionSheet.Action(title: "log out".localized().uppercaseFirst, icon: nil, handle: {
                self.showAlert(title: "Logout".localized(), message: "Do you really want to logout?".localized(), buttonTitles: ["Ok".localized(), "cancel".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in

                    if index == 0 {
                        self.navigationController?.showIndetermineHudWithMessage("logging out".localized().uppercaseFirst)
                        RestAPIManager.instance.rx.logout()
                            .subscribe(onCompleted: {
                                self.navigationController?.hideHud()
                                AppDelegate.reloadSubject.onNext(true)
                            }, onError: { (error) in
                                self.navigationController?.hideHud()
                                self.navigationController?.showError(error)
                            })
                            .disposed(by: self.disposeBag)
                    }
                }
            }, tintColor: UIColor(hexString: "#ED2C5B")!, marginTop: 14)
        ]) {
            
        }
    }
}
