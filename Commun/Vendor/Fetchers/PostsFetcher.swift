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
    var sortType: FeedTimeFrameMode
    var feedType: FeedSortMode
    var feedTypeMode: FeedTypeMode
    var userId: String?
    
    required init(sortType: FeedTimeFrameMode = .all, feedType: FeedSortMode = .popular, feedTypeMode: FeedTypeMode = .community) {
        self.sortType = sortType
        self.feedType = feedType
        self.feedTypeMode = feedTypeMode
        super.init()
    }
    
    override var request: Single<[ResponseAPIContentGetPost]>! {
        return NetworkService.shared.loadFeed(sequenceKey, withSortType: sortType, withFeedType: feedType, withFeedTypeMode: feedTypeMode, userId: userId)
            .do(onNext: { (result) in
                // assign next sequenceKey
                self.sequenceKey = result.sequenceKey
            })
            .map {$0.items ?? []}
            .asSingle()
    }
}
