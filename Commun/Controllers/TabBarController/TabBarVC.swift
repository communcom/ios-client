//
//  TabBarVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 14/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import NotificationView

public let tabBarHeight: CGFloat = 60 + (UIDevice.hasNotch ? UIDevice.safeAreaInsets.bottom : 0.0)

class TabBarVC: UITabBarController {
    // MARK: - Nested type
    class Tabbar: CMBottomToolbar {
        override func commonInit() {
            super.commonInit()
            stackView.spacing = 0
            stackView.distribution = .fillEqually
        }
        
        override func pinStackView() {
            stackView.autoPinEdgesToSuperviewSafeArea(with: contentInset)
        }
    }
    
    // MARK: - Constants
    let feedTabIndex = 0
    let discoveryTabIndex = 1
    let notificationTabIndex = 2
    let profileTabIndex = 3
    let selectedColor: UIColor = .appBlackColor
    let unselectedColor: UIColor = .appGrayColor
    
    // MARK: - Properties
    let viewModel = TabBarViewModel()
    let disposeBag = DisposeBag()
    
    // MARK: - Subviews
    private lazy var customTabbar = Tabbar(height: tabBarHeight, cornerRadius: 20)
    
    // Notification
    private lazy var notificationsItem = buttonTabBarItem(image: UIImage(named: "notifications")!, tag: notificationTabIndex)
    private lazy var notificationRedMark: UIView = {
        let notificationRedMark = UIView(width: 10, height: 10, backgroundColor: .appRedColor, cornerRadius: 5)
        notificationRedMark.borderColor = .appWhiteColor
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
        
        // show post
        let post = RequestsManager.shared.pendingRequests.compactMap { request -> ResponseAPIContentGetPost? in
            switch request {
            case .newComment(let post, _, _):
                return post
            case .replyToComment(_, let post, _, _):
                return post
            default:
                return nil
            }
        }.first
        
        if let post = post {
            let vc = PostPageVC(post: post)
            selectedViewController?.show(vc, sender: self)
        }
    }
    
    func setTabBarHiden(_ hide: Bool) {
        if hide {
            customTabbar.isHidden = true
            customTabbar.heightConstraint?.constant = 0
        } else {
            customTabbar.isHidden = false
            customTabbar.heightConstraint?.constant = tabBarHeight
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
        view.backgroundColor = .appWhiteColor
        
        // hide default tabBar
        tabBar.isHidden = true
        
        // shadow
        view.addSubview(customTabbar)
        customTabbar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // https://stackoverflow.com/questions/39578530/since-xcode-8-and-ios10-views-are-not-sized-properly-on-viewdidlayoutsubviews
        customTabbar.layoutIfNeeded()
    }
    
    private func configTabs() {
        // Feed Tab
        let feed = createViewController(index: feedTabIndex)
        let feedNC = SwipeNavigationController(rootViewController: feed, tabBarVC: self)
        let feedItem = buttonTabBarItem(image: UIImage(named: "feed")!, tag: feedTabIndex)
        feed.accessibilityLabel = "TabBarFeedTabBarItem"

        // Comunities Tab
        let discoveryVC = createViewController(index: discoveryTabIndex)
        let discoveryNC = SwipeNavigationController(rootViewController: discoveryVC, tabBarVC: self)
        let discoveryItem = buttonTabBarItem(image: UIImage(named: "tabbar-discovery-icon")!, tag: discoveryTabIndex)
        discoveryVC.accessibilityLabel = "TabBarDiscoveryTabBarItem"
        
        // Notifications Tab
        let notifications = createViewController(index: notificationTabIndex)
        let notificationsNC = SwipeNavigationController(rootViewController: notifications, tabBarVC: self)
        notificationsNC.navigationBar.prefersLargeTitles = true
        notifications.accessibilityLabel = "TabBarNotificationsTabBarItem"

        // Profile Tab
        let profile = createViewController(index: profileTabIndex)
        let profileNC = SwipeNavigationController(rootViewController: profile, tabBarVC: self)
        let profileItem = buttonTabBarItem(image: UIImage(named: "tabbar-profile")!, tag: profileTabIndex)
        profileNC.accessibilityLabel = "TabBarProfileTabBarItem"
        profileNC.navigationBar.tintColor = UIColor.appMainColor

        // Set up controllers
        viewControllers = [feedNC, discoveryNC, /* wallet,*/ notificationsNC, profileNC]
        
        customTabbar.stackView.addArrangedSubviews([
            feedItem,
            discoveryItem,
            tabBarItemAdd,
            notificationsItem,
            profileItem
        ])
                
        // highlight first
        feedItem.tintColor = selectedColor
    }
    
    func createViewController(index: Int) -> BaseViewController {
        switch index {
        case feedTabIndex:
            return FeedPageVC()
        case discoveryTabIndex:
            return DiscoveryVC()
        case notificationTabIndex:
            return NotificationsPageVC()
        case profileTabIndex:
            return MyProfilePageVC()
        default:
            fatalError()
        }
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
        
        let itemSize: CGFloat = 45
        let itemPadding: CGFloat = 14
        
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
        view.addShadow(ofColor: UIColor.onlyLightModeShadowColor(UIColor(red: 106, green: 128, blue: 245)!), radius: 10, offset: CGSize(width: 0, height: 6), opacity: 0.35)

        button.tag = viewControllers!.count + 1
        button.addTarget(self, action: #selector(buttonAddTapped), for: .touchUpInside)
        
        return button
    }
    
    @objc func switchTab(button: UIButton) {
        switchTab(index: button.tag)
    }

    func switchTab(index: Int) {
        // Remove notifications red marker
        if index == notificationTabIndex {
            self.setNotificationRedMarkHidden(true)
        }
        
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
        let items = customTabbar.stackView.arrangedSubviews.filter {$0.tag != (viewControllers?.count ?? 0) + 1}
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
                .disposed(by: disposeBag)
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
                if UIApplication.topViewController() is CreateCommunityVC {return}
                self.selectedViewController?.navigateWithNotificationItem(item)
            })
            .disposed(by: disposeBag)
        
        appDelegate.deepLinkPath
            .filter {!$0.isEmpty}
            .subscribe(onNext: { (path) in
                self.navigateWithDeeplinkPath(path)
            })
            .disposed(by: disposeBag)
        
        appDelegate.shareExtensionDataRelay
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { (data) in
                if let presentedVC = self.presentedViewController as? BasicEditorVC {
                    if !presentedVC.contentTextView.text.isEmpty || presentedVC._viewModel.attachment.value != nil {
                        presentedVC.showAlert(title: "replace content".localized().uppercaseFirst, message: "you are currently editing a post".localized().uppercaseFirst + ".\n" + "would you like to replace this content".localized().uppercaseFirst, buttonTitles: ["OK".localized(), "Cancel".localized()], highlightedButtonIndex: 1) { (index) in
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
                    if let activityVC = presentedVC as? UIActivityViewController {
                        activityVC.dismiss(animated: true, completion: {
                            let basicEditorScene = BasicEditorVC(shareExtensionData: data, chooseCommunityAfterLoading: true)
                            self.present(basicEditorScene, animated: true, completion: nil)
                        })
                    } else {
                        presentedVC.showAlert(title: "open editor".localized().uppercaseFirst, message: "close this screen and open editor".localized().uppercaseFirst + "?", buttonTitles: ["OK".localized(), "Cancel".localized()], highlightedButtonIndex: 0) { (index) in
                            if index == 0 {
                                presentedVC.dismiss(animated: true) {
                                    let basicEditorScene = BasicEditorVC(shareExtensionData: data)
                                    self.present(basicEditorScene, animated: true, completion: nil)
                                }
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
            
        NotificationsManager.shared
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
            .disposed(by: disposeBag)
        
        // in-app notifications
        NotificationsManager.shared.newNotificationsRelay
            .filter {$0.count > 0}
            .map {$0.first!}
            .distinctUntilChanged()
            .subscribe(onNext: { (item) in
                self.showNotificationViewWithNotification(item)
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
                if !alias.isEmpty {
                    self.selectedViewController?.showCommunityWithCommunityAlias(alias)
                }
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
        guard let notif = NotificationsManager.shared.newNotificationsRelay.value.first(where: {$0.identity == notificationView.identifier}) else {return}
        (UIApplication.shared.delegate as! AppDelegate).notificationTappedRelay.accept(notif)
    }
}
