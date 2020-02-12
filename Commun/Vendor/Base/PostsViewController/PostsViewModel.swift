//
//  PostsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxCocoa

class PostsViewModel: ListViewModel<ResponseAPIContentGetPost> {
    var filter: BehaviorRelay<PostsListFetcher.Filter>!
    
    convenience init(filter: PostsListFetcher.Filter = PostsListFetcher.Filter(feedTypeMode: .subscriptions, feedType: .time)) {
        let fetcher = PostsListFetcher(filter: filter)
        self.init(fetcher: fetcher)
        self.filter = BehaviorRelay<PostsListFetcher.Filter>(value: filter)
        defer {
            bindFilter()
            observeUserBlocked()
            observeCommunityBlocked()
        }
    }
    
    func bindFilter() {
        filter.skip(1).distinctUntilChanged()
            .subscribe(onNext: {filter in
                self.fetcher.reset()
                
                var filter = filter
                
                if filter.feedTypeMode == .subscriptions ||
                    filter.feedTypeMode == .subscriptionsHot ||
                    filter.feedTypeMode == .subscriptionsPopular {
                    filter.userId = Config.currentUser?.id
                }
                
                (self.fetcher as! PostsListFetcher).filter = filter
                self.fetchNext()
            })
            .disposed(by: disposeBag)
    }
    
    func observeUserBlocked() {
        ResponseAPIContentGetProfile.observeEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
            .subscribe(onNext: {blockedUser in
                let posts = self.items.value.filter {$0.author?.userId != blockedUser.userId}
                self.items.accept(posts)
            })
            .disposed(by: disposeBag)
    }
    
    func observeCommunityBlocked() {
        ResponseAPIContentGetCommunity.observeEvent(eventName: ResponseAPIContentGetCommunity.blockedEventName)
            .subscribe(onNext: { (blockedCommunity) in
                let posts = self.items.value.filter {$0.community?.communityId != blockedCommunity.communityId}
                self.items.accept(posts)
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
        if newFilter != filter.value {
            filter.accept(newFilter)
        }
    }
}
