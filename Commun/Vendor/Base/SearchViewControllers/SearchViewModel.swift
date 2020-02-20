//
//  SearchViewModel.swift
//  Commun
//
//  Created by Chung Tran on 2/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SearchViewModel: ListViewModel<ResponseAPIContentSearchItem> {
    init() {
        let fetcher = SearchListFetcher()
        fetcher.limit = 5
        super.init(fetcher: fetcher)
    }
    
    override func observeItemChange() {
        ResponseAPIContentGetProfile.observeItemChanged()
            .subscribe(onNext: {newUser in
                self.updateItem(.profile(newUser))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemChanged()
            .subscribe(onNext: {newCommunity in
                self.updateItem(.community(newCommunity))
            })
            .disposed(by: disposeBag)
    }
    
    override func observeItemDeleted() {
        ResponseAPIContentGetProfile.observeItemDeleted()
            .subscribe(onNext: { (deletedItem) in
                self.deleteItem(.profile(deletedItem))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemDeleted()
            .subscribe(onNext: { (updatedCommunity) in
                self.deleteItem(.community(updatedCommunity))
            })
            .disposed(by: disposeBag)
    }
}
