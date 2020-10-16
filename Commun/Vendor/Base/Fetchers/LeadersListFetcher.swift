//
//  LeadersListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class LeadersListFetcher: ListFetcher<ResponseAPIContentGetLeader> {
    var communityId: String?
    var communityAlias: String?
    var sequenceKey: String?
    var query: String?
    var authorizationRequired: Bool = true
    
    init(communityId: String? = nil, communityAlias: String? = nil, query: String? = nil, authorizationRequired: Bool = true) {
        self.communityId    = communityId
        self.communityAlias = communityAlias
        self.query          = query
        self.authorizationRequired = authorizationRequired
        super.init()
    }
    
    override var request: Single<[ResponseAPIContentGetLeader]> {
//        return ResponseAPIContentGetLeaders.singleWithMockData()
//            .delay(0.8, scheduler: MainScheduler.instance)
        return RestAPIManager.instance.getLeaders(communityId: communityId, communityAlias: communityAlias, sequenceKey: sequenceKey, query: query, authorizationRequired: authorizationRequired)
            .map {$0.items.map { leader in
                var leader = leader
                leader.communityId = self.communityId
                return leader
            }}
    }
}
