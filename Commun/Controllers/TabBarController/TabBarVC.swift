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

public let tabBarHeight: CGFloat = CGFloat.adaptive(height: 60.0) + (UIDevice.hasNotch ? UIDevice.safeAreaInsets.bottom : 0.0)

class TabBarVC: UITabBarController {
    // MARK: - Constants
    let feedTabIndex = 0
    let searchTabIndex = 1
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
        let comunities = CommunitiesVC(type: .all)
        let communitiesNC = BaseNavigationController(rootViewController: comunities, tabBarVC: self)
        let communitiesItem = buttonTabBarItem(image: UIImage(named: "tabbar-discovery-icon")!, tag: searchTabIndex)
        comunities.accessibilityLabel = "TabBarComunitiesTabBarItem"
        
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
        viewControllers = [feedNC, communitiesNC, /* wallet,*/ notificationsNC, profileNC]
        
        tabBarStackView.addArrangedSubviews([
            feedItem,
            communitiesItem,
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
        
        let view = UIView(width: 45, height: 45, backgroundColor: .appMainColor)
        view.cornerRadius = 45 / 2
        
        let imageView = UIImageView(image: UIImage(named: "add"))
        imageView.configureForAutoLayout()
        imageView.tintColor = .white
        
        view.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        
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
    }
    
    @objc func buttonAddTapped() {
        // open basic editor
        let vc = BasicEditorVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
        // or select editor ???
//        showActionSheet(title: "choose an editor".localized().uppercaseFirst, actions: [
//            UIAlertAction(title: "basic editor".localized().uppercaseFirst, style: .default, handler: { (_) in
//                let vc = BasicEditorVC()
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)
//            }),
//            UIAlertAction(title: "article editor".localized().uppercaseFirst, style: .default, handler: { (_) in
//                let vc = ArticleEditorVC()
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)
//            }),
//        ])
    }

    func bind() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.notificationRelay
            .skipWhile {$0 == .empty}
            .subscribe(onNext: { (item) in
                self.selectedViewController?.navigateWithNotificationItem(item)
            })
            .disposed(by: bag)
        
        SocketManager.shared
            .unseenNotificationsRelay
            .subscribe(onNext: { (unseen) in
                print("unseenCountRelay \(unseen)")
                self.setNotificationRedMarkHidden(unseen == 0)
            })
            .disposed(by: bag)
        
        // Get number of fresh notifications
//        viewModel.getFreshCount()
//            .asDriver(onErrorJustReturn: 0)
//            .map {$0 > 0 ? "\($0)" : nil}
//            .drive(tabBar.items!.first(where: {$0.tag == 4})!.rx.badgeValue)
//            .disposed(by: bag)
    }
}
