//
//  ReferralUsersViewModel.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
class ReferralUsersViewModel: ListViewModel<ResponseAPIContentGetProfile> {
    init() {
        let fetcher = ReferralUsersListFetcher()
        super.init(fetcher: fetcher, prefetch: true)
    }
}
