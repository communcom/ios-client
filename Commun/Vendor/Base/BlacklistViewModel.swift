//
//  BlacklistViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class BlacklistViewModel: ListViewModel<ResponseAPIContentGetBlacklistItem> {
    let type: GetBlacklistType
    init(type: GetBlacklistType) {
        let fetcher = BlacklistFetcher(type: type)
        self.type = type
        super.init(fetcher: fetcher)
    }
    
    override func observeItemChange() {
        ResponseAPIContentGetProfile.observeItemChanged()
            .subscribe(onNext: {newUser in
                self.updateItem(.user(newUser))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemChanged()
            .subscribe(onNext: {newCommunity in
                self.updateItem(.community(newCommunity))
            })
            .disposed(by: disposeBag)
        
//        ResponseAPIContentGetProfile.observeItemChanged()
//            .map {ResponseAPIContentGetBlacklistItem.user(ResponseAPIContentGetBlacklistUser()}
    }
    
    override func observeItemDeleted() {
        ResponseAPIContentGetProfile.observeItemDeleted()
            .subscribe(onNext: { (deletedItem) in
                self.deleteItem(.user(deletedItem))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemDeleted()
            .subscribe(onNext: { (updatedCommunity) in
                self.deleteItem(.community(updatedCommunity))
            })
            .disposed(by: disposeBag)
    }
}
