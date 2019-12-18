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
    var userId: String? = Config.currentUser?.id
    var direction: String = "all"
    var transferType: String = "all"
    var symbol: String?
    var rewards: String = "all"
    
    override init() {
        super.init()
        self.limit = 20
    }
    
    override var request: Single<[ResponseAPIWalletGetTransferHistoryItem]> {
        RestAPIManager.instance.getTransferHistory(userId: userId, direction: direction, transferType: transferType, symbol: symbol, reward: rewards, offset: offset, limit: limit)
            .map {$0.items}
//        ResponseAPIWalletGetTransferHistory.singleWithMockData()
//            .map {$0.items}
//            .delay(0.8, scheduler: MainScheduler.instance)
    }
}
