//
//  NonAuthDiscoveryVC.swift
//  Commun
//
//  Created by Chung Tran on 7/8/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthSuggestionsVC: DiscoverySuggestionsVC, NonAuthVCType {
    override init(showAllHandler: (() -> Void)? = nil, cancelSearchHandler: (() -> Void)? = nil) {
        super.init(showAllHandler: showAllHandler, cancelSearchHandler: cancelSearchHandler)
        (viewModel.fetcher as! SearchListFetcher).authorizationRequired = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
}
