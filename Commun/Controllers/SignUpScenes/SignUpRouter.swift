//
//  SignUpRouter.swift
//  Commun
//
//  Created by msm72 on 5/6/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
            
        case .setUserName:
            
            let setUserVC = SetUserVC()
            vc = setUserVC
            
        case .setPassword:
            let createPasswordVC = CreatePasswordVC()
            vc = createPasswordVC
            
        case .toBlockChain:
            if let setUserVC = self as? SetUserVC {
                setUserVC.navigateToSetPassword()
                return
            }
            
            let setUserVC = SetUserVC()
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
        navigationController?.popToVC(type: SignUpWithPhoneVC.self) { signUpVC in
            signUpVC.phoneNumberTextField.text = nil
        }
    }
}

extension SignUpRouter where Self: UIViewController {
    // MARK: - Handler
    func handleSignUpError(error: Error, with phone: String? = nil) {
        // get phone
        guard let phone = phone ?? Config.currentUser?.phoneNumber else {
            // reset if phone not found
            self.showError(error, showPleaseTryAgain: true) {
                self.resetSignUpProcess()
            }
            return
        }
        
        // catch error
        if let error = error as? CMError {
            switch error {
            case .registration(let message, let currentStep):
                if message == ErrorMessage.invalidStepTaken.rawValue {
                    // save state
                    var dataToSave = [String: Any]()
                    dataToSave[Config.registrationUserPhoneKey] = phone
                    dataToSave[Config.registrationStepKey] = currentStep
                    try! KeychainManager.save(dataToSave)
                    getState()
                    return
                }
                
                if message == ErrorMessage.couldNotCreateUserId.rawValue {
                    getState()
                    return
                }
                
            case .noConnection:
                self.showError(error)
                return
            default:
                break
            }
        }

        // unknown error
        self.showError(error)
    }
    
    func getState(showError: Bool = true) {
        showIndetermineHudWithMessage("retrieving registration state".localized().uppercaseFirst + "...")
        RestAPIManager.instance.getState()
            .subscribe(onSuccess: { (_) in
                self.hideHud()
                self.signUpNextStep()
            }) { (error) in
                self.hideHud()
                self.handleSignUpError(error: error)
            }
            .disposed(by: disposeBag)
    }
}
