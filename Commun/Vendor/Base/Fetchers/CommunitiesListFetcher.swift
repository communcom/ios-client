//
//  CommunitiesListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class CommunitiesListFetcher: ListFetcher<ResponseAPIContentGetCommunity> {
    var type: GetCommunitiesType
    var userId: String?
    
    init(type: GetCommunitiesType, userId: String? = nil) {
        self.type = type
        self.userId = userId
    }
    
    override var request: Single<[ResponseAPIContentGetCommunity]> {
//        if let search = search {
//            return RestAPIManager.instance.getCommunities(type: nil, userId: userId, offset: nil, limit: nil, search: search)
//                .map {$0.items}
//        }
        return RestAPIManager.instance.getCommunities(type: .all, userId: userId, offset: Int(offset), limit: Int(limit), search: search)
            .map {$0.items}
    }
}
