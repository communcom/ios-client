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

class ListViewModel<T: Decodable & Equatable & IdentifiableType> {
    // MARK: - Properties
    public let disposeBag   = DisposeBag()
    public var items        = BehaviorRelay<[T]>(value: [])
    public let state        = BehaviorRelay<ListLoadingState>(value: .loading)
    
    // MARK: - Filter & Fetcher
    public var fetcher: ItemsFetcher<T>
    
    // MARK: - Methods
    init(fetcher: ItemsFetcher<T>) {
        self.fetcher = fetcher
    }
    
    func fetchNext() {
        // show loading
        state.accept(.loading)
        
        fetcher.fetchNext()
            .do(onError: { error in
                self.state.accept(.error(error: error))
            })
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] list in
                self?.onItemsFetched(items: list)
                if self?.fetcher.reachedTheEnd == true {
                    self?.state.accept(.listEnded)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func onItemsFetched(items: [T]) {
        // default behavior: add to the end of the list
        if items.count > 0 {
            let newList = items.filter {!self.items.value.contains($0)}
            self.items.accept(self.items.value + newList)
        }
    }
    
    func reload() {
        items.accept([])
        fetcher.reset()
        fetchNext()
    }
}
