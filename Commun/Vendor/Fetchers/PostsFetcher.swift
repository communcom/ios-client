//
//  PostsFetcher.swift
//  Commun
//
//  Created by Chung Tran on 29/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

class PostsFetcher: ItemsFetcher<ResponseAPIContentGetPost> {
    // MARK: - Enums
    struct Filter: Equatable {
        var feedTypeMode: FeedTypeMode
        var feedType: FeedSortMode
        var sortType: FeedTimeFrameMode
        var searchKey: String?
        
        func newFilter(
            withFeedTypeMode feedTypeMode: FeedTypeMode? = nil,
            feedType: FeedSortMode? = nil,
            sortType: FeedTimeFrameMode? = nil,
            searchKey: String? = nil
        ) -> Filter {
            var newFilter = self
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
            return newFilter
        }
    }
    
    var filter: Filter
    var userId: String?
    var communityId: String?
    
    required init(filter: Filter, communityId: String? = nil) {
        self.filter = filter
        self.communityId = communityId
        super.init()
    }
    
    override var request: Single<[ResponseAPIContentGetPost]>! {
        #warning("Mocking")
//        return ResponseAPIContentGetPosts.singleWithMockData()
//            .map {$0.items!}
        return RestAPIManager.instance.getPosts(communityId: communityId, allowNsfw: false, type: filter.feedTypeMode, sortBy: filter.feedType, limit: limit, offset: offset)
            .map {$0.items ?? []}
    }
}
