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
    
    init(userId: String, type: GetSubscriptionsType) {
        self.userId = userId
        self.type = type
        super.init()
    }
    
    override var request: Single<[ResponseAPIContentGetSubscriptionsItem]> {
        RestAPIManager.instance.getSubscriptions(userId: userId, type: type, offset: Int(offset), limit: Int(limit))
            .map {$0.items}
    }
}
