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
        newItems[index] = updatedItem
        UIView.setAnimationsEnabled(false)
        fetcher.items.accept(newItems)
        UIView.setAnimationsEnabled(true)
    }
    
    func deleteItem(_ deletedItem: T) {
        let newItems = fetcher.items.value.filter {$0.identity != deletedItem.identity}
        UIView.setAnimationsEnabled(false)
        fetcher.items.accept(newItems)
        UIView.setAnimationsEnabled(true)
    }
    
    func observeItemDeleted() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(T.self)Deleted"))
            .subscribe(onNext: { (notification) in
                guard let deletedItem = notification.object as? T
                    else {return}
                self.deleteItem(deletedItem)
            })
            .disposed(by: disposeBag)
    }
    
    func observeItemChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(T.self)DidChange"))
            .subscribe(onNext: {notification in
                guard let newItem = notification.object as? T
                    else {return}
                self.updateItem(newItem)
            })
            .disposed(by: disposeBag)
    }
}
