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

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        // Feed Tab
        let feed = controllerContainer.resolve(FeedPageVC.self)!
        let feedNC = UINavigationController(rootViewController: feed)
        feedNC.tabBarItem = centerTabBarItem(withImageName: "feed", tag: 0)
        feed.accessibilityLabel = "TabBarFeedTabBarItem"

        // Comunities Tab
        let comunities = controllerContainer.resolve(CommunitiesVC.self)!
        comunities.tabBarItem = centerTabBarItem(withImageName: "comunities", tag: 1)
        comunities.accessibilityLabel = "TabBarComunitiesTabBarItem"

        // Profile Tab
        let profile = controllerContainer.resolve(ProfilePageVC.self)!
        let profileNC = UINavigationController(rootViewController: profile)
        profileNC.tabBarItem = centerTabBarItem(withImageName: "profile", tag: 2)
        profileNC.accessibilityLabel = "TabBarProfileTabBarItem"
        profileNC.navigationBar.tintColor = UIColor.appMainColor

        // Wallet Tab
        let wallet = UIViewController()
        wallet.tabBarItem = centerTabBarItem(withImageName: "wallet", tag: 3)
        wallet.accessibilityLabel = "TabBarWalletTabBarItem"
        
        // Notifications Tab
        let notifications = controllerContainer.resolve(NotificationsPageVC.self)!
        let notificationsNC = UINavigationController(rootViewController: notifications)
        notificationsNC.tabBarItem = centerTabBarItem(withImageName: "notifications", tag: 4)
        notificationsNC.navigationBar.prefersLargeTitles = true
        notifications.accessibilityLabel = "TabBarNotificationsTabBarItem"
        
        // Set up controllers
        self.viewControllers = [feedNC, comunities,/* wallet,*/ notificationsNC, profileNC]
        
        // Config styles
        self.tabBar.unselectedItemTintColor = #colorLiteral(red: 0.8971592784, green: 0.9046500325, blue: 0.9282500148, alpha: 1)
        self.tabBar.tintColor = UIColor.black
        UITabBar.appearance().barTintColor = .white
        
        // bind view model
        bindViewModel()
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
