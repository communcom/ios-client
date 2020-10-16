//
//  CommunityBannedUserViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/9/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CommunityBannedUserViewModel: ListViewModel<ResponseAPIContentGetProfile> {
    init(communityId: String) {
        let fetcher = CommunityBannedUsersListFetcher(communityId: communityId)
        super.init(fetcher: fetcher)
    }
}
