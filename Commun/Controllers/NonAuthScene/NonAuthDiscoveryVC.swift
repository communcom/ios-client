//
//  NonAuthDiscoveryVC.swift
//  Commun
//
//  Created by Chung Tran on 7/8/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthDiscoveryVC: DiscoverySuggestionsVC, NonAuthVCType, SearchableViewControllerType {
    lazy var searchController = UISearchController.default()
    var searchBar: UISearchBar {
        get {searchController.searchBar}
        set {}
    }
    
    override init(showAllHandler: (() -> Void)? = nil, cancelSearchHandler: (() -> Void)? = nil) {
        super.init(showAllHandler: showAllHandler, cancelSearchHandler: cancelSearchHandler)
        (viewModel.fetcher as! SearchListFetcher).authorizationRequired = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        // search controller
        layoutSearchBar()
    }
    
    override func bind() {
        super.bind()
        bindSearchBar()
    }
    
    func layoutSearchBar() {
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchBar
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
}
