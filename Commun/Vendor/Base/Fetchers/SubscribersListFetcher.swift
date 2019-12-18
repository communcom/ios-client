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

class SubscribersListFetcher: ListFetcher<ResponseAPIContentResolveProfile> {
    var userId: String?
    var communityId: String?
    
    override var request: Single<[ResponseAPIContentResolveProfile]> {
        return RestAPIManager.instance.getSubscribers(userId: userId, communityId: communityId, offset: Int(offset), limit: Int(limit))
//        return ResponseAPIContentGetSubscribers.singleWithMockData()
//            .delay(0.8, scheduler: MainScheduler.instance)
            .map {$0.items}
    }
}
