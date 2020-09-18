//
//  ReportCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 8/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ReportCellDelegate: class {
    var viewModel: ListViewModel<ResponseAPIContentGetReport> {get}
    func buttonProposalDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity)
    func buttonBanDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity)
    func communityIssuer(forCommunityId id: String) -> String?
}

extension ReportCellDelegate where Self: BaseViewController {
    func buttonProposalDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity) {
        guard var report = viewModel.items.value.first(where: {$0.identity == identity}) else {return}
        
        if let proposal = report.proposal {
            // accept / refuse proposal
            // change state
            report.isPerformingAction = true
            report.proposal?.isApproved = !(proposal.isApproved ?? false)
            var currentProposalCount = proposal.approvesCount ?? 0
            if currentProposalCount == 0 && (proposal.isApproved == true) {
                // prevent negative value
                currentProposalCount = 1
            }
            
            report.proposal?.approvesCount = (proposal.isApproved == true) ? currentProposalCount - 1 : currentProposalCount + 1
            report.notifyChanged()
            
            let request: Single<String>
            if proposal.isApproved == true {
                request = BlockchainManager.instance.unapproveProposal(proposal.proposalId)
            } else {
                request = BlockchainManager.instance.approveProposal(proposal.proposalId)
            }
            
            request
                .subscribe(onSuccess: { (proposal) in
                    report.isPerformingAction = false
                    report.notifyChanged()
                }) { (error) in
                    self.showError(error)
                    
                    // reverse
                    report.proposal = proposal
                    report.isPerformingAction = false
                    report.notifyChanged()
                }
                .disposed(by: disposeBag)
        } else {
            // create ban proposal
            
            guard let communityId = report.post?.contentId.communityId,
                let permlink = report.post?.contentId.permlink, let autor = report.post?.author?.userId
            else {return}
            let proposalId = BlockchainManager.instance.generateRandomProposalId()
            
            // change state immediately, reverse if fall
            report.isPerformingAction = true
            let proposal = ResponseAPIContentGetProposal.placeholder(proposalId: proposalId, isApproved: false, approvesCount: 0, approvesNeed: viewModel.items.value.first(where: {$0.proposal?.approvesNeed != nil})?.proposal?.approvesNeed ?? 3)
            report.proposal = proposal
            report.notifyChanged()
            
            var request: Single<String>
            if let issuer = self.communityIssuer(forCommunityId: communityId) {
                request = .just(issuer)
            } else {
                request = RestAPIManager.instance.getCommunity(id: communityId)
                    .map {$0.issuer ?? ""}
            }
            
            request.flatMap {BlockchainManager.instance.createBanProposal(proposalId: proposalId, communityCode: communityId, commnityIssuer: $0, permlink: permlink, author: autor)}
                .flatMapCompletable({RestAPIManager.instance.waitForTransactionWith(id: $0)})
                .subscribe(onCompleted: {
                    report.isPerformingAction = false
                    report.notifyChanged()
                }) { (error) in
                    self.showError(error)
                    guard let index = self.viewModel.items.value.firstIndex(where: {$0.identity == report.identity}) else {return}
                    var report = self.viewModel.items.value[index]
                    report.isPerformingAction = false
                    // reverse
                    report.proposal = nil
                    var newItems = self.viewModel.items.value
                    newItems[index] = report
                    self.viewModel.items.accept(newItems)
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    func buttonBanDidTouch(forItemWithIdentity identity: ResponseAPIContentGetReport.Identity) {
        guard var report = viewModel.items.value.first(where: {$0.identity == identity}),
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
