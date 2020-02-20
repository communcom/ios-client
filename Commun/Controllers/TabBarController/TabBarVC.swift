//
//  TabBarVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 14/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import SwifterSwift
import CyberSwift
import NotificationView

public let tabBarHeight: CGFloat = .adaptive(height: 60.0) + (UIDevice.hasNotch ? UIDevice.safeAreaInsets.bottom : 0.0)

class TabBarVC: UITabBarController {
    // MARK: - Constants
    let feedTabIndex = 0
    let discoveryTabIndex = 1
    let notificationTabIndex = 2
    let profileTabIndex = 3
    let selectedColor = UIColor.black
    let unselectedColor = UIColor(hexString: "#A5A7BD")
    
    // MARK: - Properties
    let viewModel = TabBarViewModel()
    let bag = DisposeBag()
    
    // MARK: - Subviews
    private lazy var tabBarContainerView = UIView(backgroundColor: .white)
    private lazy var shadowView = UIView(height: tabBarHeight)
    lazy var tabBarStackView = UIStackView(forAutoLayout: ())
    
    // Notification
    private lazy var notificationsItem = buttonTabBarItem(image: UIImage(named: "notifications")!, tag: notificationTabIndex)
    private lazy var notificationRedMark: UIView = {
        let notificationRedMark = UIView(width: 10, height: 10, backgroundColor: .ed2c5b, cornerRadius: 5)
        notificationRedMark.borderColor = .white
        notificationRedMark.borderWidth = 1
        return notificationRedMark
    }()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Config styles
        configStyles()

        // Config tabs
        configTabs()
        
        // bind view model
        bind()
    }
    
    func setTabBarHiden(_ hide: Bool) {
        if hide {
            shadowView.isHidden = true
            shadowView.heightConstraint?.constant = 0
        } else {
            shadowView.isHidden = false
            shadowView.heightConstraint?.constant = tabBarHeight
        }
    }
    
    func setNotificationRedMarkHidden(_ hide: Bool) {
        if hide {
            notificationRedMark.removeFromSuperview()
            return
        }
        
        if !notificationRedMark.isDescendant(of: notificationsItem) {
            notificationsItem.addSubview(notificationRedMark)
            notificationRedMark.centerXAnchor.constraint(equalTo: notificationsItem.centerXAnchor, constant: 6).isActive = true
            notificationRedMark.autoPinEdge(toSuperviewEdge: .top)
        }
    }
    
    private func configStyles() {
        view.backgroundColor = .white
        
        // hide default tabBar
        tabBar.isHidden = true
        
        // shadow
        view.addSubview(shadowView)
        shadowView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        shadowView.addShadow(ofColor: .shadow, radius: 16, offset: CGSize(width: 0, height: -6), opacity: 0.08)
        
        // tabBarContainerView
        shadowView.addSubview(tabBarContainerView)
        tabBarContainerView.autoPinEdgesToSuperviewEdges()
        
        // tabBarStackView
        tabBarContainerView.addSubview(tabBarStackView)
        tabBarStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0.0, left: 0.0, bottom: UIDevice.safeAreaInsets.bottom, right: 0.0))
        tabBarStackView.axis = .horizontal
        tabBarStackView.alignment = .center
        tabBarStackView.distribution = .fillEqually
        tabBarStackView.spacing = 0
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // https://stackoverflow.com/questions/39578530/since-xcode-8-and-ios10-views-are-not-sized-properly-on-viewdidlayoutsubviews
        shadowView.layoutIfNeeded()
        tabBarContainerView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
    }
    
    private func configTabs() {
        // Feed Tab
        let feed = FeedPageVC()
        let feedNC = BaseNavigationController(rootViewController: feed, tabBarVC: self)
        let feedItem = buttonTabBarItem(image: UIImage(named: "feed")!, tag: feedTabIndex)
        feed.accessibilityLabel = "TabBarFeedTabBarItem"

        // Comunities Tab
        let discoveryVC = DiscoveryVC()
        let discoveryNC = BaseNavigationController(rootViewController: discoveryVC, tabBarVC: self)
        let discoveryItem = buttonTabBarItem(image: UIImage(named: "tabbar-discovery-icon")!, tag: discoveryTabIndex)
        discoveryVC.accessibilityLabel = "TabBarDiscoveryTabBarItem"
        
        // Notifications Tab
        let notifications = NotificationsPageVC()
        let notificationsNC = BaseNavigationController(rootViewController: notifications, tabBarVC: self)
        notificationsNC.navigationBar.prefersLargeTitles = true
        notifications.accessibilityLabel = "TabBarNotificationsTabBarItem"

        // Profile Tab
        let profile = MyProfilePageVC()
        let profileNC = BaseNavigationController(rootViewController: profile, tabBarVC: self)
        let profileItem = buttonTabBarItem(image: UIImage(named: "tabbar-profile")!, tag: profileTabIndex)
        profileNC.accessibilityLabel = "TabBarProfileTabBarItem"
        profileNC.navigationBar.tintColor = UIColor.appMainColor

        // Set up controllers
        viewControllers = [feedNC, discoveryNC, /* wallet,*/ notificationsNC, profileNC]
        
        tabBarStackView.addArrangedSubviews([
            feedItem,
            discoveryItem,
            tabBarItemAdd,
            notificationsItem,
            profileItem
        ])
                
        // highlight first
        feedItem.tintColor = selectedColor
    }
    
    private func buttonTabBarItem(image: UIImage, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = unselectedColor
        button.tag = tag
        button.touchAreaEdgeInsets = UIEdgeInsets(inset: -10)
        button.addTarget(self, action: #selector(switchTab(button:)), for: .touchUpInside)
        return button
    }
    
    var tabBarItemAdd: UIButton {
        let button = UIButton(type: .system)
        
        let itemSize: CGFloat = .adaptive(height: 45)
        let itemPadding: CGFloat = .adaptive(height: 14)
        
        let view = UIView(width: itemSize, height: itemSize, backgroundColor: .appMainColor)
        view.cornerRadius = itemSize / 2
        
        let imageView = UIImageView(image: UIImage(named: "add"))
        imageView.configureForAutoLayout()
        imageView.tintColor = .white
        
        view.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: itemPadding, left: itemPadding, bottom: itemPadding, right: itemPadding))
        
        button.addSubview(view)
        view.autoAlignAxis(toSuperviewAxis: .vertical)
        view.autoAlignAxis(toSuperviewAxis: .horizontal)
        view.isUserInteractionEnabled = false
        view.addShadow(ofColor: UIColor(red: 106, green: 128, blue: 245)!, radius: 10, offset: CGSize(width: 0, height: 6), opacity: 0.35)

        button.tag = viewControllers!.count + 1
        button.addTarget(self, action: #selector(buttonAddTapped), for: .touchUpInside)
        
        return button
    }
    
    @objc func switchTab(button: UIButton) {
        switchTab(index: button.tag)
    }

    func switchTab(index: Int) {
        // pop to first if index is selected
        if selectedIndex == index {
            if let navController = viewControllers?[index] as? UINavigationController {
                if navController.viewControllers.count > 1 {
                    navController.popViewController(animated: true)
                } else {
                    navController.topViewController?.scrollToTop()
                }
            }
            return
        }
        
        // change selected index
        selectedIndex = index
        
        // change tabs' color
        let items = tabBarStackView.arrangedSubviews.filter {$0.tag != (viewControllers?.count ?? 0) + 1}
        let selectedItem = items.first {$0.tag == selectedIndex}
        let unselectedItems = items.filter {$0.tag != selectedIndex}
        selectedItem?.tintColor = selectedColor
        for item in unselectedItems {
            item.tintColor = unselectedColor
        }
        
        // markAllAsViewed
        if let nc = selectedViewController as? BaseNavigationController,
            let vc = nc.topViewController as? NotificationsPageVC
        {
            let vm = vc.viewModel as! NotificationsPageViewModel
            vm.items
                .filter {$0.count > 0}
                .take(1)
                .asSingle()
                .subscribe(onSuccess: { (items) in
                    guard let timestamp = items.first?.timestamp else {
                        return
                    }
                    vm.markAllAsViewed(timestamp: timestamp)
                })
                .disposed(by: bag)
        }
    }
    
    @objc func buttonAddTapped() {
        var community: ResponseAPIContentGetCommunity?
        if let vc = UIApplication.topViewController() as? CommunityPageVCType,
            let comm = vc.community,
            comm.isSubscribed == true
        {
            community = comm
        }
        let basicEditorScene = BasicEditorVC(community: community)
        self.present(basicEditorScene, animated: true, completion: nil)
    }
    
    func bind() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.notificationTappedRelay
            .skipWhile {$0 == .empty}
            .subscribe(onNext: { (item) in
                self.selectedViewController?.navigateWithNotificationItem(item)
            })
            .disposed(by: bag)
        
        appDelegate.deepLinkPath
            .filter {!$0.isEmpty}
            .subscribe(onNext: { (path) in
                self.navigateWithDeeplinkPath(path)
            })
            .disposed(by: bag)
        
        appDelegate.shareExtensionDataRelay
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { (data) in
                if let presentedVC = self.presentedViewController as? BasicEditorVC {
                    if !presentedVC.contentTextView.text.isEmpty || presentedVC._viewModel.attachment.value != nil
                    {
                        presentedVC.showAlert(title: "replace content".localized().uppercaseFirst, message: "you are currently editing a post".localized().uppercaseFirst + ".\n" + "would you like to replace this content".localized().uppercaseFirst, buttonTitles: ["OK", "Cancel"], highlightedButtonIndex: 1) { (index) in
                            if index == 0 {
                                presentedVC.shareExtensionData = data
                                presentedVC.loadShareExtensionData()
                            }
                        }
                    } else {
                        presentedVC.shareExtensionData = data
                        presentedVC.loadShareExtensionData()
                    }
                } else if let presentedVC = self.presentedViewController {
                    presentedVC.showAlert(title: "open editor".localized().uppercaseFirst, message: "close this screen and open editor".localized().uppercaseFirst + "?", buttonTitles: ["OK", "Cancel"], highlightedButtonIndex: 0) { (index) in
                        if index == 0 {
                            presentedVC.dismiss(animated: true) {
                                let basicEditorScene = BasicEditorVC(shareExtensionData: data)
                                self.present(basicEditorScene, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    let basicEditorScene = BasicEditorVC(shareExtensionData: data)
                    self.present(basicEditorScene, animated: true, completion: nil)
                }
                DispatchQueue.main.async {
                    appDelegate.shareExtensionDataRelay.accept(nil)
                }
            })
            .disposed(by: disposeBag)
            
        SocketManager.shared
            .unseenNotificationsRelay
            .subscribe(onNext: { (unseen) in
                self.setNotificationRedMarkHidden(unseen == 0)
                
                if let nc = self.selectedViewController as? BaseNavigationController,
                    let vc = nc.topViewController as? NotificationsPageVC
                {
                    let vm = vc.viewModel as? NotificationsPageViewModel
                    vm?.markAllAsViewed(timestamp: Date().iso8601String)
                }
            })
            .disposed(by: bag)
        
        // in-app notifications
        SocketManager.shared.newNotificationsRelay
            .filter {$0.count > 0}
            .subscribe(onNext: { (items) in
                guard let notif = items.first else {return}
                self.showNotificationViewWithNotification(notif)
            })
            .disposed(by: disposeBag)
    }
    
    private func navigateWithDeeplinkPath(_ path: [String]) {
        guard path.count == 1 || path.count == 3 else {return}
        if path.count == 1 {
            if path[0].starts(with: "@") {
                // user's profile
                let userId = String(path[0].dropFirst())
                self.selectedViewController?.showProfileWithUserId(userId)
            } else {
                // community
                let alias = path[0]
                self.selectedViewController?.showCommunityWithCommunityAlias(alias)
            }
        } else {
            let communityAlias = path[0]
            let username = String(path[1].dropFirst())
            let permlink = path[2]
            
            let postVC = PostPageVC(username: username, permlink: permlink, communityAlias: communityAlias)
            self.selectedViewController?.show(postVC, sender: nil)
        }
    }
    
    private func showNotificationViewWithNotification(_ notification: ResponseAPIGetNotificationItem) {
        let notificationView = NotificationView.default
        notificationView.body = notification.content
        notificationView.identifier = notification.identity
        notificationView.delegate = self
        notificationView.show()
    }
}

extension TabBarVC: NotificationViewDelegate {
    func notificationViewDidTap(_ notificationView: NotificationView) {
        guard let notif = SocketManager.shared.newNotificationsRelay.value.first(where: {$0.identity == notificationView.identifier}) else {return}
        (UIApplication.shared.delegate as! AppDelegate).notificationTappedRelay.accept(notif)
    }
}
