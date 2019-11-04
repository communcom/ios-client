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
    override var tableViewInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
        tableView.cornerRadius = 10
        tableView.backgroundColor = .clear
        tableView.separatorInset = .zero
    }
    
    override func handleLoading() {
        tableView.addNotificationsLoadingFooterView()
    }
}
