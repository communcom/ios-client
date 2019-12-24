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
    var filter: BehaviorRelay<TransferHistoryListFetcher.Filter>
    
    init() {
        let filter = TransferHistoryListFetcher.Filter(userId: Config.currentUser?.id, direction: "all", transferType: nil, symbol: nil, rewards: nil)
        self.filter = BehaviorRelay<TransferHistoryListFetcher.Filter>(value: filter)
        super.init(fetcher: TransferHistoryListFetcher(filter: filter))
        defer {
            bindFilter()
        }
    }
    
    func bindFilter() {
        filter.distinctUntilChanged()
            .subscribe(onNext: { (filter) in
                self.fetcher.reset(clearResult: false)
                (self.fetcher as! TransferHistoryListFetcher).filter = filter
                self.fetchNext()
            })
            .disposed(by: disposeBag)
    }
}
