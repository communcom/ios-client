//
//  CommunitiesListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift
import RxCocoa

class SubscriptionsListFetcher: ListFetcher<ResponseAPIContentGetSubscriptionsItem> {
    var userId: String
    var type: GetSubscriptionsType
    
    lazy var searchFetcher: SearchListFetcher = {
        let fetcher = SearchListFetcher()
        fetcher.limit = 20
        fetcher.searchType = .entitySearch
        fetcher.entitySearchEntity = .profiles
        return fetcher
    }()
    
    init(userId: String, type: GetSubscriptionsType) {
        self.userId = userId
        self.type = type
        super.init()
    }
    
    override var request: Single<[ResponseAPIContentGetSubscriptionsItem]> {
        if let search = search {
            searchFetcher.search = search
            return searchFetcher.request.map {$0.compactMap {$0.profileValue}.compactMap {ResponseAPIContentGetSubscriptionsItem.user($0)}}
        }
        return RestAPIManager.instance.getSubscriptions(userId: userId, type: type, offset: Int(offset), limit: Int(limit))
            .map {$0.items}
    }
    
    override func join(newItems items: [ResponseAPIContentGetSubscriptionsItem]) -> [ResponseAPIContentGetSubscriptionsItem] {
        if search != nil {
            return items
        }
        return super.join(newItems: items)
    }
}
