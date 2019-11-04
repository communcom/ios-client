//
//  SubscribersViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class SubscribersViewModel: ListViewModel<ResponseAPIContentResolveProfile> {
    convenience init(userId: String? = nil, communityId: String? = nil) {
        let fetcher = SubscribersListFetcher()
        fetcher.userId = userId
        fetcher.communityId = communityId
        self.init(fetcher: fetcher)
        defer {fetchNext()}
    }
}
