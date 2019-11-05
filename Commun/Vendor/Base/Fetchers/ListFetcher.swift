//
//  ListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
    
    // MARK: - Parammeters
    let limit = UInt(Config.paginationLimit)
    var offset: UInt = 0
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let state = BehaviorRelay<ListFetcherState>(value: .loading(false))
    var request: Single<[T]> {
        fatalError("Must override")
    }
    let items = BehaviorRelay<[T]>(value: [])
    
    // MARK: - Methods
    func reset() {
        state.accept(.loading(false))
        items.accept([])
        offset = 0
    }
    
    func fetchNext(forceRetry: Bool = false) {
        // prevent dupplicate
        switch state.value {
        case .loading(let isLoading):
            if isLoading {return}
        case .listEnded, .listEmpty:
            return
        case .error(_):
            if !forceRetry {
                return
            }
        }
        
        // assign loading state
        state.accept(.loading(true))
        
        // send request
        request
            .do(onSuccess: { (result) in
                // get next offset
                self.offset += self.limit
                
                // resign state
                if result.count < self.limit {
                    // mark the end
                    self.state.accept(.listEnded)
                }
                else {
                    self.state.accept(.loading(false))
                }
            }, onError: { (error) in
                self.state.accept(.error(error: error))
            })
            .map {self.join(newItems: $0)}
            .do(onSuccess: { (items) in
                if items.count == 0 {
                    self.state.accept(.listEmpty)
                }
            })
            .subscribe(onSuccess: { (items) in
                self.items.accept(items)
            })
            .disposed(by: disposeBag)
    }
    
    func join(newItems items: [T]) -> [T] {
        var newList = items.filter { (item) -> Bool in
            !self.items.value.contains {$0.identity == item.identity}
        }
        newList = self.items.value + newList
        return newList
    }
}

