//
//  CommunityPageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension CommunityPageVC {
    func hideCommunity() {
        guard let id = viewModel.profile.value?.communityId else {return}
        showIndetermineHudWithMessage("hiding".localized().uppercaseFirst + "...")
        
        BlockchainManager.instance.hideCommunity(id)
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(
                    title: "community hidden".localized().uppercaseFirst,
                    message: "You've hidden" + " \(self.viewModel.profile.value?.communityId ?? "this community")" + ".\n" + "we're sorry that you've had this experience".localized().uppercaseFirst + ".") { _ in
                        var profile = self.viewModel.profile.value
                        profile?.isInBlacklist = true
                        profile?.notifyChanged()
                        
                        profile?.notifyDeleted()
                        profile?.notifyEvent(eventName: ResponseAPIContentGetCommunity.blockedEventName)
                    }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func unhideCommunity() {
        guard let id = viewModel.profile.value?.communityId else {return}
        showIndetermineHudWithMessage("unhiding".localized().uppercaseFirst + "...")
        
        BlockchainManager.instance.unhideCommunity(id)
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(
                    title: "community unhidden".localized().uppercaseFirst,
                    message: "You've un hidden" + " \(self.viewModel.profile.value?.communityId ?? "this community")" + ".") { _ in
                        var profile = self.viewModel.profile.value
                        profile?.isInBlacklist = false
                        profile?.notifyChanged()
                    }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    @objc func getPointsButtonTapped(_ sender: UIButton) {
        guard let viewModel = viewModel as? CommunityPageViewModel else { return }
        let communityID: String = viewModel.communityId ?? viewModel.communityAlias ?? ""

        if !communityID.isEmpty {
            showOtherBalanceWalletVC(symbol: communityID.uppercased())
        }
    }
}
