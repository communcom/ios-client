//
//  DiscoveryPostsVC.swift
//  Commun
//
//  Created by Chung Tran on 2/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DiscoveryPostsVC: PostsViewController {
    init(prefetch: Bool = true) {
        super.init(filter: PostsListFetcher.Filter(feedTypeMode: .subscriptionsPopular, feedType: .time, sortType: .day, userId: Config.currentUser?.id), prefetch: prefetch)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .f3f5fa
    }
    
    override func setUpTableView() {
        super.setUpTableView()
        tableView.backgroundColor = .f3f5fa
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    override func search(_ keyword: String?) {
        viewModel.rowHeights = [:]
        super.search(keyword)
    }
}
