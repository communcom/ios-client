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
        super.init()
        defer {
            observeItemDeleted()
            observeItemChange()
        }
    }
    
    func fetchNext(forceRetry: Bool = false) {
        fetcher.fetchNext(forceRetry: forceRetry)
    }
    
    func reload() {
        fetcher.reset()
        fetchNext()
    }
    
    func updateItem(_ updatedItem: T) {
        var newItems = fetcher.items.value
        guard let index = newItems.firstIndex(where: {$0.identity == updatedItem.identity}) else {return}
        guard let newUpdatedItem = newItems[index].newUpdatedItem(from: updatedItem) else {return}
        newItems[index] = newUpdatedItem
        fetcher.items.accept(newItems)
    }
    
    func deleteItem(_ deletedItem: T) {
        let newItems = fetcher.items.value.filter {$0.identity != deletedItem.identity}
        fetcher.items.accept(newItems)
    }
    
    func observeItemDeleted() {
        T.observeItemDeleted()
            .subscribe(onNext: { (deletedItem) in
                self.deleteItem(deletedItem)
            })
            .disposed(by: disposeBag)
    }
    
    func observeItemChange() {
        T.observeItemChanged()
            .subscribe(onNext: { (changedItem) in
                self.updateItem(changedItem)
            })
            .disposed(by: disposeBag)
    }
}
