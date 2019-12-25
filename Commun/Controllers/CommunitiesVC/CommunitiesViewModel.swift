//
//  CommunitiesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class CommunitiesViewModel: ListViewModel<ResponseAPIContentGetCommunity> {
    init(type: GetCommunitiesType, userId: String? = nil) {
        let fetcher = CommunitiesListFetcher(type: type, userId: userId)
        super.init(fetcher: fetcher)
        self.fetcher = fetcher
        defer {fetchNext()}
    }
}
