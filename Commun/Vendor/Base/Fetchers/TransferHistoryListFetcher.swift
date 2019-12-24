//
//  TransferHistoryListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class TransferHistoryListFetcher: ListFetcher<ResponseAPIWalletGetTransferHistoryItem> {
    // MARK: - Nested type
    struct Filter: FilterType {
        var userId: String? = Config.currentUser?.id
        var direction: String = "all"
        var transferType: String?
        var symbol: String?
        var rewards: String?
    }
    
    var filter: Filter
    
    required init(filter: Filter) {
        self.filter = filter
        super.init()
        self.limit = 20
    }
    
    override var request: Single<[ResponseAPIWalletGetTransferHistoryItem]> {
        RestAPIManager.instance.getTransferHistory(userId: filter.userId, direction: filter.direction, transferType: filter.transferType, symbol: filter.symbol, reward: filter.rewards, offset: offset, limit: limit)
            .map {$0.items}
//        ResponseAPIWalletGetTransferHistory.singleWithMockData()
//            .map {$0.items}
//            .delay(0.8, scheduler: MainScheduler.instance)
    }
}
