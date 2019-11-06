//
//  SubsViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

/// Reusable viewcontroller for subscriptions/subscribers vc
class SubsViewController<T: ListItemType>: ListViewController<T> {
    lazy var closeButton = UIButton.circleGray(imageName: "close-x")
    
    override var tableViewInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    override func setUp() {
        super.setUp()
        navigationItem.hidesBackButton = true
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.backgroundColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
        tableView.backgroundColor = .clear
        tableView.separatorInset = .zero
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    override func handleLoading() {
        tableView.addNotificationsLoadingFooterView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
