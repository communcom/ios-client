//
//  CommunitiesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class CommunitiesViewModel: ListViewModel<ResponseAPIContentGetCommunity> {
    lazy var searchVM: SearchViewModel = createSearchVM()
    
    func createSearchVM() -> SearchViewModel {
        let fetcher = SearchListFetcher()
        fetcher.limit = 20
        fetcher.searchType = .entitySearch
        fetcher.entitySearchEntity = .communities
        return SearchViewModel(fetcher: fetcher)
    }
    
    init(type: GetCommunitiesType, userId: String? = nil, authorizationRequired: Bool = true, prefetch: Bool = true) {
        let fetcher = CommunitiesListFetcher(type: type, userId: userId, authorizationRequired: authorizationRequired)
        super.init(fetcher: fetcher, prefetch: prefetch)
        self.fetcher = fetcher
    }
    
    var mergedState: Observable<ListFetcherState> {
        Observable.merge(
            state.filter {_ in self.searchVM.isQueryEmpty},
            searchVM.state.filter {_ in !self.searchVM.isQueryEmpty}
        )
    }
    
    var mergedItems: Observable<[ResponseAPIContentGetCommunity]> {
        Observable.merge(
            items.filter {_ in self.searchVM.isQueryEmpty},
            searchVM.items
                .filter {_ in !self.searchVM.isQueryEmpty}
                .map{$0.compactMap{$0.communityValue}}
        )
    }
    
    var itemsCount: Int {
        if searchVM.isQueryEmpty {
            return items.value.count
        }
        return searchVM.items.value.count
    }
    
    override func fetchNext(forceRetry: Bool = false) {
        if searchVM.isQueryEmpty {
            super.fetchNext(forceRetry: forceRetry)
        } else {
            searchVM.fetchNext(forceRetry: forceRetry)
        }
    }
    
    override func reload(clearResult: Bool = true) {
        if searchVM.isQueryEmpty {
            super.reload(clearResult: clearResult)
        } else {
            searchVM.reload(clearResult: clearResult)
        }
    }
}
