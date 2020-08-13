//
//  ProposalsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
class ProposalsViewModel: ListViewModel<ResponseAPIContentGetProposal> {
    init(communityIds: [String]) {
        let fetcher = ProposalsListFetcher()
        fetcher.communityIds = communityIds
        super.init(fetcher: fetcher, prefetch: true)
    }
}
