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
    
    let filter = BehaviorRelay<PostsFetcher.Filter>(value: PostsFetcher.Filter(feedTypeMode: .community, feedType: .popular, sortType: .all))
    
    lazy var fetcher = PostsFetcher(filter: filter.value)
    
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
        filter.distinctUntilChanged()
            .filter {filter in
                if filter.feedTypeMode != .community && filter.feedType == .popular {return false}
                return true
            }
            .subscribe(onNext: {filter in
                self.items.accept([])
                self.fetcher.reset()
                self.fetcher.filter = filter
                self.fetchNext()
            })
            .disposed(by: disposeBag)
        
    }
    
    func changeFilter(
        feedTypeMode: FeedTypeMode? = nil,
        feedType: FeedSortMode? = nil,
        sortType: FeedTimeFrameMode? = nil,
        searchKey: String? = nil
    ) {
        var newFilter = filter.value
        if let feedTypeMode = feedTypeMode,
            feedTypeMode != newFilter.feedTypeMode
        {
            newFilter.feedTypeMode = feedTypeMode
        }
        
        if let feedType = feedType,
            feedType != newFilter.feedType
        {
            newFilter.feedType = feedType
        }
        
        if let sortType = sortType,
            sortType != newFilter.sortType
        {
            newFilter.sortType = sortType
        }
        
        newFilter.searchKey = searchKey
        filter.accept(newFilter)
    }
    
    func fetchNext() {
        loadingHandler?()
        fetcher.fetchNext()
            .do(onError: {error in
                self.fetchNextErrorHandler?(error)
            })
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { (list) in
                if list.count > 0 {
                    let newList = list.filter {!self.items.value.contains($0)}
                    self.items.accept(self.items.value + newList)
                }
                
                if self.fetcher.reachedTheEnd {
                    self.listEndedHandler?()
                    return
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    @objc func reload() {
        items.accept([])
        fetcher.reset()
        fetchNext()
    }
}
