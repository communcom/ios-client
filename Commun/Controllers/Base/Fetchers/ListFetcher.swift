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

enum ListFetcherState {
    case loading(Bool)
    case listEnded
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
        case .listEnded:
            return
        case .error(_):
            if !forceRetry {
                return
            }
        default:
            break
        }
        
        // assign loading state
        state.accept(.loading(true))
        
        // send request
        return request
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
            .asDriver(onErrorJustReturn: [])
            .map {self.join(newItems: $0)}
            .drive(items)
            .disposed(by: disposeBag)
    }
    
    func join(newItems items: [T]) -> [T] {
        var newList = items.filter {!self.items.value.contains($0)}
        newList = self.items.value + newList
        return newList
    }
}

