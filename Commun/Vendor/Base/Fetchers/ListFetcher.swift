//
//  ListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

typealias FilterType = Equatable

enum ListFetcherState: Equatable {
    static func == (lhs: ListFetcherState, rhs: ListFetcherState) -> Bool {
        switch (lhs, rhs) {
        case (.loading(let loading1), .loading(let loading2)):
            return loading1 == loading2
        case (.listEnded, .listEnded):
            return true
        case (.error(let error1), .error(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        case (.listEmpty, .listEmpty):
            return true
        default:
            return false
        }
    }
    
    case loading(Bool)
    case listEnded
    case listEmpty
    case error(error: Error)
    
    var lastError: Error? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
}

class ListFetcher<T: ListItemType> {
    // MARK: - Constants
    var isPaginationEnabled: Bool {true}
    
    // MARK: - Parammeters
    var limit = UInt(Config.paginationLimit)
    var offset: UInt = 0
    
    private var reloadClearedResult = true
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let state = BehaviorRelay<ListFetcherState>(value: .loading(false))
    var request: Single<[T]> {
        fatalError("Must override")
    }
    let items = BehaviorRelay<[T]>(value: [])
    
    // MARK: - Methods
    func reset(clearResult: Bool = true) {
        state.accept(.loading(false))
        if clearResult {
            items.accept([])
        } else {
            items.accept(Array(items.value.prefix(Int(limit))))
        }
        reloadClearedResult = clearResult
        offset = 0
    }
    
    func fetchNext(forceRetry: Bool = false) {
        // prevent dupplicate
        switch state.value {
        case .loading(let isLoading):
            if isLoading {return}
        case .listEnded, .listEmpty:
            return
        case .error:
            if !forceRetry {
                return
            }
        }
        
        // assign loading state
        state.accept(.loading(true))
        
        // send request
        request
            .subscribe(onSuccess: { (items) in
                self.items.accept(self.join(newItems: items))
                
                // resign state
                if self.isPaginationEnabled {
                    if items.count == 0 {
                        if self.offset == 0 {
                            self.state.accept(.listEmpty)
                        } else {
                            if self.items.value.count > 0 {
                                self.state.accept(.listEnded)
                            }
                        }
                    } else if items.count < self.limit {
                        self.state.accept(.listEnded)
                    } else if items.count > self.limit {
                        self.state.accept(.listEnded)
                    } else {
                        self.state.accept(.loading(false))
                    }
                } else {
                    self.state.accept(items.count == 0 ? .listEmpty: .listEnded)
                }
                
                // get next offset
                self.offset += self.limit
                
            }, onError: {error in
                self.state.accept(.error(error: error))
            })
            .disposed(by: disposeBag)
    }
    
    func join(newItems items: [T]) -> [T] {
        var updatedItems = [T]()
        
        // add new items
        if !reloadClearedResult {
            reloadClearedResult = true
            updatedItems = items
            updatedItems.joinUnique(self.items.value)
        } else {
            updatedItems = self.items.value
            updatedItems.joinUnique(items)
        }
        
        // update current items
        updatedItems = updatedItems.map {
            var mutableItem = $0
            
            // if item exists in list, update it
            if let newItem = items.first(where: {$0.identity == mutableItem.identity}),
                let updatedItem = mutableItem.newUpdatedItem(from: newItem)
            {
                mutableItem = updatedItem
            }
            return mutableItem
        }
        
        return updatedItems
    }
}
