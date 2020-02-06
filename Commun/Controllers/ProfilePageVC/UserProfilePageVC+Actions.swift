//
//  UserProfilePageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/15/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

extension UserProfilePageVC {    
    func blockUser() {
        guard let userId = viewModel.profile.value?.userId else {return}
        showIndetermineHudWithMessage("blocking".localized().uppercaseFirst + "...")
        
//        Completable.empty()
//            .delay(0.8, scheduler: MainScheduler.instance)
        BlockchainManager.instance.block(userId)
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(
                    title: "user blocked".localized().uppercaseFirst,
                    message: "you've blocked".localized().uppercaseFirst + " \(self.viewModel.profile.value?.username ?? "this user".localized())" + ".\n" + "we're sorry that you've had this experience".localized().uppercaseFirst + ".") { _ in
                        var profile = self.viewModel.profile.value
                        profile?.isInBlacklist = true
                        profile?.notifyChanged()
                        
                        profile?.notifyDeleted()
                        profile?.notifyEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
                    }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
        
    }
    
    func unblockUser() {
        guard let userId = viewModel.profile.value?.userId else {return}
        showIndetermineHudWithMessage("unblocking".localized().uppercaseFirst + "...")
        
//        Completable.empty()
//            .delay(0.8, scheduler: MainScheduler.instance)
        BlockchainManager.instance.unblock(userId)
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(
                    title: "user unblocked".localized().uppercaseFirst,
                    message: "you've unblocked".localized().uppercaseFirst + " \(self.viewModel.profile.value?.username ?? "this user".localized().uppercaseFirst)" + ".") { _ in
                        var user = self.viewModel.profile.value
                        user?.isInBlacklist = false
                        user?.notifyChanged()
                    }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
