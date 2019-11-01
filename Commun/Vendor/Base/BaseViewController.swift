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
            let tabBarController = tabBarController as? TabBarVC else {return}
        var contentInsets = scrollView.contentInset
        
        var insetsBottom = contentInsets.bottom + tabBarController.tabBarHeight
        
        if let tableView = scrollView as? UITableView {
            if tableView.insetsContentViewsToSafeArea {
                insetsBottom -= (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            }
        }
        
        contentInsets.bottom = insetsBottom
        
        scrollView.contentInset = contentInsets
        tabBarController.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Add white view in bottom safe area
        let bottomView = UIView(width: self.view.frame.width, height: 40.0, backgroundColor: .white, cornerRadius: 0.0)
        self.view.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
    }
}
