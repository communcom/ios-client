//
//  ProposalCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 8/27/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

protocol ProposalCellDelegate: class {
    var items: [ResponseAPIContentGetProposal] {get}
    func buttonAcceptDidTouch(forItemWithIdentity identity: ResponseAPIContentGetProposal.Identity)
    func buttonApplyDidTouch(forItemWithIdentity identity: ResponseAPIContentGetProposal.Identity)
}

extension ProposalCellDelegate where Self: BaseViewController {
    func buttonAcceptDidTouch(forItemWithIdentity identity: ResponseAPIContentGetProposal.Identity) {
        guard let proposal = items.first(where: {$0.identity == identity}) else {return}
        proposal.toggleAccept().flatMapToCompletable()
            .subscribe(onError: { (error) in
                self.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    func buttonApplyDidTouch(forItemWithIdentity identity: ResponseAPIContentGetProposal.Identity) {
        showAlert(title: "apply".localized().uppercaseFirst, message: "do you really want to apply this proposal?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in
            if index == 0 {
                self.acceptAndApply(proposalIdentity: identity)
            }
        }
    }
    
    private func acceptAndApply(proposalIdentity: ResponseAPIContentGetProposal.Identity) {
        guard var proposal = items.first(where: {$0.identity == proposalIdentity}),
            let proposer = proposal.proposer?.userId,
            let approvesCount = proposal.approvesCount,
            let approvesNeed = proposal.approvesNeed,
            approvesNeed > 0
        else {return}
        
        let isApproved = proposal.isApproved ?? false
        proposal.isBeingApproved = true
        
        if (approvesCount >= approvesNeed - 1) && !isApproved {
            let currentProposalCount = proposal.approvesCount ?? 0
            proposal.approvesCount = currentProposalCount + 1
            proposal.notifyChanged()
            
            // accept and apply
            BlockchainManager.instance.approveProposal(proposal.proposalId)
                .flatMapCompletable({RestAPIManager.instance.waitForTransactionWith(id: $0)})
                .do(onError: { (_) in
                    proposal.approvesCount = currentProposalCount
                }, onCompleted: {
                    proposal.isApproved = true
                    proposal.notifyChanged()
                })
                .andThen(
                    BlockchainManager.instance.execProposal(proposalName: proposal.proposalId, proposer: proposer)
                        .flatMapCompletable({RestAPIManager.instance.waitForTransactionWith(id: $0)})
                )
                .subscribe(onCompleted: {
                    self.showDone("applied".localized().uppercaseFirst)
                    proposal.notifyDeleted()
                }) { (error) in
                    self.showError(error)
                    proposal.isBeingApproved = false
                    proposal.notifyChanged()
                }
                .disposed(by: self.disposeBag)
        } else {
            // just apply
            proposal.notifyChanged()
            BlockchainManager.instance.execProposal(proposalName: proposal.proposalId, proposer: proposer)
                .flatMapCompletable({RestAPIManager.instance.waitForTransactionWith(id: $0)})
                .subscribe(onCompleted: {
                    self.showDone("applied".localized().uppercaseFirst)
                    proposal.notifyDeleted()
                }) { (error) in
                    self.showError(error)
                    proposal.isBeingApproved = false
                    proposal.notifyChanged()
                }
                .disposed(by: self.disposeBag)
        }
    }
}
