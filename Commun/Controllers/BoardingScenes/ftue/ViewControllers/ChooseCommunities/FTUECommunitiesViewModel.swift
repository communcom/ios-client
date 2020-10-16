//
//  FTUECommunitiesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class FTUECommunitiesViewModel: CommunitiesViewModel {
    override func createSearchVM() -> SearchViewModel {
        let fetcher = SearchListFetcher()
        fetcher.limit = 20
        fetcher.searchType = .entitySearch
        fetcher.entitySearchEntity = .communities
        fetcher.authorizationRequired = false
        return SearchViewModel(fetcher: fetcher)
    }
    
    let chosenCommunities = BehaviorRelay<[ResponseAPIContentGetCommunity]>(value: [])
    
    init() {
        super.init(type: .all, authorizationRequired: false)
    }
    
    override func updateItem(_ updatedItem: ResponseAPIContentGetCommunity) {
        super.updateItem(updatedItem)
        var newItems = chosenCommunities.value
        guard let index = newItems.firstIndex(where: {$0.identity == updatedItem.identity}) else {return}
        guard let newUpdatedItem = newItems[index].newUpdatedItem(from: updatedItem) else {return}
        newItems[index] = newUpdatedItem
        chosenCommunities.accept(newItems)
    }
}
