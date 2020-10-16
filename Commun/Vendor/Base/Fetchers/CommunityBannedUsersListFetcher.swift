//
//  CommunityBannedUsersListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/9/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class CommunityBannedUsersListFetcher: ListFetcher<ResponseAPIContentGetProfile> {
    var communityId: String
    init(communityId: String) {
        self.communityId = communityId
    }
    
    override var request: Single<[ResponseAPIContentGetProfile]> {
        RestAPIManager.instance.getCommunityBlacklist(communityId: communityId, limit: Int(limit), offset: Int(offset))
            .map {$0.items}
    }
}
