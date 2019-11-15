//
//  BlacklistViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
        ResponseAPIContentGetBlacklistUser.observeItemChanged()
            .subscribe(onNext: {newUser in
                self.updateItem(.user(newUser))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetBlacklistCommunity.observeItemChanged()
            .subscribe(onNext: {newCommunity in
                self.updateItem(.community(newCommunity))
            })
            .disposed(by: disposeBag)
    }
    
    override func observeItemDeleted() {
        ResponseAPIContentGetBlacklistUser.observeItemDeleted()
            .subscribe(onNext: { (deletedItem) in
                self.deleteItem(.user(deletedItem))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetBlacklistCommunity.observeItemDeleted()
            .subscribe(onNext: { (updatedCommunity) in
                self.deleteItem(.community(updatedCommunity))
            })
            .disposed(by: disposeBag)
    }
}
