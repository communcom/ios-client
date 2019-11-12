//
//  BaseViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        bind()
    }
    
    func setUp() {
        
    }
    
    func bind() {
        
    }
    
//    func avoidTabBar() {
//        // avoid tabBar
//        guard let scrollView = contentScrollView,
//            let tabBarController = tabBarController as? TabBarVC else {return}
//        var contentInsets = scrollView.contentInset
//        let insetsBottom = contentInsets.bottom + tabBarController.tabBarHeight
//        let defaultBottomOffset: CGFloat = 10
//        contentInsets.bottom = insetsBottom + defaultBottomOffset + view.safeAreaInsets.bottom
//        scrollView.scrollIndicatorInsets.bottom = insetsBottom + view.safeAreaInsets.bottom
//        scrollView.contentInset = contentInsets
//    }
}
