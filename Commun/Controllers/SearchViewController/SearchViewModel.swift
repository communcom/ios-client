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
}
