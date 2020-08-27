//
//  ReportCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 8/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

protocol ReportCellDelegate: class {
    var items: [ResponseAPIContentGetReport] {get}
    func buttonProposalDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity)
    func buttonBanDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity)
    func communityIssuer(forCommunityId id: String) -> String?
}

extension ReportCellDelegate where Self: BaseViewController {
    func buttonProposalDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity) {
        guard var report = items.first(where: {$0.identity == identity}) else {return}
        
        if let proposal = report.proposal {
            // accept / refuse proposal
            
            let originIsApproved = proposal.isApproved ?? false
            // change state
            report.isPerformingAction = true
            report.proposal?.isApproved = !originIsApproved
            var currentProposalCount = report.proposal?.approvesCount ?? 0
            if currentProposalCount == 0 && originIsApproved {
                // prevent negative value
                currentProposalCount = 1
            }
            
            report.proposal?.approvesCount = originIsApproved ? currentProposalCount - 1 : currentProposalCount + 1
            report.notifyChanged()
            
            proposal.toggleAccept()
                .subscribe(onSuccess: { (proposal) in
                    report.proposal = proposal
                    report.isPerformingAction = false
                    report.notifyChanged()
                }) { (error) in
                    self.showError(error)
                    
                    report.proposal?.isApproved = originIsApproved
                    var currentProposalCount = report.proposal?.approvesCount ?? 0
                    if currentProposalCount == 0 && originIsApproved {
                        // prevent negative value
                        currentProposalCount = 1
                    }
                    report.proposal?.approvesCount = originIsApproved ? currentProposalCount + 1 : currentProposalCount - 1
                    report.isPerformingAction = false
                    report.notifyChanged()
                }
                .disposed(by: disposeBag)
        } else {
            // create ban proposal
            
            guard let communityId = report.post?.contentId.communityId,
                let permlink = report.post?.contentId.permlink
            else {return}
            let proposalId = BlockchainManager.instance.generateRandomProposalId()
            
            // change state immediately, reverse if fall
            report.isPerformingAction = true
            let proposal = ResponseAPIContentGetProposal.placeholder(proposalId: proposalId, isApproved: true, approvesCount: 1, approvesNeed: 3)
            report.proposal = proposal
            report.notifyChanged()
            
            var request: Single<String>
            if let issuer = self.communityIssuer(forCommunityId: communityId) {
                request = .just(issuer)
            } else {
                request = RestAPIManager.instance.getCommunity(id: communityId)
                    .map {$0.issuer ?? ""}
            }
            
            request.flatMap {BlockchainManager.instance.createBanProposal(proposalId: proposalId, communityCode: communityId, commnityIssuer: $0, permlink: permlink)}
                .flatMapCompletable({RestAPIManager.instance.waitForTransactionWith(id: $0)})
                .subscribe(onCompleted: {
                    report.isPerformingAction = false
                    report.notifyChanged()
                }) { (error) in
                    self.showError(error)
                    report.isPerformingAction = false
                    // reverse
                    report.proposal = nil
                    report.notifyChanged()
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    func buttonBanDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity) {
        guard var report = items.first(where: {$0.identity == identity}),
            let proposal = report.proposal,
            let proposer = proposal.proposer?.userId
        else {return}
        
        // exec proposal
        
        showAlert(title: "ban action".localized().uppercaseFirst, message: "do you really want to ban this content?".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1) { (index) in
            if index == 0 {
                report.isPerformingAction = true
                report.notifyChanged()
                
                BlockchainManager.instance.execProposal(proposalName: proposal.proposalId, proposer: proposer)
                    .flatMapCompletable({RestAPIManager.instance.waitForTransactionWith(id: $0)})
                    .subscribe(onCompleted: {
                        report.notifyDeleted()
                    }) { (error) in
                        self.showError(error)
                        report.isPerformingAction = false
                        report.notifyChanged()
                    }
                    .disposed(by: self.disposeBag)
            }
        }
    }
}
