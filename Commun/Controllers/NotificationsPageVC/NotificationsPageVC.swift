//
//  NotificationsPageVC.swift
//  Commun
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NotificationsPageVC: ListViewController<ResponseAPIGetNotificationItem, NotificationCell> {
    // MARK: - Properties
    override var tableViewMargin: UIEdgeInsets {UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)}
    
    // MARK: - Initializers
    init() {
        let vm = NotificationsPageViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "notifications".localized().uppercaseFirst
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    override func handleListEmpty() {
        let title = "no notification"
        let description = "you haven't had any notification yet"
        tableView.addEmptyPlaceholderFooterView(emoji: "🙈", title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func handleLoading() {
        tableView.addNotificationsLoadingFooterView()
    }
}
