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
    }
    
    var filter: Filter
    var userId: String?
    
    required init(filter: Filter) {
        self.filter = filter
        super.init()
    }
    
    override var request: Single<[ResponseAPIContentGetPost]>! {
        return NetworkService.shared.loadFeed(sequenceKey, withSortType: filter.sortType, withFeedType: filter.feedType, withFeedTypeMode: filter.feedTypeMode, userId: userId)
            .do(onSuccess: { (result) in
                // assign next sequenceKey
                self.sequenceKey = result.sequenceKey
            })
            .map {$0.items ?? []}
    }
}
