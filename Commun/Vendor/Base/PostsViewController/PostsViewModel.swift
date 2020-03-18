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
    lazy var searchVM: SearchViewModel = {
        let fetcher = SearchListFetcher()
        fetcher.limit = 10
        fetcher.searchType = .entitySearch
        fetcher.entitySearchEntity = .posts
        return SearchViewModel(fetcher: fetcher)
    }()
    
    init(filter: PostsListFetcher.Filter = PostsListFetcher.Filter(feedTypeMode: .subscriptions, feedType: .time), prefetch: Bool = true) {
        let fetcher = PostsListFetcher(filter: filter)
        super.init(fetcher: fetcher, prefetch: prefetch)
        self.filter = BehaviorRelay<PostsListFetcher.Filter>(value: filter)
        defer {
            bindFilter()
            observeUserEvents()
            observeCommunityEvents()
        }
    }
    
    override func fetchNext(forceRetry: Bool = false) {
        if searchVM.isQueryEmpty {
            super.fetchNext(forceRetry: forceRetry)
        } else {
            searchVM.fetchNext(forceRetry: forceRetry)
        }
    }
    
    override func reload(clearResult: Bool = true) {
        if searchVM.isQueryEmpty {
            super.reload(clearResult: clearResult)
        } else {
            searchVM.reload(clearResult: clearResult)
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
    
    func observeUserEvents() {
        let removePostByUser: (ResponseAPIContentGetProfile) -> Void = {[weak self] user in
            guard let strongSelf = self else {return}
            
            // if user is on UserProfilePage, do nothing
            if let fetcher = strongSelf.fetcher as? PostsListFetcher,
                fetcher.filter.feedTypeMode == .byUser,
                fetcher.filter.userId == user.userId
            {
                return
            }
            
            let posts = strongSelf.items.value.filter {$0.author?.userId != user.userId}
            strongSelf.items.accept(posts)
        }
        
        let followUserHandler: (ResponseAPIContentGetProfile) -> Void = {[weak self] user in
            guard let strongSelf = self else {return}
            
            // if user is on UserProfilePage, do nothing
            if let fetcher = strongSelf.fetcher as? PostsListFetcher,
                fetcher.filter.feedTypeMode == .byUser,
                fetcher.filter.userId == user.userId
            {
                return
            }
            
            strongSelf.reload(clearResult: false)
        }
        
        ResponseAPIContentGetProfile.observeEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
            .subscribe(onNext: {blockedUser in
                removePostByUser(blockedUser)
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetProfile.observeProfileUnfollowed()
            .subscribe(onNext: { (unfollowedUser) in
                removePostByUser(unfollowedUser)
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetProfile.observeProfileFollowed()
            .subscribe(onNext: { (followedUser) in
                followUserHandler(followedUser)
            })
            .disposed(by: disposeBag)
    }
    
    func observeCommunityEvents() {
        let removeAnyPostsByCommunity: (ResponseAPIContentGetCommunity) -> Void = { [weak self] community in
            guard let strongSelf = self else {return}
            
            // if user is on CommunityPage, do nothing
            if let fetcher = strongSelf.fetcher as? PostsListFetcher,
                fetcher.filter.feedTypeMode == .community,
                (fetcher.filter.communityId == community.communityId || fetcher.filter.communityAlias == fetcher.filter.communityAlias)
            {
                return
            }
            
            let posts = strongSelf.items.value.filter {$0.community?.communityId != community.communityId}
            strongSelf.items.accept(posts)
        }
        
        let followCommunityHandler: (ResponseAPIContentGetCommunity) -> Void = { [weak self] community in
            guard let strongSelf = self else {return}
            
            // if user is on CommunityPage, do nothing
            if let fetcher = strongSelf.fetcher as? PostsListFetcher,
                fetcher.filter.feedTypeMode == .community,
                (fetcher.filter.communityId == community.communityId || fetcher.filter.communityAlias == fetcher.filter.communityAlias)
            {
                return
            }
            
            strongSelf.reload(clearResult: false)
        }
        
        ResponseAPIContentGetCommunity.observeEvent(eventName: ResponseAPIContentGetCommunity.blockedEventName)
            .subscribe(onNext: { (blockedCommunity) in
                removeAnyPostsByCommunity(blockedCommunity)
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeCommunityUnfollowed()
            .subscribe(onNext: { (unfollowedCommunity) in
                removeAnyPostsByCommunity(unfollowedCommunity)
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetCommunity.observeCommunityFollowed()
            .subscribe(onNext: { (followedCommunity) in
                followCommunityHandler(followedCommunity)
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
