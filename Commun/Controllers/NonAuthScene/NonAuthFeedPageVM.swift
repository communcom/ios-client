//
//  NonAuthFeedPageVM.swift
//  Commun
//
//  Created by Chung Tran on 7/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class NonAuthFeedPageVM: PostsViewModel {
    init() {
        let filter = PostsListFetcher.Filter(type: .new, sortBy: .time, timeframe: .all)
        super.init(filter: filter, prefetch: true)
    }
}
