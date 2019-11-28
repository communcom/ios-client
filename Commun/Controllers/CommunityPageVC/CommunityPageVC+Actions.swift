//
//  CommunityPageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/21/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension CommunityPageVC {
    func hideCommunity() {
        guard let id = viewModel.profile.value?.communityId else {return}
        showIndetermineHudWithMessage("hiding".localized().uppercaseFirst + "...")
        
//        Completable.empty()
//            .delay(0.8, scheduler: MainScheduler.instance)
        RestAPIManager.instance.hideCommunity(id)
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(
                    title: "community hidden".localized().uppercaseFirst,
                    message: "You've hidden" + " \(self.viewModel.profile.value?.communityId ?? "this community")" + ".\n" + "we're sorry that you've had this experience".localized().uppercaseFirst + ".") { _ in
                        self.viewModel.profile.value?.notifyDeleted()
                        self.viewModel.profile.value?.notifyEvent(eventName: ResponseAPIContentGetCommunity.blockedEventName)
                    }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
