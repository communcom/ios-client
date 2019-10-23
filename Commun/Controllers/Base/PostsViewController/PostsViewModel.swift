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

class PostsViewModel: ListViewModel<ResponseAPIContentGetPost>, PostsListController {
    var filter: BehaviorRelay<PostsListFetcher.Filter>!
    
    convenience init(filter: PostsListFetcher.Filter = PostsListFetcher.Filter(feedTypeMode: .new, feedType: .popular, sortType: .all)) {
        let fetcher = PostsListFetcher(filter: filter)
        self.init(fetcher: fetcher)
        self.filter = BehaviorRelay<PostsListFetcher.Filter>(value: filter)
        defer {
            bindFilter()
            observePostDelete()
            observePostChange()
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
                (self.fetcher as! PostsListFetcher).filter = filter
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
