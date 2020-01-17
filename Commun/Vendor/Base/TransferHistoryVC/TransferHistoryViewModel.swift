//
//  TransferHistoryViewModel.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxCocoa

class TransferHistoryViewModel: ListViewModel<ResponseAPIWalletGetTransferHistoryItem> {
    var initialHistoryItems: [ResponseAPIWalletGetTransferHistoryItem]?
    var filter: BehaviorRelay<TransferHistoryListFetcher.Filter>
    
    init(initialItems: [ResponseAPIWalletGetTransferHistoryItem]? = nil) {
        if let initialItems = initialItems {
            self.initialHistoryItems = initialItems
        }
        let filter = TransferHistoryListFetcher.Filter(userId: Config.currentUser?.id, direction: "all", transferType: nil, symbol: nil, rewards: nil)
        self.filter = BehaviorRelay<TransferHistoryListFetcher.Filter>(value: filter)
        super.init(fetcher: TransferHistoryListFetcher(filter: filter))
        defer {
            bindFilter()
        }
    }
    
    func bindFilter() {
        var skip = 0
        if let initItems = initialHistoryItems {
            skip = 1
            items.accept(initItems)
        }
        
        filter.distinctUntilChanged()
            .skip(skip)
            .subscribe(onNext: { (filter) in
                self.fetcher.reset()
                (self.fetcher as! TransferHistoryListFetcher).filter = filter
                self.fetchNext()
            })
            .disposed(by: disposeBag)
    }
}
