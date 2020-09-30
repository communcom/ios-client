//
//  ProposalsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
class ProposalsViewModel: ListViewModel<ResponseAPIContentGetProposal> {
    var proposalsCount: UInt64 {(fetcher as! ProposalsListFetcher).proposalsCount}
    
    init() {
        let fetcher = ProposalsListFetcher()
        super.init(fetcher: fetcher, prefetch: false)
        
        defer {
            observeItemHeight()
        }
    }
    
    func observeItemHeight() {
        ResponseAPIContentGetProposal.observeItemHeightChanged()
            .subscribe(onNext: { dict in
                for (key, value) in dict {
                    guard var item = self.fetcher.items.value.first(where: {$0.identity == key}) else {return}
                    if item.height != value {
                        item.height = value
                        item.notifyChanged()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func deleteItem(_ deletedItem: ResponseAPIContentGetProposal) {
        (fetcher as! ProposalsListFetcher).proposalsCount -= 1
        super.deleteItem(deletedItem)
    }
}
