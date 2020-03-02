//
//  DiscoveryAllViewModel.swift
//  Commun
//
//  Created by Chung Tran on 2/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class DiscoveryAllViewModel: SearchViewModel {
    var followingVM: SubscriptionsViewModel
    var communitiesVM: SubscriptionsViewModel
    
    override init() {
        followingVM = SubscriptionsViewModel(type: .user, prefetch: false)
        communitiesVM = SubscriptionsViewModel(type: .community, prefetch: false)
        
        followingVM.fetcher.limit = 5
        communitiesVM.fetcher.limit = 5
        
        followingVM.fetchNext()
        communitiesVM.fetchNext()
        
        super.init()
        (fetcher as! SearchListFetcher).searchType = .extendedSearch
        (fetcher as! SearchListFetcher).extendedSearchEntity = [
            .profiles: ["limit": 5, "offset": 0],
            .communities: ["limit": 5, "offset": 0],
            .posts: ["limit": 5, "offset": 0]
        ]
    }
    
    var subscriptions: Observable<[ResponseAPIContentSearchItem]> {
        let users = followingVM.items.map {
            $0.compactMap {
                $0.userValue == nil ? nil : ResponseAPIContentSearchItem.profile($0.userValue!)
            }.prefix(5)
        }
        let communities = communitiesVM.items.map {
            $0.compactMap {
                $0.communityValue == nil ? nil : ResponseAPIContentSearchItem.community($0.communityValue!)
            }.prefix(5)
        }
        return Observable.zip(users, communities).map {Array($0) + Array($1)}
    }
    
    override func reload(clearResult: Bool = true) {
        if isQueryEmpty {
            // clear subscriptions
            followingVM.reload(clearResult: clearResult)
            communitiesVM.reload(clearResult: clearResult)
        } else {
            super.reload(clearResult: clearResult)
        }
    }
}
