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
        followingVM = SubscriptionsViewModel.ofCurrentUser(type: .user)
        communitiesVM = SubscriptionsViewModel.ofCurrentUser(type: .community)
        
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
            $0
                .filter{$0.userValue?.isSubscribed == true}
                .sorted(by: {($0.userValue?.username ?? "") < ($1.userValue?.username ?? "")})
                .compactMap {
                    $0.userValue == nil ? nil : ResponseAPIContentSearchItem.profile($0.userValue!)
                }
                .prefix(5)
        }
        let communities = communitiesVM.items.map {
            $0
                .filter{$0.communityValue?.isSubscribed == true}
                .sorted(by: {($0.communityValue?.name ?? "") < ($1.communityValue?.name ?? "")})
                .compactMap {
                    $0.communityValue == nil ? nil : ResponseAPIContentSearchItem.community($0.communityValue!)
                }
                .prefix(5)
        }
        return Observable.combineLatest(users, communities).map {Array($0) + Array($1)}
    }
    
    var subscriptionsFetcherState: Observable<ListFetcherState> {
        let usersFetcherState = followingVM.state.asObservable()
        let communitiesFetcherState = communitiesVM.state.asObservable()
        return Observable.combineLatest(usersFetcherState, communitiesFetcherState)
            .map {(state1, state2) -> ListFetcherState in
                switch state1 {
                case .loading(let isLoading):
                    if isLoading {return .loading(true)}
                    switch state2 {
                    case .loading(let isLoading2):
                        if isLoading != isLoading2 {return .loading(true)}
                        return .listEnded
                    case .listEmpty, .listEnded:
                        return .listEnded
                    case .error(let error):
                        return .error(error: error)
                    }
                case .listEmpty:
                    switch state2 {
                    case .loading(let isLoading):
                        if isLoading {return .loading(true)}
                        return .listEnded
                    case .listEmpty, .listEnded:
                        return .listEnded
                    case .error(let error):
                        return .error(error: error)
                    }
                case .listEnded:
                    switch state2 {
                    case .loading(let isLoading):
                        if isLoading {return .loading(true)}
                        return .listEnded
                    case .listEmpty, .listEnded:
                        return .listEnded
                    case .error(let error):
                        return .error(error: error)
                    }
                case .error(let error):
                    switch state2 {
                    case .loading(let isLoading):
                        if isLoading {return .loading(true)}
                        return .error(error: error)
                    case .listEmpty:
                        return .error(error: error)
                    case .listEnded:
                        return .error(error: error)
                    case .error:
                        return .error(error: error)
                    }
                }
            }
    }
    
    override func fetchNext(forceRetry: Bool = false) {
        if isQueryEmpty {
            followingVM.fetchNext(forceRetry: forceRetry)
            communitiesVM.fetchNext(forceRetry: forceRetry)
        } else {
            super.fetchNext(forceRetry: forceRetry)
        }
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
