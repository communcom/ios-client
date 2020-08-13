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
            .do(onSuccess: {if $0.proposalsCount != nil { self.proposalsCount = $0.proposalsCount! }})
            .map {$0.items}
    }
    
    override func handleNewData(_ items: [ResponseAPIContentGetProposal]) {
        super.handleNewData(items)
        loadPosts(from: items.filter {$0.contentType == "post"})
        loadComments(from: items.filter {$0.contentType == "comment"})
    }
    
    private func loadPosts(from proposals: [ResponseAPIContentGetProposal]) {
        for proposal in proposals where proposal.data?.message_id?.permlink != nil {
            RestAPIManager.instance.loadPost(userId: proposal.data?.message_id?.author, permlink: proposal.data!.message_id!.permlink!, communityId: proposal.community?.communityId
            ).subscribe(onSuccess: { (post) in
                var proposal = proposal
                proposal.post = post
                proposal.notifyChanged()
            }).disposed(by: disposeBag)
        }
    }
    
    private func loadComments(from proposals: [ResponseAPIContentGetProposal]) {
        // TODO:
    }
}
