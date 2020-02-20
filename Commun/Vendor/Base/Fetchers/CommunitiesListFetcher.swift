//
//  CommunitiesListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class CommunitiesListFetcher: ListFetcher<ResponseAPIContentGetCommunity> {
    var type: GetCommunitiesType
    var userId: String?
    
    lazy var searchFetcher: SearchListFetcher = {
        let fetcher = SearchListFetcher()
        fetcher.limit = 20
        fetcher.searchType = .entitySearch
        fetcher.entitySearchEntity = .communities
        return fetcher
    }()
    
    init(type: GetCommunitiesType, userId: String? = nil) {
        self.type = type
        self.userId = userId
    }
    
    override var request: Single<[ResponseAPIContentGetCommunity]> {
        if let search = search {
            searchFetcher.search = search
            return searchFetcher.request.map {$0.compactMap {$0.communityValue}}
        }
//        if let search = search {
//            return RestAPIManager.instance.getCommunities(type: nil, userId: userId, offset: nil, limit: nil, search: search)
//                .map {$0.items}
//        }
        return RestAPIManager.instance.getCommunities(type: .all, userId: userId, offset: Int(offset), limit: Int(limit))
            .map {$0.items}
    }
    
    override func join(newItems items: [ResponseAPIContentGetCommunity]) -> [ResponseAPIContentGetCommunity] {
        if search != nil {
            return items
        }
        return super.join(newItems: items)
    }
}
