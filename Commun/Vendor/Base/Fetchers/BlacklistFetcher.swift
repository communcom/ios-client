//
//  BlacklistFetcher.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class BlacklistFetcher: ListFetcher<ResponseAPIContentGetBlacklistItem> {
    var type: GetBlacklistType
    
    init(type: GetBlacklistType) {
        self.type = type
    }
    
    override var request: Single<[ResponseAPIContentGetBlacklistItem]> {
        return RestAPIManager.instance.getBlacklist(type: type, offset: Int(offset), limit: Int(limit))
            .map {result in
                var items = [ResponseAPIContentGetBlacklistItem]()
                for item in result.items {
                    switch item {
                    case .user(var user):
                        user.isInBlacklist = true
                        items.append(ResponseAPIContentGetBlacklistItem.user(user))
                    case .community(var community):
                        community.isInBlacklist = true
                        items.append(ResponseAPIContentGetBlacklistItem.community(community))
                    }
                }
                return items
            }
    }
}
