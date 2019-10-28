//
//  LeadersListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class LeadersListFetcher: ListFetcher<ResponseAPIContentGetLeader> {
    var communityId: String
    var sequenceKey: String?
    var query: String?
    
    init(communityId: String, query: String? = nil) {
        self.communityId    = communityId
        self.query          = query
        super.init()
    }
    
    override var request: Single<[ResponseAPIContentGetLeader]> {
        return RestAPIManager.instance.getLeaders(communityId: communityId, sequenceKey: sequenceKey, query: query)
            .map {$0.items}
    }
}
