//
//  BaseViewController.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    // Override this property to avoid Tabbar
    var contentScrollView: UIScrollView? { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        bind()
        avoidTabBar()
    }
    
    func setUp() {
        
    }
    
    func bind() {
        
    }
    
    func avoidTabBar() {
        // avoid tabBar
        guard let scrollView = contentScrollView,
            let tabBarController = tabBarController else {return}
        var contentInsets = scrollView.contentInset
        contentInsets.bottom = tabBarController.tabBar.height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        
        scrollView.contentInset = contentInsets
    }
}
