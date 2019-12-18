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
        RestAPIManager.instance.block(userId)
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(
                    title: "user blocked".localized().uppercaseFirst,
                    message: "You've blocked" + " \(self.viewModel.profile.value?.username ?? "this user")" + ".\n" + "we're sorry that you've had this experience".localized().uppercaseFirst + ".") { _ in
                        self.viewModel.profile.value?.notifyDeleted()
                        self.viewModel.profile.value?.notifyEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
                    }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
        
    }
}
