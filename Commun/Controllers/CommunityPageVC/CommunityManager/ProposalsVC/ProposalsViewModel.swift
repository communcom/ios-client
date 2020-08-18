//
//  ProposalsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
class ProposalsViewModel: ListViewModel<ResponseAPIContentGetProposal> {
    var proposalsCount: UInt64 {(fetcher as! ProposalsListFetcher).proposalsCount}
    
    init() {
        let fetcher = ProposalsListFetcher()
        super.init(fetcher: fetcher, prefetch: false)
    }
}
