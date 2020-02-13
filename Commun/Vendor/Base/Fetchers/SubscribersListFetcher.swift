//
//  SubscribersListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class SubscribersListFetcher: ListFetcher<ResponseAPIContentGetProfile> {
    var userId: String?
    var communityId: String?
    
    lazy var searchFetcher: SearchListFetcher = {
        let fetcher = SearchListFetcher()
        fetcher.limit = 5
        fetcher.searchType = .quickSearch
        fetcher.entities = [.profiles]
        return fetcher
    }()
    
    override var request: Single<[ResponseAPIContentGetProfile]> {
        if let search = search {
            searchFetcher.search = search
            return searchFetcher.request.map {$0.compactMap {$0.profileValue}}
        }
        
        return RestAPIManager.instance.getSubscribers(userId: userId, communityId: communityId, offset: Int(offset), limit: Int(limit))
//        return ResponseAPIContentGetSubscribers.singleWithMockData()
//            .delay(0.8, scheduler: MainScheduler.instance)
            .map {$0.items}
    }
    
    override func join(newItems items: [ResponseAPIContentGetProfile]) -> [ResponseAPIContentGetProfile] {
        if search != nil {
            return items
        }
        return super.join(newItems: items)
    }
}
