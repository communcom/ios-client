//
//  ListViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
        fetcher.state
    }
    
    public var rowHeights: [ListFetcher<T>.ItemIdentifier: CGFloat] {
        get {
            fetcher.rowHeights
        }
        set {
            fetcher.rowHeights = newValue
        }
    }
    
    // MARK: - Filter & Fetcher
    public var fetcher: ListFetcher<T>
    
    // MARK: - Methods
    init(fetcher: ListFetcher<T>, prefetch: Bool = false) {
        self.fetcher = fetcher
        super.init()
        defer {
            if prefetch {
                fetchNext()
            }
            observeItemDeleted()
            observeItemChange()
        }
    }
    
    func fetchNext(forceRetry: Bool = false) {
        fetcher.fetchNext(forceRetry: forceRetry)
    }
    
    func reload(clearResult: Bool = true) {
        fetcher.reset(clearResult: clearResult)
        fetchNext()
    }
    
    func shouldUpdateHeightForItem(_ item: T?, withUpdatedItem updatedItem: T?) -> Bool {false}
    
    func updateItem(_ updatedItem: T) {
        var newItems = fetcher.items.value
        guard let index = newItems.firstIndex(where: {$0.identity == updatedItem.identity}) else {return}
        guard let newUpdatedItem = newItems[index].newUpdatedItem(from: updatedItem) else {return}
        if shouldUpdateHeightForItem(newItems[index], withUpdatedItem: newUpdatedItem) {
            rowHeights.removeValue(forKey: updatedItem.identity)
        }
        newItems[index] = newUpdatedItem
        fetcher.items.accept(newItems)
    }
    
    func deleteItem(_ deletedItem: T) {
        deleteItemWithIdentity(deletedItem.identity)
    }
    
    func deleteItemWithIdentity(_ identity: T.Identity) {
        let newItems = fetcher.items.value.filter {$0.identity != identity}
        rowHeights.removeValue(forKey: identity)
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
