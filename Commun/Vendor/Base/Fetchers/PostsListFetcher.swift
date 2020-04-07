//
//  PostsListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class PostsListFetcher: ListFetcher<ResponseAPIContentGetPost> {
    // MARK: - Enums
    struct Filter: FilterType, Codable {
        static let filterKey = "currentUserFeedFilterKey"
        
        var feedTypeMode: FeedTypeMode
        var feedType: FeedSortMode
        var sortType: FeedTimeFrameMode?
        var searchKey: String?
        var userId: String?
        var communityId: String?
        var communityAlias: String?
        
        func save() throws {
            UserDefaults.standard.set(try JSONEncoder().encode(self), forKey: Filter.filterKey)
        }
        
        static var feed: Filter {
            guard let data = UserDefaults.standard.data(forKey: Filter.filterKey),
                let filter = try? JSONDecoder().decode(Filter.self, from: data)
            else {
                return PostsListFetcher.Filter(feedTypeMode: .subscriptions, feedType: .time, userId: Config.currentUser?.id)
            }
            return filter
        }
        
        func newFilter(
            withFeedTypeMode feedTypeMode: FeedTypeMode? = nil,
            feedType: FeedSortMode? = nil,
            sortType: FeedTimeFrameMode? = nil,
            searchKey: String? = nil,
            userId: String? = nil,
            communityId: String? = nil,
            communityAlias: String? = nil
        ) -> Filter {
            var newFilter = self
            if let feedTypeMode = feedTypeMode,
                feedTypeMode != newFilter.feedTypeMode {
                newFilter.feedTypeMode = feedTypeMode
            }
            
            if let feedType = feedType,
                feedType != newFilter.feedType {
                newFilter.feedType = feedType
            }
            
            if let sortType = sortType,
                sortType != newFilter.sortType {
                newFilter.sortType = sortType
            }
            
            newFilter.searchKey = searchKey
            
            if let userId = userId,
                userId != newFilter.userId {
                newFilter.userId = userId
            }
            
            if let communityId = communityId,
                communityId != newFilter.communityId {
                newFilter.communityId = communityId
            }
            
            if let alias = communityAlias,
                communityAlias != newFilter.communityAlias
            {
                newFilter.communityAlias = alias
            }
            
            return newFilter
        }
    }
    
    // MARK: - Properties
    var filter: Filter
    
    // MARK: - Initializers
    required init(filter: Filter) {
        self.filter = filter
        super.init()
    }
        
    override var request: Single<[ResponseAPIContentGetPost]> {
        RestAPIManager.instance.getPosts(userId: filter.userId, communityId: filter.communityId, communityAlias: filter.communityAlias, allowNsfw: false, type: filter.feedTypeMode, sortBy: filter.feedType, sortType: filter.sortType, limit: limit, offset: offset
        )
            .map { $0.items ?? [] }
            .do(onSuccess: { (posts) in
                self.loadRewards(fromPosts: posts)
            })
    }
    
    override func join(newItems items: [ResponseAPIContentGetPost]) -> [ResponseAPIContentGetPost] {
        return super.join(newItems: items).filter { $0.document != nil}
    }

    private func loadRewards(fromPosts posts: [ResponseAPIContentGetPost]) {
        let contentIds = posts.map { RequestAPIContentId(responseAPI: $0.contentId) }
        
        RestAPIManager.instance.rewardsGetStateBulk(posts: contentIds)
            .map({ $0.mosaics })
            .subscribe(onSuccess: { (mosaics) in
                self.showMosaics(mosaics)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func showMosaics(_ mosaics: [ResponseAPIRewardsGetStateBulkMosaic]) {
        // add mosaics
        var posts = self.items.value
            .map {post -> ResponseAPIContentGetPost in
                var post = post
                // clear explanation
                if post.topExplanation != .hidden {
                    post.topExplanation = nil
                }
                if post.bottomExplanation != .hidden {
                    post.bottomExplanation = nil
                }
                
                // add mosaics
                if let mosaic = mosaics.first(where: {$0.contentId.userId == post.contentId.userId && $0.contentId.permlink == post.contentId.permlink})
                {
                    post.mosaic = mosaic
                }
                return post
            }
        
        // add explanation
        if ExplanationView.shouldShowViewWithId(
            ResponseAPIContentGetPost.TopExplanationType.reward.rawValue)
        {
            var lastShownRewardExplantionIndex: Int?
            var lastShownCommentExplanationIndex: Int?
            for (index, post) in posts.enumerated() {
                // show reward explanation
                let showReward: () -> Void = {
                    if posts[index].topExplanation != .hidden {
                        posts[index].topExplanation = .reward
                    }
                    lastShownRewardExplantionIndex = index
                }
                
                // show rewards for comment explanation
                let showComment: () -> Void = {
                    if posts[index].bottomExplanation != .hidden {
                        posts[index].bottomExplanation = .rewardsForComments
                    }
                    lastShownCommentExplanationIndex = index
                }
                
                // show rewards for like explanation
                let showLike: () -> Void = {
                    if posts[index].bottomExplanation != .hidden {
                        posts[index].bottomExplanation = .rewardsForLikes
                    }
                }
    
                // check index and show needed explanation
                if lastShownRewardExplantionIndex == nil {
                    if index >= 3 && post.mosaic?.isRewarded == true {
                        showReward()
                    }
                } else {
                    if index >= 40 + lastShownRewardExplantionIndex! && post.mosaic?.isRewarded == true {
                        showReward()
                    }
                    
                    if index == 7 + lastShownRewardExplantionIndex! {
                        showComment()
                    }
                    
                    if let commentIndex = lastShownCommentExplanationIndex,
                        index == 7 + commentIndex
                    {
                        showLike()
                    }
                }
            }
        }
        
        // assign value
        self.items.accept(posts)
    }
}
