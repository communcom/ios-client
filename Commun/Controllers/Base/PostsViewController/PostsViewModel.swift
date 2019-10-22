//
//  PostsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxCocoa

class PostsViewModel: ListViewModel<ResponseAPIContentGetPost> {
    var filter: BehaviorRelay<PostsFetcher.Filter>!
    
    convenience init() {
        let filter = PostsFetcher.Filter(feedTypeMode: .new, feedType: .popular, sortType: .all)
        let fetcher = PostsFetcher(filter: filter)
        self.init(fetcher: fetcher)
        self.filter = BehaviorRelay<PostsFetcher.Filter>(value: filter)
        defer {
            bindFilter()
        }
    }
    
    func bindFilter() {
        filter.distinctUntilChanged()
            .filter {filter in
                if filter.feedTypeMode != .new && filter.feedType == .popular {return false}
                return true
            }
            .subscribe(onNext: {filter in
                self.items.accept([])
                self.fetcher.reset()
                (self.fetcher as! PostsFetcher).filter = filter
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
        let newFilter = filter.value.newFilter(withFeedTypeMode: feedTypeMode, feedType: feedType, sortType: sortType, searchKey: searchKey)
        filter.accept(newFilter)
    }
}
