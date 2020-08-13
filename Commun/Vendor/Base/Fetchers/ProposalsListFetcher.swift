//
//  ProposalsListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class ProposalsListFetcher: ListFetcher<ResponseAPIContentGetProposal> {
    var communityIds = [String]()
    var proposalsCount: UInt64 = 0
    override var request: Single<[ResponseAPIContentGetProposal]> {
        RestAPIManager.instance.getProposals(communityIds: communityIds, limit: Int(limit), offset: Int(offset))
            .do(onSuccess: {self.proposalsCount = $0.proposalsCount})
            .map {$0.items}
    }
}
