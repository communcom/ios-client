//
//  SetUserVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

extension SetUserVC {
    @IBAction func buttonNextDidTouch(_ sender: Any) {
        guard KeychainManager.currentUser()?.phoneNumber != nil else {
            resetSignUpProcess()
            return
        }
        
        guard let userName = userNameTextField.text,
            viewModel.isUserNameValid(userName) else {
                return
        }
        
        self.view.endEditing(true)
        
        showIndetermineHudWithMessage("setting username".localized().uppercaseFirst + "...")
        
        viewModel.set(userName: userName)
            .catchError({ (error) -> Single<String> in
                if let error = error as? ErrorAPI {
                    if error.caseInfo.message == "Invalid step taken",
                        Config.currentUser?.registrationStep == .toBlockChain{
                        return .just(Config.currentUser?.id ?? "")
                    }
                }
                throw error
            })
            .flatMapCompletable({ (id) -> Completable in
                self.showIndetermineHudWithMessage("saving to blockchain...".localized().uppercaseFirst)
                return RestAPIManager.instance.toBlockChain()
            })
            .subscribe(onCompleted: {
                AppDelegate.reloadSubject.onNext(true)
            }, onError: {error in
                self.hideHud()
                self.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Gestures
    @IBAction func handlerTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
