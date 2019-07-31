//
//  FeedPageViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class FeedPageViewModel: PostsListController, ListViewModelType {
    // PostsListController requirement
    var disposeBag = DisposeBag()
    var items = BehaviorRelay<[ResponseAPIContentGetPost]>(value: [])
    let lastError = BehaviorRelay<Error?>(value: nil)
    
    let sortType = BehaviorRelay<FeedTimeFrameMode>(value: .all)
    let feedType = BehaviorRelay<FeedSortMode>(value: .popular)
    let feedTypeMode = BehaviorRelay<FeedTypeMode>(value: .community)
    
    let fetcher = PostsFetcher(sortType: .all, feedType: .popular, feedTypeMode: .community)
    
    // Handlers
    var listEndedHandler: (() -> Void)?
    var fetchNextErrorHandler: ((Error) -> Void)?
    var loadingHandler: (() -> Void)?
    
    init() {
        // bind filter
        bindFilter()
        
        // post observers
        observePostDelete()
        observePostChange()
    }
    
    func bindFilter() {
        Observable.combineLatest(sortType.distinctUntilChanged(), feedType.distinctUntilChanged(), feedTypeMode.distinctUntilChanged())
            .filter({ (sortType, feedType, feedTypeMode) -> Bool in
                if feedTypeMode == .byUser && feedType == .popular {return false}
                return true
            })
            .subscribe(onNext: {(sortType, feedType, feedTypeMode) in
                self.items.accept([])
                self.fetcher.reset()
                self.fetcher.sortType = sortType
                self.fetcher.feedType = feedType
                self.fetcher.feedTypeMode = feedTypeMode
                self.fetchNext()
            })
            .disposed(by: disposeBag)
        
    }
    
    func fetchNext() {
        fetcher.fetchNext()
            .do(onSubscribe: {
                self.loadingHandler?()
            })
            .subscribe(onSuccess: { (list) in
                self.lastError.accept(nil)
                
                if list.count > 0 {
                    let newList = list.filter {!self.items.value.contains($0)}
                    self.items.accept(self.items.value + newList)
                }
                
                if self.fetcher.reachedTheEnd {
                    self.listEndedHandler?()
                    return
                }
                
            }) { (error) in
                self.lastError.accept(error)
                self.fetchNextErrorHandler?(error)
            }
            .disposed(by: disposeBag)
    }
    
    @objc func reload() {
        items.accept([])
        lastError.accept(nil)
        fetcher.reset()
        fetchNext()
    }
}
