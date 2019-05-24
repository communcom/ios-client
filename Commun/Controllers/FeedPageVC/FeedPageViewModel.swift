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
        
//        // observePostChange
//        NotificationCenter.default.rx.notification(.init(rawValue: PostControllerPostDidChangeNotification))
//            .subscribe(onNext: {notification in
//                guard let newPost = notification.object as? ResponseAPIContentGetPost
//                    else {return}
//                
//                let indexToReplace = self.items.value.firstIndex(where: {$0.contentId.permlink == newPost.contentId.permlink})
//                
//                guard let index = indexToReplace else {return}
//                var newArray = self.items.value
//                newArray[index] = newPost
//                self.items.accept(newArray)
//            })
//            .disposed(by: bag)
    }
    
    func bindFilter() {
        #warning("handle error")
        Observable.combineLatest(sortType, feedType, feedTypeMode)
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
        items.accept([])
        fetcher.reset()
        fetchNext()
    }
}
