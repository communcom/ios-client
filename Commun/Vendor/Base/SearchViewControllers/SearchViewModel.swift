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
    
    init(fetcher: SearchListFetcher) {
        super.init(fetcher: fetcher)
    }
    
    var query: String? {
        get {
            (fetcher as! SearchListFetcher).queryString
        }
        set {
            (fetcher as! SearchListFetcher).queryString = newValue
        }
        
    }
    
    var isQueryEmpty: Bool {
        (query == nil) || (query!.isEmpty)
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
        
        ResponseAPIContentGetPost.observeItemChanged()
            .subscribe(onNext: {newPost in
                self.updateItem(.post(newPost))
            })
            .disposed(by: disposeBag)
    }
    
    override func observeItemDeleted() {
        ResponseAPIContentGetProfile.observeItemDeleted()
            .subscribe(onNext: { (deletedProfile) in
                self.deleteItem(.profile(deletedProfile))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeItemDeleted()
            .subscribe(onNext: { (deletedCommunity) in
                self.deleteItem(.community(deletedCommunity))
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetPost.observeItemDeleted()
            .subscribe(onNext: { (deletedPost) in
                self.deleteItem(.post(deletedPost))
            })
            .disposed(by: disposeBag)
    }
}
