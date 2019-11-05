//
//  ListViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class ListViewModel<T: ListItemType>: BaseViewModel {
    // MARK: - Properties
    var items: BehaviorRelay<[T]> {
        fetcher.items
    }
    public var state: BehaviorRelay<ListFetcherState> {
        return fetcher.state
    }
    
    // MARK: - Filter & Fetcher
    public var fetcher: ListFetcher<T>
    
    // MARK: - Methods
    init(fetcher: ListFetcher<T>) {
        self.fetcher = fetcher
    }
    
    func fetchNext(forceRetry: Bool = false) {
        fetcher.fetchNext(forceRetry: forceRetry)
    }
    
    func reload() {
        fetcher.reset()
        fetchNext()
    }
}
