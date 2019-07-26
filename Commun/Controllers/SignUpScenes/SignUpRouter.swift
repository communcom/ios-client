//
//  SignUpRouter.swift
//  Commun
//
//  Created by msm72 on 5/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift

protocol SignUpRouter {
    var disposeBag: DisposeBag {get}
}

extension SignUpRouter where Self: UIViewController {
    // MARK: - Flow
    /// Move to next scene
    func signUpNextStep() {
        // Retrieve current user's state
        let user = KeychainManager.currentUser()
        let step = user?.registrationStep ?? .firstStep
        
        // Navigation
        var vc: UIViewController
        
        switch step {
        case .verify:
            let confirmUserVC = controllerContainer.resolve(ConfirmUserVC.self)!
            vc = confirmUserVC
            
        case .setUserName, .toBlockChain:
            let setUserVC = controllerContainer.resolve(SetUserVC.self)!
            vc = setUserVC
            
        default:
            return
        }
        
        self.navigationController?.pushViewController(vc)
    }
    
    /// Reset signing up
    func resetSignUpProcess() {
        try? KeychainManager.deleteUser()
        // Dismiss all screen
        popToSignUpVC()
    }
}

extension SignUpRouter where Self: UIViewController {
    // MARK: - Back button
    func setBackButtonToSignUpVC() {
        navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back".localized(), style: .plain, target: self, action: #selector(popToSignUpVC))
        navigationItem.leftBarButtonItem = newBackButton
    }
}

extension SignUpRouter where Self: UIViewController {
    // MARK: - Handler
    func handleSignUpError(error: Error, with phone: String) {
        if let error = error as? ErrorAPI {
            if error.caseInfo.message == "Invalid step taken" {
                handleInvalidStepTakenWithPhone(phone)
                return
            }
        }
        hideHud()
        showError(error)
    }
    
    /// handle Invalid step taken
    func handleInvalidStepTakenWithPhone(_ phone: String) {
        // Get state
        RestAPIManager.instance.rx.getState(phone: phone)
            .subscribe(onSuccess: { (result) in
                if result.currentState == "registered" {
                    self.showErrorWithLocalizedMessage("This number is already taken!")
                    return
                }
                self.hideHud()
                self.signUpNextStep()
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
