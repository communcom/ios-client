//
//  CommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityPageVC: PostsViewController {
    let communityId: String
    
    init(communityId: String) {
        self.communityId = communityId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        // assign tableView
        view.addSubview(tableView)
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.insetsContentViewsToSafeArea = false
        
        // assign header
        let headerView = CommunityHeaderView(frame: .zero)
        headerView.tableView = tableView
        let containerView = UIView(forAutoLayout: ())
        
        containerView.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges()
        
        tableView.tableHeaderView = containerView
        
        containerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        
        tableView.tableHeaderView?.layoutIfNeeded()
    }
    
    override func bind() {
        super.bind()
        
        
    }
    
    override func setUpViewModel() {
        viewModel = PostsViewModel(filter: PostsListFetcher.Filter(feedTypeMode: .community, feedType: .time, sortType: .all, communityId: communityId))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
