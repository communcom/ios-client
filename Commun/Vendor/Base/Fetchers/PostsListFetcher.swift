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
        enum Language: String, CaseIterable {
            case all = "all"
            case english = "en"
            case russian = "ru"
            
            var localizedName: String {
                switch self {
                case .all:
                    return "all".localized()
                case .english:
                    return "english".localized()
                case .russian:
                    return "russian".localized()
                }
            }
            
            static var observable: Observable<Language> {
                UserDefaults.standard.rx.observe(String.self, Config.currentUserFeedLanguage)
                    .map {$0 ?? "all"}
                    .map {PostsListFetcher.Filter.Language(rawValue: $0) ?? .all}
            }
        }
        
        static let filterKey = "currentUserFeedFilterKey"
        var authorizationRequired = true
        
        var type: FeedTypeMode
        var sortBy: FeedSortMode?
        var timeframe: FeedTimeFrameMode?
        var searchKey: String?
        var userId: String?
        var communityId: String?
        var communityAlias: String?
        var language: String = UserDefaults.standard.string(forKey: Config.currentUserFeedLanguage) ?? "all"
        
        func save() throws {
            UserDefaults.standard.set(try JSONEncoder().encode(self), forKey: Filter.filterKey)
        }
        
        static var myFeed: Filter {
            PostsListFetcher.Filter(type: .subscriptions, sortBy: .time, userId: Config.currentUser?.id)
        }
        
        static var feed: Filter {
            guard let data = UserDefaults.standard.data(forKey: Filter.filterKey),
                let filter = try? JSONDecoder().decode(Filter.self, from: data),
                (filter.type == .subscriptions || filter.type == .new || filter.type == .hot || filter.type == .subscriptionsHot || filter.type == .subscriptionsPopular)
            else {
                return myFeed
            }
            return filter
        }
        
        func newFilter(
            type: FeedTypeMode? = nil,
            sortBy: FeedSortMode? = nil,
            timeframe: FeedTimeFrameMode? = nil,
            searchKey: String? = nil,
            userId: String? = nil,
            communityId: String? = nil,
            communityAlias: String? = nil,
            allowedLanguages: [String]? = nil
        ) -> Filter {
            var newFilter = self
            if let type = type,
                type != newFilter.type
            {
                newFilter.type = type
            }
            
            if let sortBy = sortBy,
                sortBy != newFilter.sortBy
            {
                newFilter.sortBy = sortBy
            }
            
            if let timeframe = timeframe,
                timeframe != newFilter.timeframe
            {
                newFilter.timeframe = timeframe
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
            
            if let alias = communityAlias,
                communityAlias != newFilter.communityAlias
            {
                newFilter.communityAlias = alias
            }
            
            if let allowedLanguages = allowedLanguages,
                allowedLanguages.count > 0,
                allowedLanguages != [newFilter.language]
            {
                newFilter.language = allowedLanguages.first!
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
        RestAPIManager.instance.getPosts(userId: filter.userId ?? Config.currentUser?.id, communityId: filter.communityId, communityAlias: filter.communityAlias, allowNsfw: false, type: filter.type, sortBy: filter.sortBy, timeframe: filter.timeframe, limit: limit, offset: offset, authorizationRequired: filter.authorizationRequired, allowedLanguages: [filter.language]
        )
            .map { $0.items ?? [] }
    }
    
    override func join(newItems items: [ResponseAPIContentGetPost]) -> [ResponseAPIContentGetPost] {
        return super.join(newItems: items).filter { $0.document != nil}
    }
    
    override func handleNewData(_ items: [ResponseAPIContentGetPost]) {
        super.handleNewData(items)
        loadRewards(fromPosts: items)
        loadDonations(forPosts: items)
    }

    // MARK: - Rewards
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
        let oldPosts = self.items.value
        for i in 0..<oldPosts.count {
            if let updatedPost = posts.first(where: {$0.identity == oldPosts[i].identity}),
                oldPosts[i].shouldUpdateHeightForPostWithUpdatedPost(updatedPost)
            {
                rowHeights[oldPosts[i].identity] = nil
            }
        }
        self.items.accept(posts)
    }
    
    // MARK: - Donations
    private func loadDonations(forPosts posts: [ResponseAPIContentGetPost]) {
        let contentIds = posts.map { RequestAPIContentId(responseAPI: $0.contentId) }
        RestAPIManager.instance.getDonationsBulk(posts: contentIds)
            .map {$0.items}
            .subscribe(onSuccess: { donations in
                self.showDonations(donations)
            })
            .disposed(by: disposeBag)
    }
    
    private func showDonations(_ donations: [ResponseAPIWalletGetDonationsBulkItem]) {
        for var post in items.value {
            if let donations = donations.first(where: {$0.contentId.userId == post.contentId.userId && $0.contentId.permlink == post.contentId.permlink && $0.contentId.communityId == post.contentId.communityId})
            {
                post.donations = donations
                post.notifyChanged()
            }
        }
    }
}
