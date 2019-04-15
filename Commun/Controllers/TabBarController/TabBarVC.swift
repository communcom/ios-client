//
//  TabBarVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 14/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        // Feed Tab
        let feed = controllerContainer.resolve(FeedPageVC.self)!
        feed.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(named: "feed"), tag: 0)
        
        // Comunities Tab
        let comunities = UIViewController()
        comunities.tabBarItem = UITabBarItem(title: "Сomunities", image: UIImage(named: "comunities"), tag: 1)
        
        // Profile Tab
        let profile = UIViewController()
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), tag: 2)
        
        // Wallet Tab
        let wallet = UIViewController()
        wallet.tabBarItem = UITabBarItem(title: "Wallet", image: UIImage(named: "wallet"), tag: 3)
        
        // Notifications Tab
        let notifications = controllerContainer.resolve(NotificationsPageVC.self)!
        let notificationsNC = UINavigationController(rootViewController: notifications)
        notificationsNC.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(named: "notifications"), tag: 4)
        notificationsNC.navigationBar.prefersLargeTitles = true
        
        // Set up controllers
        self.viewControllers = [feed, comunities, profile, wallet, notificationsNC]
        
        // Config styles
        self.tabBar.tintColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
        UITabBar.appearance().barTintColor = .white
    }

}
