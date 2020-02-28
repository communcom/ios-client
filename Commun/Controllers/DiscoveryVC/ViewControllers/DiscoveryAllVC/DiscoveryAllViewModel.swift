//
//  DiscoveryAllViewModel.swift
//  Commun
//
//  Created by Chung Tran on 2/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DiscoveryAllViewModel: SearchViewModel {
    var followingVM: SubscriptionsViewModel
    var communitiesVM: SubscriptionsViewModel
    
    override init() {
        followingVM = SubscriptionsViewModel(type: .user)
        communitiesVM = SubscriptionsViewModel(type: .community)
        
        super.init()
        (fetcher as! SearchListFetcher).searchType = .extendedSearch
        (fetcher as! SearchListFetcher).extendedSearchEntity = [
            .profiles: ["limit": 5, "offset": 0],
            .communities: ["limit": 5, "offset": 0],
            .posts: ["limit": 5, "offset": 0]
        ]
    }
}
