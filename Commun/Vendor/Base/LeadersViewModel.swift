//
//  LeadersViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class LeadersViewModel: ListViewModel<ResponseAPIContentGetLeader> {
    convenience init(communityId: String? = nil, communityAlias: String? = nil, query: String? = nil) {
        let fetcher = LeadersListFetcher(communityId: communityId, communityAlias: communityAlias, query: query)
        self.init(fetcher: fetcher)
    }
}
