//
//  PostsListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class PostsListFetcher: ListFetcher<ResponseAPIContentGetPost> {
    // MARK: - Enums
    struct Filter: FilterType {
        var feedTypeMode: FeedTypeMode
        var feedType: FeedSortMode
        var sortType: FeedTimeFrameMode
        var searchKey: String?
        var userId: String?
        var communityId: String?
        
        func newFilter(
            withFeedTypeMode feedTypeMode: FeedTypeMode? = nil,
            feedType: FeedSortMode? = nil,
            sortType: FeedTimeFrameMode? = nil,
            searchKey: String? = nil,
            userId: String? = nil,
            communityId: String? = nil
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
            
            if let userId = userId,
                userId != newFilter.userId
            {
                newFilter.userId = userId
            }
            
            if let communityId = communityId,
                communityId != newFilter.communityId
            {
                newFilter.communityId = communityId
            }
            
            return newFilter
        }
    }
    
    var filter: Filter 
    
    required init(filter: Filter) {
        self.filter = filter
        super.init()
    }
        
    override var request: Single<[ResponseAPIContentGetPost]> {
        return RestAPIManager.instance.getPosts(communityId: filter.communityId, allowNsfw: false, type: filter.feedTypeMode, sortBy: filter.feedType, limit: limit, offset: offset)
        .map {$0.items ?? []}
    }
}
