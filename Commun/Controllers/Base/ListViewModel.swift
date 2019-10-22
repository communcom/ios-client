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
    public let items        = BehaviorRelay<[T]>(value: [])
    public let loading      = PublishSubject<Bool>()
    public let listEnded    = PublishSubject<Void>()
    public let error        = PublishSubject<Error>()
    
    // MARK: - Filter & Fetcher
    public var fetcher: ItemsFetcher<T>
    
    // MARK: - Methods
    init(fetcher: ItemsFetcher<T>) {
        self.fetcher = fetcher
    }
    
    func fetchNext() {
        // show loading
        loading.onNext(true)
        
        fetcher.fetchNext()
            .do(onError: { error in
                self.error.onNext(error)
            })
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] list in
                self?.onItemsFetched(items: list)
                if self?.fetcher.reachedTheEnd == true {
                    self?.listEnded.onNext(())
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
