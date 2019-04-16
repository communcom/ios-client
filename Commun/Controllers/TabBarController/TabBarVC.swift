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
        feed.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(named: "feed"), tag: 0)
        feed.accessibilityLabel = "TabBarFeedTabBarItem"
        
        // Comunities Tab
        let comunities = UIViewController()
        comunities.tabBarItem = UITabBarItem(title: "Сomunities", image: UIImage(named: "comunities"), tag: 1)
        comunities.accessibilityLabel = "TabBarComunitiesTabBarItem"
        
        // Profile Tab
        let profile = UIViewController()
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), tag: 2)
        profile.accessibilityLabel = "TabBarProfileTabBarItem"
        
        // Wallet Tab
        let wallet = UIViewController()
        wallet.tabBarItem = UITabBarItem(title: "Wallet", image: UIImage(named: "wallet"), tag: 3)
        wallet.accessibilityLabel = "TabBarWalletTabBarItem"
        
        // Notifications Tab
        let notifications = controllerContainer.resolve(NotificationsPageVC.self)!
        let notificationsNC = UINavigationController(rootViewController: notifications)
        notificationsNC.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(named: "notifications"), tag: 4)
        notificationsNC.navigationBar.prefersLargeTitles = true
        notifications.accessibilityLabel = "TabBarNotificationsTabBarItem"
        
        // Set up controllers
        self.viewControllers = [feed, comunities, profile, wallet, notificationsNC]
        
        // Config styles
        self.tabBar.tintColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
        UITabBar.appearance().barTintColor = .white
        
        // bind view model
        bindViewModel()
    }

    func bindViewModel() {
        // Get number of fresh notifications
        viewModel.getFreshCount()
            .asDriver(onErrorJustReturn: 0)
            .map {$0 > 0 ? "\($0)" : nil}
            .drive(tabBar.items!.last!.rx.badgeValue)
            .disposed(by: bag)
    }
}
