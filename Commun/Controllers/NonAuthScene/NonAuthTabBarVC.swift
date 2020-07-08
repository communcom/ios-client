//
//  NonAuthTabBarVC.swift
//  Commun
//
//  Created by Chung Tran on 7/8/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthTabBarVC: TabBarVC, NonAuthVCType {
    override func createViewController(index: Int) -> BaseViewController {
        switch index {
        case feedTabIndex:
            return NonAuthFeedPageVC()
        case discoveryTabIndex:
            return NonAuthDiscoveryVC()
        case notificationTabIndex:
            return BaseViewController()
        case profileTabIndex:
            return BaseViewController()
        default:
            fatalError()
        }
    }
    
    override func switchTab(index: Int) {
        if index == notificationTabIndex || index == profileTabIndex {
            showAuthVC()
            return
        }
        super.switchTab(index: index)
    }
}
