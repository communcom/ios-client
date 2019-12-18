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
    
    override var request: Single<[ResponseAPIWalletGetTransferHistoryItem]> {
        // TODO: - Remove mock, replace by real request
        ResponseAPIWalletGetTransferHistory.singleWithMockData()
            .map {$0.items}
            .delay(0.8, scheduler: MainScheduler.instance)
    }
}
