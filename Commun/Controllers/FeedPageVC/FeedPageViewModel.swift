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

class FeedPageViewModel {
    
    private let bag = DisposeBag()
    
    let items = BehaviorRelay<[ResponseAPIContentGetPost]>(value: [])
    
    let sortType = BehaviorRelay<FeedTimeFrameMode>(value: .all)
    let feedType = BehaviorRelay<FeedSortMode>(value: .popular)
    let feedTypeMode = BehaviorRelay<FeedTypeMode>(value: .community)
    
    let fetcher = PostsFetcher(sortType: .all, feedType: .popular, feedTypeMode: .community)
    
    init() {
        // bind filter
        bindFilter()
    }
    
    func bindFilter() {
        #warning("handle error")
        Observable.combineLatest(sortType, feedType, feedTypeMode)
            .flatMapLatest({ (sortType, feedType, feedTypeMode) -> Single<[ResponseAPIContentGetPost]> in
                self.fetcher.reset()
                self.fetcher.sortType = sortType
                self.fetcher.feedType = feedType
                self.fetcher.feedTypeMode = feedTypeMode
                return self.fetcher.fetchNext()
                    .catchErrorJustReturn([])
            })
            .asDriver(onErrorJustReturn: [])
            .drive(items)
            .disposed(by: bag)
        
    }
    
    func fetchNext() {
        fetcher.fetchNext()
            .subscribe(onSuccess: { (list) in
                self.items.accept(self.items.value + list)
            }) { (error) in
                #warning("handle error")
            }
            .disposed(by: bag)
    }
    
    @objc func reload() {
        fetcher.reset()
        fetchNext()
    }
}
