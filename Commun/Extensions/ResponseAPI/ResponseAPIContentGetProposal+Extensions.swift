//
//  ResponseAPIContentGetProposal+Extensions.swift
//  Commun
//
//  Created by Chung Tran on 8/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension ResponseAPIContentGetProposal {
    func toggleAccept() -> Single<ResponseAPIContentGetProposal> {
        var proposal = self
        let originIsApproved = proposal.isApproved ?? false
        
        let request: Single<String>
        if originIsApproved {
            request = BlockchainManager.instance.unapproveProposal(proposal.proposalId)
        } else {
            request = BlockchainManager.instance.approveProposal(proposal.proposalId)
        }
        
        return request
            .flatMapCompletable({RestAPIManager.instance.waitForTransactionWith(id: $0)})
            .do(onError: { _ in
                proposal.isBeingApproved = false
                proposal.isApproved = originIsApproved
                var currentProposalCount = proposal.approvesCount ?? 0
                if currentProposalCount == 0 && originIsApproved {
                    // prevent negative value
                    currentProposalCount = 1
                }
                proposal.approvesCount = originIsApproved ? currentProposalCount + 1 : currentProposalCount - 1
                proposal.notifyChanged()
            }, onCompleted: {
                proposal.isBeingApproved = false
                proposal.notifyChanged()
            }, onSubscribe: {
                // change state
                proposal.isBeingApproved = true
                proposal.isApproved = !originIsApproved
                var currentProposalCount = proposal.approvesCount ?? 0
                if currentProposalCount == 0 && originIsApproved {
                    // prevent negative value
                    currentProposalCount = 1
                }
                
                proposal.approvesCount = originIsApproved ? currentProposalCount - 1 : currentProposalCount + 1
                proposal.notifyChanged()
            })
            .andThen(Single<ResponseAPIContentGetProposal>.just(proposal))
    }
}
