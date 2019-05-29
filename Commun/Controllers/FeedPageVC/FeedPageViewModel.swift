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

class FeedPageViewModel: PostsListController {
    // PostsListController requirement
    var disposeBag = DisposeBag()
    var items = BehaviorRelay<[ResponseAPIContentGetPost]>(value: [])
    
    let sortType = BehaviorRelay<FeedTimeFrameMode>(value: .all)
    let feedType = BehaviorRelay<FeedSortMode>(value: .popular)
    let feedTypeMode = BehaviorRelay<FeedTypeMode>(value: .community)
    
    let fetcher = PostsFetcher(sortType: .all, feedType: .popular, feedTypeMode: .community)
    
    init() {
        // bind filter
        bindFilter()
        
        // post observers
        observePostDelete()
        observePostChange()
    }
    
    func bindFilter() {
        #warning("handle error")
        Observable.combineLatest(sortType, feedType, feedTypeMode)
            .skip(1)
            .filter({ (sortType, feedType, feedTypeMode) -> Bool in
                if feedTypeMode == .byUser && feedType == .popular {return false}
                return true
            })
            .flatMapLatest({ (sortType, feedType, feedTypeMode) -> Single<[ResponseAPIContentGetPost]> in
                self.items.accept([])
                self.fetcher.reset()
                self.fetcher.sortType = sortType
                self.fetcher.feedType = feedType
                self.fetcher.feedTypeMode = feedTypeMode
                return self.fetcher.fetchNext()
                    .catchErrorJustReturn([])
            })
            .asDriver(onErrorJustReturn: [])
            .drive(items)
            .disposed(by: disposeBag)
        
    }
    
    func fetchNext() {
        fetcher.fetchNext()
            .subscribe(onSuccess: { (list) in
                guard list.count > 0 else {return}
                let newList = list.filter {!self.items.value.contains($0)}
                self.items.accept(self.items.value + newList)
            }) { (error) in
                #warning("handle error")
            }
            .disposed(by: disposeBag)
    }
    
    @objc func reload() {
        items.accept([])
        fetcher.reset()
        fetchNext()
    }
}
