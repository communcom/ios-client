//
//  TabBarVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 14/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class TabBarVC: UITabBarController {
    let viewModel = TabBarViewModel()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Config styles
        configStyles()

        // Config tabs
        configTabs()
        
        // bind view model
        bindViewModel()
    }
    
    private func configStyles() {
        view.backgroundColor = .white
        
        // Config styles
        tabBar.unselectedItemTintColor = #colorLiteral(red: 0.8971592784, green: 0.9046500325, blue: 0.9282500148, alpha: 1)
        tabBar.tintColor = UIColor.black
        
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().backgroundColor = .white
        
        // Remove default line
        tabBar.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 18)
        
        // Shadow
        let shadowView = UIView(frame: tabBar.frame)
        shadowView.backgroundColor = .white
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shadowView)
        view.bringSubviewToFront(tabBar)
        
        shadowView.topAnchor
            .constraint(equalTo: tabBar.topAnchor)
            .isActive = true
        shadowView.bottomAnchor
            .constraint(equalTo: tabBar.bottomAnchor)
            .isActive = true
        shadowView.leadingAnchor
            .constraint(equalTo: tabBar.leadingAnchor)
            .isActive = true
        shadowView.trailingAnchor
            .constraint(equalTo: tabBar.trailingAnchor)
            .isActive = true
        
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 18).cgPath
        shadowLayer.fillColor = UIColor.black.cgColor

        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.2
        shadowLayer.shadowRadius = 30

        shadowView.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    private func configTabs() {
        // Feed Tab
        let feed = controllerContainer.resolve(FeedPageVC.self)!
        let feedNC = SwipeNavigationController(rootViewController: feed)
        feedNC.tabBarItem = centerTabBarItem(withImageName: "feed", tag: 0)
        feed.accessibilityLabel = "TabBarFeedTabBarItem"

        // Comunities Tab
        let comunities = controllerContainer.resolve(CommunitiesVC.self)!
        let communitiesNC = SwipeNavigationController(rootViewController: comunities)
        communitiesNC.tabBarItem = centerTabBarItem(withImageName: "comunities", tag: 1)
        comunities.accessibilityLabel = "TabBarComunitiesTabBarItem"

        // Profile Tab
        let profile = controllerContainer.resolve(ProfilePageVC.self)!
        let profileNC = SwipeNavigationController(rootViewController: profile)
        profileNC.tabBarItem = centerTabBarItem(withImageName: "profile", tag: 2)
        profileNC.accessibilityLabel = "TabBarProfileTabBarItem"
        profileNC.navigationBar.tintColor = UIColor.appMainColor

        // Wallet Tab
        let wallet = UIViewController()
        wallet.tabBarItem = centerTabBarItem(withImageName: "wallet", tag: 3)
        wallet.accessibilityLabel = "TabBarWalletTabBarItem"
        
        // Notifications Tab
        let notifications = controllerContainer.resolve(NotificationsPageVC.self)!
        let notificationsNC = SwipeNavigationController(rootViewController: notifications)
        notificationsNC.tabBarItem = centerTabBarItem(withImageName: "notifications", tag: 4)
        notificationsNC.navigationBar.prefersLargeTitles = true
        notifications.accessibilityLabel = "TabBarNotificationsTabBarItem"
        
        // Set up controllers
        viewControllers = [feedNC, communitiesNC,/* wallet,*/ notificationsNC, profileNC]
    }
    
    private func centerTabBarItem(withImageName imageName: String, tag: Int) -> UITabBarItem {
        let item = UITabBarItem(title: nil, image: UIImage(named: imageName), tag: tag)
        item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        return item
    }

    func bindViewModel() {
        // Get number of fresh notifications
        viewModel.getFreshCount()
            .asDriver(onErrorJustReturn: 0)
            .map {$0 > 0 ? "\($0)" : nil}
            .drive(tabBar.items!.first(where: {$0.tag == 4})!.rx.badgeValue)
            .disposed(by: bag)
    }
}
